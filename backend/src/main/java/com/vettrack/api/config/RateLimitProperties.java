package com.vettrack.api.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.ArrayList;
import java.util.List;

/**
 * Rate limiting configuration loaded from application.yml under 'app.rate-limiting'.
 * Each endpoint entry defines its own paths, max request count, and time window.
 */
@Data
@Configuration
@ConfigurationProperties(prefix = "app.rate-limiting")
public class RateLimitProperties {

    private boolean trustedProxyHeaderEnabled = false;
    private List<EndpointRule> endpoints = new ArrayList<>();

    public boolean isTrustedProxyHeaderEnabled() {
        return trustedProxyHeaderEnabled;
    }

    public void setTrustedProxyHeaderEnabled(boolean trustedProxyHeaderEnabled) {
        this.trustedProxyHeaderEnabled = trustedProxyHeaderEnabled;
    }

    public List<EndpointRule> getEndpoints() {
        return endpoints;
    }

    public void setEndpoints(List<EndpointRule> endpoints) {
        this.endpoints = endpoints;
    }

    @Data
    public static class EndpointRule {
        private List<String> paths = new ArrayList<>();
        private int maxRequests = 10;
        private int windowSeconds = 60;

        public List<String> getPaths() {
            return paths;
        }

        public void setPaths(List<String> paths) {
            this.paths = paths;
        }

        public int getMaxRequests() {
            return maxRequests;
        }

        public void setMaxRequests(int maxRequests) {
            this.maxRequests = maxRequests;
        }

        public int getWindowSeconds() {
            return windowSeconds;
        }

        public void setWindowSeconds(int windowSeconds) {
            this.windowSeconds = windowSeconds;
        }
    }
}
