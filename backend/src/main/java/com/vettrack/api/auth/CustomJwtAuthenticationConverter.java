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
 * <p><b>Authority üretim kuralı:</b>
 * <ul>
 *   <li>{@code user_metadata.role} → {@code ROLE_OWNER}, {@code ROLE_ADMIN} gibi roller
 *       <em>doğrudan</em> eklenir. <strong>Ancak {@code vet_staff} bu eşlemeden muaftır</strong>;
 *       çünkü vet_staff yetkisi yalnızca aktif klinik üyeliğiyle (aşağıda) verilir.</li>
 *   <li>{@code clinic_memberships.status = 'active'} → {@code ROLE_VET_STAFF} eklenir.
 *       Üyeliği {@code disabled} olan bir hesap bu sorgudan 0 satır alır ve hiç
 *       {@code ROLE_VET_STAFF} almaz — okuma dahil tüm vet-path'leri engellenir.</li>
 * </ul>
 *
 * <p>Bu tasarım şunları sağlar:
 * <ul>
 *   <li>Davet kabul eden doktorlar (JWT'de {@code ROLE_OWNER}) aktif üyelikleri sayesinde
 *       {@code ROLE_VET_STAFF} alır (P1a fix).</li>
 *   <li>Üyeliği devre dışı bırakılan eski vet_staff hesapları, JWT'de
 *       {@code user_metadata.role=vet_staff} olsa bile {@code ROLE_VET_STAFF} alamaz.</li>
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

        // 1. user_metadata.role → authority (ROLE_OWNER, ROLE_ADMIN, vb.)
        //    "vet_staff" bu eşlemeden kasıtlı olarak çıkarılmıştır:
        //    ROLE_VET_STAFF yalnızca aşağıdaki aktif üyelik sorgusuyla verilir.
        //    Böylece üyeliği disabled olan hesaplar JWT'den ROLE_VET_STAFF alamaz.
        Map<String, Object> userMetadata = jwt.getClaim("user_metadata");
        String role = null;

        if (userMetadata != null && userMetadata.containsKey("role")) {
            role = (String) userMetadata.get("role");
        } else if (jwt.hasClaim("role")) {
            role = jwt.getClaimAsString("role");
        }

        if (role != null && !role.isBlank() && !"vet_staff".equalsIgnoreCase(role)) {
            String formattedRole = role.startsWith("ROLE_") ? role.toUpperCase() : "ROLE_" + role.toUpperCase();
            authorities.add(new SimpleGrantedAuthority(formattedRole));
        }

        // 2. Aktif klinik üyeliği → ROLE_VET_STAFF
        //    status = 'active' olan üyeler VET_STAFF yetkisi alır.
        //    status = 'disabled' → 0 satır → yetki verilmez → okuma dahil tüm vet path'leri engellenir.
        String userId = jwt.getSubject();
        if (userId != null && !userId.isBlank()) {
            try {
                Integer count = jdbcTemplate.queryForObject(
                        "SELECT COUNT(*) FROM clinic_memberships WHERE user_id = ?::uuid AND status = 'active'",
                        Integer.class,
                        userId
                );
                if (count != null && count > 0) {
                    authorities.add(new SimpleGrantedAuthority("ROLE_VET_STAFF"));
                }
            } catch (DataAccessException ex) {
                // DB erişim hatası: authority eklenmeden devam edilir.
            }
        }

        return new JwtAuthenticationToken(jwt, authorities);
    }
}