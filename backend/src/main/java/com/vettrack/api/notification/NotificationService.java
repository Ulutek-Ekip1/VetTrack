package com.vettrack.api.notification;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.notification.dto.NotificationListResponse;
import com.vettrack.api.notification.dto.NotificationResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;

    @Transactional
    public Notification sendNotificationToOwner(UUID ownerId,
                                                NotificationType type,
                                                String title,
                                                String body,
                                                UUID treatmentEntryId) {
        // 1. Veritabanına bildirimi kaydet
        Notification notification = Notification.builder()
                .ownerId(ownerId)
                .type(type != null ? type : NotificationType.SYSTEM)
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

        List<DeviceToken> deviceTokens = deviceTokenRepository.findByUserId(ownerId);
        for (DeviceToken deviceToken : deviceTokens) {
            try {
                Message message = Message.builder()
                        .setToken(deviceToken.getFcmToken())
                        .putData("title", title)
                        .putData("body", body)
                        .putData("type", savedNotification.getType().name())
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

    @Transactional
    public Notification sendVisitClosedNotification(UUID ownerId, UUID petId, UUID visitId) {
        Notification savedNotification = notificationRepository.save(Notification.builder()
                .ownerId(ownerId).petId(petId).visitId(visitId).type(NotificationType.VISIT)
                .title("Muayene tamamlandı")
                .body("Evcil hayvanınızın muayenesi tamamlandı. Tedavi ve önerileri görüntüleyebilirsiniz.")
                .isRead(false).build());

        if (FirebaseApp.getApps().isEmpty()) return savedNotification;
        for (DeviceToken token : deviceTokenRepository.findByUserId(ownerId)) {
            try {
                FirebaseMessaging.getInstance().sendAsync(Message.builder().setToken(token.getFcmToken())
                        .putData("title", savedNotification.getTitle()).putData("body", savedNotification.getBody())
                        .putData("type", savedNotification.getType().name())
                        .putData("notificationId", savedNotification.getId().toString())
                        .putData("petId", petId.toString()).putData("visitId", visitId.toString()).build());
            } catch (Exception e) { log.error("FCM visit notification failed: {}", e.getMessage()); }
        }
        return savedNotification;
    }

    @Transactional(readOnly = true)
    public NotificationListResponse getOwnerNotifications(UUID ownerId) {
        List<NotificationResponse> notifications = notificationRepository
                .findByOwnerIdOrderBySentAtDesc(ownerId)
                .stream()
                .map(NotificationResponse::fromEntity)
                .toList();

        long unreadCount = notificationRepository.countByOwnerIdAndIsReadFalse(ownerId);

        return NotificationListResponse.builder()
                .notifications(notifications)
                .unreadCount(unreadCount)
                .build();
    }

    @Transactional(readOnly = true)
    public long getUnreadCount(UUID ownerId) {
        return notificationRepository.countByOwnerIdAndIsReadFalse(ownerId);
    }

    @Transactional
    public void markAsRead(UUID notificationId, UUID ownerId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new ResourceNotFoundException("Bildirim bulunamadı: " + notificationId));

        if (!notification.getOwnerId().equals(ownerId)) {
            throw new ResourceNotFoundException("Bildirim bulunamadı veya erişim yetkiniz yok.");
        }

        if (Boolean.FALSE.equals(notification.getIsRead())) {
            notification.setIsRead(true);
            notification.setReadAt(OffsetDateTime.now());
            notificationRepository.save(notification);
        }
    }

    @Transactional
    public int markAllAsRead(UUID ownerId) {
        List<Notification> unread = notificationRepository.findByOwnerIdAndIsReadFalse(ownerId);
        OffsetDateTime now = OffsetDateTime.now();
        for (Notification n : unread) {
            n.setIsRead(true);
            n.setReadAt(now);
        }
        notificationRepository.saveAll(unread);
        return unread.size();
    }
}
