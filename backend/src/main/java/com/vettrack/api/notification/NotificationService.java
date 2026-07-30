package com.vettrack.api.notification;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;

    @Transactional
    public Notification sendNotificationToOwner(UUID ownerId, String title, String body, UUID treatmentEntryId) {
        // 1. Veritabanına bildirimi kaydet
        Notification notification = Notification.builder()
                .ownerId(ownerId)
                .title(title)
                .body(body)
                .treatmentEntryId(treatmentEntryId)
                .isRead(false)
                .build();
        Notification savedNotification = notificationRepository.save(notification);

        // 2. Firebase initialized ise FCM token'larına Push bildirim gönder
        if (FirebaseApp.getApps().isEmpty()) {
            log.info("Firebase henüz yapılandırılmadığı için sadece DB bildirimi kaydedildi. (Owner ID: {})", ownerId);
            return savedNotification;
        }

        List<DeviceToken> deviceTokens = deviceTokenRepository.findByOwnerId(ownerId);
        for (DeviceToken deviceToken : deviceTokens) {
            try {
                Message message = Message.builder()
                        .setToken(deviceToken.getFcmToken())
                        .putData("title", title)
                        .putData("body", body)
                        .putData("notificationId", savedNotification.getId().toString())
                        .build();

                FirebaseMessaging.getInstance().sendAsync(message);
                log.info("FCM bildirimi gönderildi. Token: {}", deviceToken.getFcmToken());
            } catch (Exception e) {
                log.error("FCM bildirim gönderim hatası (Token: {}): {}", deviceToken.getFcmToken(), e.getMessage());
            }
        }

        return savedNotification;
    }

    @Transactional(readOnly = true)
    public List<Notification> getOwnerNotifications(UUID ownerId) {
        return notificationRepository.findByOwnerIdOrderBySentAtDesc(ownerId);
    }

    @Transactional
    public void markAsRead(UUID notificationId, UUID ownerId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Bildirim bulunamadı: " + notificationId));

        if (!notification.getOwnerId().equals(ownerId)) {
            throw new ResourceNotFoundException("Bildirim bulunamadı veya erişim yetkiniz yok.");
        }

        notification.setIsRead(true);
        notificationRepository.save(notification);
    }
}
