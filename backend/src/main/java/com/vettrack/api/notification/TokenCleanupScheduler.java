package com.vettrack.api.notification;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.OffsetDateTime;

@Component
public class TokenCleanupScheduler {

    private final DeviceTokenService service;

    public TokenCleanupScheduler(DeviceTokenService service) {
        this.service = service;
    }

    // Runs every day at 03:00 AM
    @Scheduled(cron = "0 0 3 * * ?")
    public void removeExpiredTokens() {
        OffsetDateTime threshold = OffsetDateTime.now().minusDays(60);
        service.cleanStaleTokens(threshold);
    }
}