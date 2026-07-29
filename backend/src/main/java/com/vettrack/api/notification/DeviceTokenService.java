package com.vettrack.api.notification;

import com.vettrack.api.notification.dto.DeviceTokenRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.OffsetDateTime;
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

        if (existingTokenOpt.isPresent()) {
            DeviceToken deviceToken = existingTokenOpt.get();
            
            // Eğer token zaten bu sahibe aitse sadece son erişim tarihini güncelle
            if (deviceToken.getOwnerId().equals(ownerId)) {
                deviceToken.setCreatedAt(OffsetDateTime.now());
            } else {
                // Token başka bir kullanıcıya aitse (cihaz el değiştirdiyse veya farklı biri girdi yaptıysa)
                // Yetkisiz bildirim gönderimini engellemek için sahipliği güvenle güncelle.
                deviceToken.setOwnerId(ownerId);
                deviceToken.setPlatform(request.getPlatform());
                deviceToken.setCreatedAt(OffsetDateTime.now());
            }
            repository.save(deviceToken);
        } else {
            // Tamamen yeni bir token kaydı oluştur
            DeviceToken newToken = new DeviceToken(ownerId, request.getFcmToken(), request.getPlatform());
            repository.save(newToken);
        }
    }

    @Transactional
    public void unregisterDevice(String fcmToken) {
        repository.deleteByFcmToken(fcmToken);
    }

    @Transactional
    public int cleanStaleTokens(OffsetDateTime threshold) {
        return repository.deleteByCreatedAtBefore(threshold);
    }
}