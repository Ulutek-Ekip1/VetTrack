package com.vettrack.api.notification;

import com.vettrack.api.notification.dto.DeviceTokenRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DeviceTokenService {

    private final DeviceTokenRepository repository;

    @Transactional
    public void registerDevice(UUID userId, DeviceTokenRequest request) {
        Optional<DeviceToken> existingTokenOpt = repository.findByFcmToken(request.getFcmToken());
        Platform platformEnum = parsePlatform(request.getPlatform());

        if (existingTokenOpt.isPresent()) {
            DeviceToken deviceToken = existingTokenOpt.get();
            deviceToken.setUserId(userId);
            deviceToken.setPlatform(platformEnum);
            deviceToken.setLastSeen(OffsetDateTime.now());
            repository.save(deviceToken);
        } else {
            DeviceToken newToken = DeviceToken.builder()
                    .userId(userId)
                    .fcmToken(request.getFcmToken())
                    .platform(platformEnum)
                    .build();
            repository.save(newToken);
        }
    }

    @Transactional
    public void unregisterDevice(UUID userId, String fcmToken) {
        repository.deleteByUserIdAndFcmToken(userId, fcmToken);
    }

    @Transactional
    public void unregisterDevice(String fcmToken) {
        repository.deleteByFcmToken(fcmToken);
    }

    @Transactional
    public int cleanStaleTokens(OffsetDateTime threshold) {
        return repository.deleteByLastSeenBefore(threshold);
    }

    private Platform parsePlatform(String platformStr) {
        if (platformStr == null) return Platform.android;
        try {
            return Platform.valueOf(platformStr.toLowerCase());
        } catch (IllegalArgumentException e) {
            return Platform.android;
        }
    }
}