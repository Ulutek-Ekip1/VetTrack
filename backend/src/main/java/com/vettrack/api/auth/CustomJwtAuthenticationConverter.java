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
 * <p>Supabase JWT'sindeki {@code user_metadata.role} alanından temel rolü okur
 * ({@code ROLE_OWNER}, {@code ROLE_VET_STAFF}, …). Bunun yanı sıra kullanıcının
 * {@code clinic_memberships} tablosunda aktif bir kaydı varsa —JWT'deki role ne
 * olursa olsun— {@code ROLE_VET_STAFF} authority'sini ekler. Bu sayede davet
 * kabul eden doktorların JWT'leri hâlâ {@code ROLE_OWNER} taşısa da okuma
 * endpoint'lerine erişebilirler (P1a fix).
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

        // 1. user_metadata.role → authority (mevcut davranış korunuyor)
        Map<String, Object> userMetadata = jwt.getClaim("user_metadata");
        String role = null;

        if (userMetadata != null && userMetadata.containsKey("role")) {
            role = (String) userMetadata.get("role");
        } else if (jwt.hasClaim("role")) {
            role = jwt.getClaimAsString("role");
        }

        if (role != null && !role.isBlank()) {
            String formattedRole = role.startsWith("ROLE_") ? role.toUpperCase() : "ROLE_" + role.toUpperCase();
            authorities.add(new SimpleGrantedAuthority(formattedRole));
        }

        // 2. Aktif klinik üyeliği → ROLE_VET_STAFF (P1a fix)
        //    Davet kabul eden doktorun JWT'si ROLE_OWNER taşısa da clinic_memberships'te
        //    aktif kaydı varsa VET_STAFF yetkisi verilir; read endpoint'leri uniform çalışır.
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
                // DB erişim hatası: authority eklenmeden devam edilir; request zaten
                // mevcut JWT rolüyle değerlendirilir. Hata loglama istenirse buraya eklenebilir.
            }
        }

        return new JwtAuthenticationToken(jwt, authorities);
    }
}