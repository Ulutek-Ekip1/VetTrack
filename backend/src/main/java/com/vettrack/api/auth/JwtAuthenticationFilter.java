package com.vettrack.api.auth;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtDecoder jwtDecoder;
    private final JdbcTemplate jdbcTemplate;

    public JwtAuthenticationFilter(JwtDecoder jwtDecoder, JdbcTemplate jdbcTemplate) {
        this.jwtDecoder = jwtDecoder;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String authorization = request.getHeader("Authorization");

        if (authorization != null && authorization.startsWith("Bearer ")
                && SecurityContextHolder.getContext().getAuthentication() == null) {
            String token = authorization.substring(7);
            try {
                Jwt jwt = jwtDecoder.decode(token);
                
                String userId = jwt.getSubject();
                try {
                    Boolean isActive = jdbcTemplate.queryForObject(
                        "SELECT is_active FROM profiles WHERE id = ?::uuid", 
                        Boolean.class, userId);

                    if (Boolean.FALSE.equals(isActive)) {
                        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                        response.getWriter().write("User account is inactive or deleted.");
                        return;
                    }
                } catch (DataAccessException e) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    return;
                }

                Authentication authentication = new JwtAuthenticationToken(jwt);
                SecurityContextHolder.getContext().setAuthentication(authentication);
            } catch (JwtException ex) {
                // Token geçersizse isteði kesmek yerine anonymous (anonim) olarak devam etmesine izin veriyoruz.
                // Yetkilendirme (authorization) katmaný korunan endpoint'leri zaten engelleyecektir.
            }
        }

        filterChain.doFilter(request, response);
    }
}
