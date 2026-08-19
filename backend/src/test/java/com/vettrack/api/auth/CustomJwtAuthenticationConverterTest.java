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
 * Trello: "CustomJwtAuthenticationConverter: Silent Catch Düzeltmesi ve Yapılandırılmış Loglama"
 * DB kaynaklı yetki kayıplarının (catch (DataAccessException ignored)) artık sessizce
 * yutulmadığını, WARN seviyesinde loglandığını doğrular.
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

    @Test
    @DisplayName("Admin DB kontrolü DataAccessException fırlatırsa: admin verilmez ama WARN loglanır (artık sessiz yutulmaz)")
    void whenAdminDbCheckFails_thenLogsWarnAndDoesNotGrantAdmin() {
        String userId = UUID.randomUUID().toString();
        when(jdbcTemplate.queryForObject(anyString(), eq(Integer.class), eq(userId)))
                .thenThrow(new DataAccessResourceFailureException("connection refused"));
        when(jdbcTemplate.queryForList(anyString(), eq(userId))).thenReturn(List.of());

        AbstractAuthenticationToken token = converter.convert(buildJwt(userId));

        assertFalse(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN")));
        assertTrue(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_OWNER")));

        List<ILoggingEvent> warnLogs = logAppender.list.stream()
                .filter(e -> e.getLevel() == Level.WARN)
                .toList();
        assertEquals(1, warnLogs.size());
        assertTrue(warnLogs.get(0).getFormattedMessage().contains(userId));
        assertTrue(warnLogs.get(0).getFormattedMessage().contains("Admin"));
    }

    @Test
    @DisplayName("Klinik üyeliği DB kontrolü DataAccessException fırlatırsa: ROLE_VET_STAFF verilmez ama WARN loglanır")
    void whenClinicMembershipDbCheckFails_thenLogsWarnAndDoesNotGrantVetStaff() {
        String userId = UUID.randomUUID().toString();
        when(jdbcTemplate.queryForObject(anyString(), eq(Integer.class), eq(userId))).thenReturn(0);
        when(jdbcTemplate.queryForList(anyString(), eq(userId)))
                .thenThrow(new DataAccessResourceFailureException("connection refused"));

        AbstractAuthenticationToken token = converter.convert(buildJwt(userId));

        assertFalse(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_VET_STAFF")));
        assertTrue(token.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_OWNER")));

        List<ILoggingEvent> warnLogs = logAppender.list.stream()
                .filter(e -> e.getLevel() == Level.WARN)
                .toList();
        assertEquals(1, warnLogs.size());
        assertTrue(warnLogs.get(0).getFormattedMessage().contains(userId));
        assertTrue(warnLogs.get(0).getFormattedMessage().contains("Klinik"));
    }

    @Test
    @DisplayName("DB kontrolleri başarılıysa: hiçbir WARN loglanmaz")
    void whenDbChecksSucceed_thenNoWarningsLogged() {
        String userId = UUID.randomUUID().toString();
        when(jdbcTemplate.queryForObject(anyString(), eq(Integer.class), eq(userId))).thenReturn(0);
        when(jdbcTemplate.queryForList(anyString(), eq(userId))).thenReturn(List.of());

        converter.convert(buildJwt(userId));

        long warnCount = logAppender.list.stream().filter(e -> e.getLevel() == Level.WARN).count();
        assertEquals(0, warnCount);
    }
}
