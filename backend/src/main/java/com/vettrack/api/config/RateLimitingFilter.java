package com.vettrack.api.config;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Config-driven rate limiting filter.
 * <p>
 * Endpoint rules are loaded from application.yml under 'app.rate-limiting.endpoints'.
 * Each rule defines a list of paths, a max request count, and a time window in seconds.
 * <p>
 * Cache key is 'ip:path' so different endpoints are tracked independently for the same client.
 */
@Component
@RequiredArgsConstructor
public class RateLimitingFilter extends OncePerRequestFilter {

    private final RateLimitProperties properties;

    // Path -> rule lookup, built once at startup for O(1) match
    private Map<String, RateLimitProperties.EndpointRule> ruleByPath;

    // Single cache shared across all rate-limited endpoints; key format: 'ip:path'
    // Expire window is set to the longest configured window to cover all rules safely
    private Cache<String, RequestTracker> requestTrackers;

    @Override
    protected void initFilterBean() {
        ruleByPath = new HashMap<>();
        int longestWindowSeconds = 60;

        for (RateLimitProperties.EndpointRule rule : properties.getEndpoints()) {
            for (String path : rule.getPaths()) {
                ruleByPath.put(path, rule);
            }
            if (rule.getWindowSeconds() > longestWindowSeconds) {
                longestWindowSeconds = rule.getWindowSeconds();
            }
        }

        requestTrackers = Caffeine.newBuilder()
                .expireAfterWrite(longestWindowSeconds, TimeUnit.SECONDS)
                .maximumSize(10_000)
                .build();
    }

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
        RateLimitProperties.EndpointRule rule = ruleByPath.get(path);

        if (rule == null) {
            filterChain.doFilter(request, response);
            return;
        }

        String clientIp = getClientIp(request);
        String cacheKey = clientIp + ":" + path;
        long currentTime = System.currentTimeMillis();
        long windowMillis = rule.getWindowSeconds() * 1000L;

        RequestTracker tracker = requestTrackers.asMap().compute(cacheKey, (key, existingTracker) -> {
            if (existingTracker == null || (currentTime - existingTracker.windowStart) > windowMillis) {
                return new RequestTracker(currentTime);
            } else {
                existingTracker.requestCount.incrementAndGet();
                return existingTracker;
            }
        });

        if (tracker != null && tracker.requestCount.get() > rule.getMaxRequests()) {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("""
                {
                    "status": 429,
                    "error": "TOO_MANY_REQUESTS",
                    "message": "Çok fazla istek gönderildi. Lütfen bir süre sonra tekrar deneyiniz."
                }
                """);
            return;
        }

        filterChain.doFilter(request, response);
    }

    /**
     * Resolves the client IP address.
     * Security Note: trusted-proxy-header-enabled should only be set to true when running behind a trusted reverse proxy
     * (e.g., Nginx, AWS ALB, Cloudflare) that reliably overwrites/sanitizes incoming X-Forwarded-For headers.
     */
    private String getClientIp(HttpServletRequest request) {
        if (properties.isTrustedProxyHeaderEnabled()) {
            String xForwardedFor = request.getHeader("X-Forwarded-For");
            if (xForwardedFor != null && !xForwardedFor.isBlank()) {
                return xForwardedFor.split(",")[0].trim();
            }
        }
        return request.getRemoteAddr();
    }

    public Map<String, RequestTracker> getRequestTrackers() {
        return requestTrackers.asMap();
    }
}
