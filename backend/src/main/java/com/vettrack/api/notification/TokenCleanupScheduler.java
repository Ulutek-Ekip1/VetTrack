package com.vettrack.api.notification;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Component
public class TokenCleanupScheduler {

    private final DeviceTokenService service;

    public TokenCleanupScheduler(DeviceTokenService service) {
        this.service = service;
    }

    // Runs every day at 03:00 AM
    @Scheduled(cron = "0 0 3 * * ?")
    public void removeExpiredTokens() {
        Instant threshold = Instant.now().minus(60, ChronoUnit.DAYS);
        service.cleanStaleTokens(threshold);
    }
}