package com.vettrack.api.auth;

import org.springframework.core.convert.converter.Converter;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;

import java.util.Collection;
import java.util.HashSet;
import java.util.Map;

public class CustomJwtAuthenticationConverter implements Converter<Jwt, AbstractAuthenticationToken> {

    private final JwtGrantedAuthoritiesConverter defaultGrantedAuthoritiesConverter = new JwtGrantedAuthoritiesConverter();

    @Override
    public AbstractAuthenticationToken convert(Jwt jwt) {
        Collection<GrantedAuthority> authorities = new HashSet<>(defaultGrantedAuthoritiesConverter.convert(jwt));

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

        return new JwtAuthenticationToken(jwt, authorities);
    }
}