package com.vettrack.api.auth;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import java.util.HashMap;
import java.time.LocalDateTime;

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

    private final ObjectMapper objectMapper = new ObjectMapper();

    private void writeErrorResponse(HttpServletResponse response, int status, String errorCode, String message) throws java.io.IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        Map<String, Object> errorDetails = new HashMap<>();
        errorDetails.put("timestamp", LocalDateTime.now().toString());
        errorDetails.put("status", status);
        errorDetails.put("error", errorCode);
        errorDetails.put("message", message);
        response.getWriter().write(objectMapper.writeValueAsString(errorDetails));
    }

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
                    writeErrorResponse(response, HttpServletResponse.SC_UNAUTHORIZED, "ACCOUNT_INACTIVE", "User account is inactive or deleted.");
                    return;
                }
            } catch (DataAccessException e) {
                SecurityContextHolder.clearContext();
                writeErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "INTERNAL_SERVER_ERROR", "Database error during authentication.");
                return;
            }
        }

        filterChain.doFilter(request, response);
    }
}