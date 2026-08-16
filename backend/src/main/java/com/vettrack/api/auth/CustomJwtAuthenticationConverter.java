package com.vettrack.api.auth;

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

import java.util.Collection;
import java.util.HashSet;
import java.util.Map;

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
                Integer adminCount = jdbcTemplate.queryForObject(
                        "SELECT COUNT(*) FROM profiles WHERE id = ?::uuid AND role = 'admin' AND is_active = true",
                        Integer.class,
                        userId
                );
                if (adminCount != null && adminCount > 0) {
                    isAdmin = true;
                }
            } catch (DataAccessException ignored) {
                // DB hatası durumunda admin varsayılmaz
            }
        }

        if (isAdmin) {
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
        }

        // 2. Aktif klinik üyeliği → ROLE_VET_STAFF & ROLE_CLINIC_ADMIN
        if (userId != null && !userId.isBlank()) {
            try {
                var rows = jdbcTemplate.queryForList(
                        "SELECT is_clinic_admin FROM clinic_memberships WHERE user_id = ?::uuid AND status = 'active'",
                        userId
                );
                if (!rows.isEmpty()) {
                    authorities.add(new SimpleGrantedAuthority("ROLE_VET_STAFF"));
                    boolean hasClinicAdmin = rows.stream()
                            .anyMatch(r -> Boolean.TRUE.equals(r.get("is_clinic_admin")));
                    if (hasClinicAdmin) {
                        authorities.add(new SimpleGrantedAuthority("ROLE_CLINIC_ADMIN"));
                    }
                }
            } catch (DataAccessException ignored) {
                // DB erişim hatası: authority eklenmeden devam edilir.
            }
        }

        // 3. Standart kullanıcı rolü (Varsayılan olarak ROLE_OWNER)
        authorities.add(new SimpleGrantedAuthority("ROLE_OWNER"));

        return new JwtAuthenticationToken(jwt, authorities);
    }
}