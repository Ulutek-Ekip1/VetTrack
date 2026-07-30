package com.vettrack.api.notification;

import com.vettrack.api.notification.dto.DeviceTokenRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Service
public class DeviceTokenService {

    private final DeviceTokenRepository repository;

    public DeviceTokenService(DeviceTokenRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public void registerDevice(UUID ownerId, DeviceTokenRequest request) {
        Optional<DeviceToken> existingTokenOpt = repository.findByFcmToken(request.getFcmToken());
        DeviceToken.Platform platformEnum = parsePlatform(request.getPlatform());

        if (existingTokenOpt.isPresent()) {
            DeviceToken deviceToken = existingTokenOpt.get();
            deviceToken.setOwnerId(ownerId);
            deviceToken.setPlatform(platformEnum);
            deviceToken.setUpdatedAt(Instant.now());
            repository.save(deviceToken);
        } else {
            DeviceToken newToken = new DeviceToken(ownerId, request.getFcmToken(), platformEnum);
            repository.save(newToken);
        }
    }

    @Transactional
    public void unregisterDevice(UUID ownerId, String fcmToken) {
        repository.deleteByOwnerIdAndFcmToken(ownerId, fcmToken);
    }

    @Transactional
    public void unregisterDevice(String fcmToken) {
        repository.deleteByFcmToken(fcmToken);
    }

    @Transactional
    public int cleanStaleTokens(Instant threshold) {
        return repository.deleteByUpdatedAtBefore(threshold);
    }

    private DeviceToken.Platform parsePlatform(String platformStr) {
        if (platformStr == null) return DeviceToken.Platform.ANDROID;
        try {
            return DeviceToken.Platform.valueOf(platformStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            return DeviceToken.Platform.ANDROID;
        }
    }
}