package com.vettrack.api.auth;

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.convert.converter.Converter;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.stereotype.Component;
import lombok.extern.slf4j.Slf4j;

import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.function.Supplier;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * JWT'den Spring Security authority'leri üretir.
 *
 * <p><b>Güvenlik & Yetkilendirme Kuralları:</b>
 * <ul>
 *   <li>{@code user_metadata} kullanıcı tarafından kayıt / profil güncelleme esnasında
 *       düzenlenebilir (untrusted). Bu nedenle <strong>user_metadata alanından hiçbir rol üretilmez</strong>
 *       (Yetki yükseltme / Privilege Escalation koruması).</li>
 *   <li>{@code ROLE_ADMIN} yalnızca güvenilir sunucu yönetimindeki {@code app_metadata.role = 'admin'}
 *       veya veritabanındaki {@code profiles.role = 'admin' AND is_active = true} kaydı ile verilir.</li>
 *   <li>{@code ROLE_VET_STAFF} yalnızca {@code clinic_memberships.status = 'active'} kaydı
 *       bulunan kullanıcılara verilir.</li>
 *   <li>{@code ROLE_CLINIC_ADMIN} yalnızca {@code clinic_memberships.status = 'active' AND is_clinic_admin = true}
 *       kaydı bulunan kullanıcılara verilir.</li>
 *   <li>Tüm authenticated kullanıcılar için varsayılan yetki {@code ROLE_OWNER}'dır.</li>
 * </ul>
 */
@Slf4j
@Component
public class CustomJwtAuthenticationConverter implements Converter<Jwt, AbstractAuthenticationToken> {

    private final JwtGrantedAuthoritiesConverter defaultGrantedAuthoritiesConverter =
            new JwtGrantedAuthoritiesConverter();

    private final JdbcTemplate jdbcTemplate;

    public CustomJwtAuthenticationConverter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public AbstractAuthenticationToken convert(Jwt jwt) {
        Collection<GrantedAuthority> authorities =
                new HashSet<>(defaultGrantedAuthoritiesConverter.convert(jwt));

        String userId = jwt.getSubject();

        // 1. Güvenilir admin kontrolü (app_metadata veya profiles DB tablosu)
        Map<String, Object> appMetadata = jwt.getClaim("app_metadata");
        boolean isAdmin = false;
        if (appMetadata != null && "admin".equalsIgnoreCase((String) appMetadata.get("role"))) {
            isAdmin = true;
        }

        if (!isAdmin && userId != null && !userId.isBlank()) {
            try {
                Integer adminCount = queryWithRetry(
                        "admin rolü",
                        userId,
                        () -> jdbcTemplate.queryForObject(
                                "SELECT COUNT(*) FROM profiles WHERE id = ?::uuid AND role = 'admin' AND is_active = true",
                                Integer.class,
                                userId
                        )
                );
                if (adminCount != null && adminCount > 0) {
                    isAdmin = true;
                }
            } catch (DataAccessException ex) {
                log.error("Admin rolü DB kontrolü kalıcı olarak başarısız oldu, userId={} için admin varsayılmadı: {}",
                        userId, ex.getMessage());
            }
        }

        if (isAdmin) {
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
        }

        // 2. Aktif klinik üyeliği → ROLE_VET_STAFF & ROLE_CLINIC_ADMIN
        if (userId != null && !userId.isBlank()) {
            try {
                var rows = queryWithRetry(
                        "klinik üyeliği",
                        userId,
                        () -> jdbcTemplate.queryForList(
                                "SELECT is_clinic_admin FROM clinic_memberships WHERE user_id = ?::uuid AND status = 'active'",
                                userId
                        )
                );
                if (!rows.isEmpty()) {
                    authorities.add(new SimpleGrantedAuthority("ROLE_VET_STAFF"));
                    boolean hasClinicAdmin = rows.stream()
                            .anyMatch(r -> Boolean.TRUE.equals(r.get("is_clinic_admin")));
                    if (hasClinicAdmin) {
                        authorities.add(new SimpleGrantedAuthority("ROLE_CLINIC_ADMIN"));
                    }
                }
            } catch (DataAccessException ex) {
                log.error("Klinik üyeliği DB kontrolü kalıcı olarak başarısız oldu, userId={} için ROLE_VET_STAFF/ROLE_CLINIC_ADMIN eklenmedi: {}",
                        userId, ex.getMessage());
            }
        }

        // 3. Standart kullanıcı rolü (Varsayılan olarak ROLE_OWNER)
        authorities.add(new SimpleGrantedAuthority("ROLE_OWNER"));

        return new JwtAuthenticationToken(jwt, authorities);
    }

    /**
     * ROLE_VET_STAFF / ROLE_ADMIN artık tamamen bu DB sorgularının başarısına bağlı
     * (bkz. sınıf üstü Javadoc — user_metadata'dan doğrudan rol üretimi kaldırıldı,
     * privilege escalation koruması). Bu sorgular artık HER authenticated istekte
     * çalışıyor; bağlantı havuzu baskısı altında (HikariCP tükenmesi →
     * {@link org.springframework.jdbc.CannotGetJdbcConnectionException}, PgBouncer/ağ
     * kesintisi) geçici bir hata legit bir vet'i tek seferde 403'e düşürebilir.
     *
     * <p>{@code CannotGetJdbcConnectionException} Spring'in hiyerarşisinde (yanıltıcı
     * biçimde) {@code NonTransientDataAccessException} altında yer alır — sadece
     * {@link org.springframework.dao.TransientDataAccessException} yakalamak bu en olası
     * senaryoyu (havuz baskısı) KAÇIRIRDI. Bu yüzden burada genel {@link DataAccessException}
     * için bir kez tekrar deneniyor; kalıcı bir SQL/şema hatası varsa ikinci deneme de aynı
     * şekilde başarısız olur ve çağırana fırlatılır (fail-closed korunur).
     */
    private <T> T queryWithRetry(String context, String userId, Supplier<T> query) {
        try {
            return query.get();
        } catch (DataAccessException firstAttemptEx) {
            log.warn("{} DB sorgusu başarısız oldu, tekrar deneniyor. userId={}: {}",
                    context, userId, firstAttemptEx.getMessage());
            return query.get();
        }
    }
}