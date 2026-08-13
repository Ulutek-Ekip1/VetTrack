package com.vettrack.api.auth;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JdbcTemplate jdbcTemplate;

    public JwtAuthenticationFilter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication != null && authentication instanceof JwtAuthenticationToken jwtAuthToken) {
            Jwt jwt = jwtAuthToken.getToken();
            String userId = jwt.getSubject();
            try {
                List<Boolean> statusList = jdbcTemplate.queryForList(
                    "SELECT is_active FROM profiles WHERE id = ?::uuid",
                    Boolean.class, userId);

                if (!statusList.isEmpty() && Boolean.FALSE.equals(statusList.get(0))) {
                    SecurityContextHolder.clearContext();
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("User account is inactive or deleted.");
                    return;
                }
            } catch (DataAccessException e) {
                SecurityContextHolder.clearContext();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("Database error during authentication.");
                return;
            }
        }

        filterChain.doFilter(request, response);
    }
}