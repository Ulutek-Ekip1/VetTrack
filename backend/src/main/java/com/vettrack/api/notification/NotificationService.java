package com.vettrack.api.notification;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MessagingErrorCode;
import com.google.firebase.messaging.Message;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.notification.dto.NotificationListResponse;
import com.vettrack.api.notification.dto.NotificationResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private static final int MAX_SEND_ATTEMPTS = 3;
    private static final long RETRY_BASE_DELAY_MS = 500;

    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public Notification sendNotificationToOwner(UUID ownerId,
                                                NotificationType type,
                                                String title,
                                                String body,
                                                UUID treatmentEntryId) {
        Notification notification = Notification.builder()
                .ownerId(ownerId)
                .type(type != null ? type : NotificationType.SYSTEM)
                .title(title)
                .body(body)
                .treatmentEntryId(treatmentEntryId)
                .isRead(false)
                .build();
        Notification savedNotification = notificationRepository.save(notification);

        eventPublisher.publishEvent(new NotificationCreatedEvent(savedNotification.getId(), ownerId));

        return savedNotification;
    }

    @Transactional
    public Notification sendVisitClosedNotification(UUID ownerId, UUID petId, UUID visitId) {
        Notification savedNotification = notificationRepository.save(Notification.builder()
                .ownerId(ownerId).petId(petId).visitId(visitId).type(NotificationType.VISIT)
                .title("Muayene tamamlandı")
                .body("Evcil hayvanınızın muayenesi tamamlandı. Tedavi ve önerileri görüntüleyebilirsiniz.")
                .isRead(false).build());

        eventPublisher.publishEvent(new NotificationCreatedEvent(savedNotification.getId(), ownerId));

        return savedNotification;
    }

    /**
     * Notification kaydını oluşturan transaction commit olduktan SONRA çalışır
     * (AFTER_COMMIT) — böylece transaction rollback olursa hiç push gitmemiş
     * olur, ya da DB satırı hiç yokken push atılmış olmaz.
     */
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void onNotificationCreated(NotificationCreatedEvent event) {
        if (FirebaseApp.getApps().isEmpty()) {
            return;
        }

        Notification notification = notificationRepository.findById(event.getNotificationId()).orElse(null);
        if (notification == null) {
            log.warn("Bildirim gönderim event'i tetiklendi ama kayıt bulunamadı: {}", event.getNotificationId());
            return;
        }

        List<DeviceToken> deviceTokens = deviceTokenRepository.findByUserId(event.getOwnerId());
        for (DeviceToken deviceToken : deviceTokens) {
            sendWithRetry(deviceToken, notification);
        }
    }

    private void sendWithRetry(DeviceToken deviceToken, Notification notification) {
        Message.Builder messageBuilder = Message.builder()
                .setToken(deviceToken.getFcmToken())
                .putData("title", notification.getTitle())
                .putData("body", notification.getBody())
                .putData("type", notification.getType().name())
                .putData("notificationId", notification.getId().toString());
        if (notification.getPetId() != null) {
            messageBuilder.putData("petId", notification.getPetId().toString());
        }
        if (notification.getVisitId() != null) {
            messageBuilder.putData("visitId", notification.getVisitId().toString());
        }
        Message message = messageBuilder.build();

        for (int attempt = 1; attempt <= MAX_SEND_ATTEMPTS; attempt++) {
            try {
                FirebaseMessaging.getInstance().send(message);
                log.info("FCM bildirimi gönderildi (deneme {}). Token: {}", attempt, deviceToken.getFcmToken());
                return;
            } catch (FirebaseMessagingException e) {
                MessagingErrorCode errorCode = e.getMessagingErrorCode();

                if (errorCode == MessagingErrorCode.UNREGISTERED) {
                    log.warn("Geçersiz FCM token, siliniyor. Token: {}, hata: {}", deviceToken.getFcmToken(), errorCode);
                    deviceTokenRepository.delete(deviceToken);
                    return;
                }

                if (errorCode == MessagingErrorCode.INVALID_ARGUMENT) {
                    // Token'a özel değil — bozuk payload, aşırı büyük alan vb. istek
                    // seviyesindeki sebeplerden de gelebilir. Token'ı silmek burada
                    // yanlış olur: aynı payload sorunu tüm kullanıcılar için aynı hatayı
                    // üretebilir ve geçerli tüm token'lar kalıcı olarak silinebilir.
                    log.error("FCM isteği reddedildi (INVALID_ARGUMENT), token silinmedi. Token: {}, hata: {}",
                            deviceToken.getFcmToken(), e.getMessage());
                    return;
                }

                boolean retryable = errorCode == MessagingErrorCode.INTERNAL
                        || errorCode == MessagingErrorCode.UNAVAILABLE
                        || errorCode == MessagingErrorCode.QUOTA_EXCEEDED;

                if (!retryable || attempt == MAX_SEND_ATTEMPTS) {
                    log.error("FCM bildirim gönderim hatası (Token: {}, deneme: {}, hata: {}): {}",
                            deviceToken.getFcmToken(), attempt, errorCode, e.getMessage());
                    return;
                }

                long backoffMs = RETRY_BASE_DELAY_MS * (1L << (attempt - 1));
                log.warn("FCM gönderim hatası, {} ms sonra tekrar denenecek (deneme {}/{}, hata: {})",
                        backoffMs, attempt, MAX_SEND_ATTEMPTS, errorCode);
                try {
                    Thread.sleep(backoffMs);
                } catch (InterruptedException interruptedException) {
                    Thread.currentThread().interrupt();
                    return;
                }
            } catch (Exception e) {
                log.error("FCM bildirim gönderim hatası (Token: {}): {}", deviceToken.getFcmToken(), e.getMessage());
                return;
            }
        }
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
