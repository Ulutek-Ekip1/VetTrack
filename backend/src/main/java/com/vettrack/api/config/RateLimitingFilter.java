package com.vettrack.api.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

@Component
public class RateLimitingFilter extends OncePerRequestFilter {

    private static final int MAX_REQUESTS_PER_MINUTE = 10;
    private static final long ONE_MINUTE_IN_MILLIS = 60_000L;

    @Value("${app.rate-limiting.trusted-proxy-header-enabled:false}")
    private boolean trustedProxyHeaderEnabled;

    private final Map<String, RequestTracker> requestTrackers = new ConcurrentHashMap<>();

    public static class RequestTracker {
        final long windowStart;
        final AtomicInteger requestCount;

        RequestTracker(long windowStart) {
            this.windowStart = windowStart;
            this.requestCount = new AtomicInteger(1);
        }

        public long getWindowStart() {
            return windowStart;
        }

        public int getRequestCount() {
            return requestCount.get();
        }
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String path = request.getRequestURI();

        if ("/api/auth/login".equals(path) || "/api/auth/register".equals(path) ||
            "/auth/login".equals(path) || "/auth/register".equals(path)) {

            cleanExpiredTrackersIfNecessary();

            String clientIp = getClientIp(request);
            long currentTime = System.currentTimeMillis();

            RequestTracker tracker = requestTrackers.compute(clientIp, (ip, existingTracker) -> {
                if (existingTracker == null || (currentTime - existingTracker.windowStart) > ONE_MINUTE_IN_MILLIS) {
                    return new RequestTracker(currentTime);
                } else {
                    existingTracker.requestCount.incrementAndGet();
                    return existingTracker;
                }
            });

            if (tracker.requestCount.get() > MAX_REQUESTS_PER_MINUTE) {
                response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
                response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("""
                    {
                        "status": 429,
                        "error": "TOO_MANY_REQUESTS",
                        "message": "Çok fazla istek gönderildi. Lütfen 1 dakika sonra tekrar deneyiniz."
                    }
                    """);
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    private void cleanExpiredTrackersIfNecessary() {
        long currentTime = System.currentTimeMillis();
        if (requestTrackers.size() > 100) {
            requestTrackers.entrySet().removeIf(entry ->
                (currentTime - entry.getValue().windowStart) > ONE_MINUTE_IN_MILLIS
            );
        }
    }

    private String getClientIp(HttpServletRequest request) {
        if (trustedProxyHeaderEnabled) {
            String xForwardedFor = request.getHeader("X-Forwarded-For");
            if (xForwardedFor != null && !xForwardedFor.isBlank()) {
                return xForwardedFor.split(",")[0].trim();
            }
        }
        return request.getRemoteAddr();
    }

    public void setTrustedProxyHeaderEnabled(boolean trustedProxyHeaderEnabled) {
        this.trustedProxyHeaderEnabled = trustedProxyHeaderEnabled;
    }

    public Map<String, RequestTracker> getRequestTrackers() {
        return requestTrackers;
    }
}
