package com.vettrack.api.auth;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.read.ListAppender;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.jdbc.CannotGetJdbcConnectionException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Trello: "403 Forbidden Yetki Üretim Kök Neden Analizi"
 * ROLE_VET_STAFF/ROLE_ADMIN artık tamamen bu iki JDBC sorgusunun başarısına bağlı.
 * DB kaynaklı hatalar artık (1) sessizce yutulmuyor, loglanıyor ve (2) bir kez
 * tekrar deneniyor — HikariCP havuz baskısı gibi geçici hatalarda legit bir vet'i
 * tek seferde 403'e düşürmemek için.
 */
class CustomJwtAuthenticationConverterTest {

    private JdbcTemplate jdbcTemplate;
    private CustomJwtAuthenticationConverter converter;
    private ListAppender<ILoggingEvent> logAppender;
    private Logger logger;

    @BeforeEach
    void setUp() {
        jdbcTemplate = mock(JdbcTemplate.class);
        converter = new CustomJwtAuthenticationConverter(jdbcTemplate);

        logger = (Logger) LoggerFactory.getLogger(CustomJwtAuthenticationConverter.class);
        logAppender = new ListAppender<>();
        logAppender.start();
        logger.addAppender(logAppender);
    }

    @AfterEach
    void tearDown() {
        logger.detachAppender(logAppender);
    }

    private Jwt buildJwt(String subject) {
        return Jwt.withTokenValue("token")
                .header("alg", "ES256")
                .subject(subject)
                .claim("sub", subject)
                .issuedAt(Instant.now())
                .expiresAt(Instant.now().plusSeconds(3600))
                .build();
    }

    private List<ILoggingEvent> logsAt(Level level) {
        return logAppender.list.stream().filter(e -> e.getLevel() == level).toList();
    }

    @Test
    @DisplayName("Klinik üyeliği sorgusu ilk denemede havuz baskısıyla (CannotGetJdbcConnectionException) başarısız olur ama retry'da başarılı olursa: ROLE_VET_STAFF yine verilir, sadece WARN loglanır")
    void whenClinicMembershipQueryFailsOnceThenSucceedsOnRetry_thenGrantsRoleAndLogsOnlyWarn() {
        String userId = UUID.randomUUID().toString();
        when(jdbcTemplate.queryForObject(anyString(), eq(Integer.class), eq(userId))).thenReturn(0);
        when(jdbcTemplate.queryForList(anyString(), eq(userId)))
                .thenThrow(new CannotGetJdbcConnectionException("connection pool exhausted"))
                .thenReturn(List.of(java.util.Map.of("is_clinic_admin", false)));

        AbstractAuthenticationToken token = converter.convert(buildJwt(userId));

        assertTrue(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_VET_STAFF")));

        assertEquals(1, logsAt(Level.WARN).size());
        assertEquals(0, logsAt(Level.ERROR).size());
        assertTrue(logsAt(Level.WARN).get(0).getFormattedMessage().contains(userId));
    }

    @Test
    @DisplayName("Admin DB kontrolü iki denemede de DataAccessException fırlatırsa: admin verilmez, WARN (retry) + ERROR (kalıcı hata) loglanır")
    void whenAdminDbCheckFailsOnBothAttempts_thenLogsWarnThenErrorAndDoesNotGrantAdmin() {
        String userId = UUID.randomUUID().toString();
        when(jdbcTemplate.queryForObject(anyString(), eq(Integer.class), eq(userId)))
                .thenThrow(new DataAccessResourceFailureException("connection refused"));
        when(jdbcTemplate.queryForList(anyString(), eq(userId))).thenReturn(List.of());

        AbstractAuthenticationToken token = converter.convert(buildJwt(userId));

        assertFalse(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")));
        assertTrue(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_OWNER")));

        assertEquals(1, logsAt(Level.WARN).size());
        assertEquals(1, logsAt(Level.ERROR).size());
        assertTrue(logsAt(Level.ERROR).get(0).getFormattedMessage().contains(userId));
        assertTrue(logsAt(Level.ERROR).get(0).getFormattedMessage().contains("Admin"));
    }

    @Test
    @DisplayName("Klinik üyeliği DB kontrolü iki denemede de başarısız olursa: ROLE_VET_STAFF verilmez, WARN + ERROR loglanır")
    void whenClinicMembershipDbCheckFailsOnBothAttempts_thenLogsWarnThenErrorAndDoesNotGrantVetStaff() {
        String userId = UUID.randomUUID().toString();
        when(jdbcTemplate.queryForObject(anyString(), eq(Integer.class), eq(userId))).thenReturn(0);
        when(jdbcTemplate.queryForList(anyString(), eq(userId)))
                .thenThrow(new DataAccessResourceFailureException("connection refused"));

        AbstractAuthenticationToken token = converter.convert(buildJwt(userId));

        assertFalse(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_VET_STAFF")));
        assertTrue(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_OWNER")));

        assertEquals(1, logsAt(Level.WARN).size());
        assertEquals(1, logsAt(Level.ERROR).size());
        assertTrue(logsAt(Level.ERROR).get(0).getFormattedMessage().contains(userId));
        assertTrue(logsAt(Level.ERROR).get(0).getFormattedMessage().contains("Klinik"));
    }

    @Test
    @DisplayName("DB kontrolleri ilk denemede başarılıysa: hiçbir WARN/ERROR loglanmaz")
    void whenDbChecksSucceedFirstTry_thenNoWarningsOrErrorsLogged() {
        String userId = UUID.randomUUID().toString();
        when(jdbcTemplate.queryForObject(anyString(), eq(Integer.class), eq(userId))).thenReturn(0);
        when(jdbcTemplate.queryForList(anyString(), eq(userId))).thenReturn(List.of());

        converter.convert(buildJwt(userId));

        assertEquals(0, logsAt(Level.WARN).size());
        assertEquals(0, logsAt(Level.ERROR).size());
    }
}
