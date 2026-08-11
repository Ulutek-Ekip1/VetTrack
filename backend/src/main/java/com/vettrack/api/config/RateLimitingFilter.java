package com.vettrack.api.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitingFilter extends OncePerRequestFilter {

    private static final int MAX_REQUESTS_PER_MINUTE = 10;
    private final Map<String, RequestCounter> requestCounts = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String path = request.getRequestURI();

        if (path.startsWith("/auth/login") || path.startsWith("/auth/register")) {
            String clientIp = getClientIP(request);
            long currentTime = Instant.now().getEpochSecond();

            RequestCounter counter = requestCounts.compute(clientIp, (ip, count) -> {
                if (count == null || (currentTime - count.startTime) >= 60) {
                    return new RequestCounter(currentTime, 1);
                } else {
                    count.count++;
                    return count;
                }
            });

            if (counter.count > MAX_REQUESTS_PER_MINUTE) {
                response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
                response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                response.setCharacterEncoding("UTF-8");
                String jsonResponse = "{\"status\":429,\"error\":\"TOO_MANY_REQUESTS\",\"message\":\"Çok fazla istek gönderildi. Lütfen 1 dakika sonra tekrar deneyiniz.\"}";
                response.getWriter().write(jsonResponse);
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    private String getClientIP(HttpServletRequest request) {
        String xfHeader = request.getHeader("X-Forwarded-For");
        if (xfHeader == null || xfHeader.isEmpty()) {
            return request.getRemoteAddr();
        }
        return xfHeader.split(",")[0].trim();
    }

    private static class RequestCounter {
        final long startTime;
        int count;

        RequestCounter(long startTime, int count) {
            this.startTime = startTime;
            this.count = count;
        }
    }
}
