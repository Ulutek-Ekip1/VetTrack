package com.vettrack.api.notification;

import com.google.api.core.ApiFuture;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

/** Sends FCM only after the notification and its related domain change commit. */
@Slf4j
@Component
@RequiredArgsConstructor
public class NotificationPushListener {

    private final NotificationRepository notificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void sendAfterCommit(NotificationPushRequestedEvent event) {
        if (FirebaseApp.getApps().isEmpty()) {
            log.info("Firebase is not configured; notification {} remains available in-app only.", event.notificationId());
            return;
        }

        Notification notification = notificationRepository.findById(event.notificationId()).orElse(null);
        if (notification == null) {
            log.warn("Committed notification {} could not be read for FCM delivery.", event.notificationId());
            return;
        }

        for (DeviceToken token : deviceTokenRepository.findByUserId(notification.getOwnerId())) {
            try {
                ApiFuture<String> delivery = FirebaseMessaging.getInstance()
                        .sendAsync(buildMessage(notification, token));
                delivery.addListener(() -> logDelivery(delivery, notification.getId()), Runnable::run);
            } catch (Exception e) {
                log.error("FCM dispatch could not be started for notification {}: {}",
                        notification.getId(), e.getMessage());
            }
        }
    }

    private Message buildMessage(Notification notification, DeviceToken token) {
        Message.Builder builder = Message.builder()
                .setToken(token.getFcmToken())
                .putData("title", notification.getTitle())
                .putData("body", notification.getBody() == null ? "" : notification.getBody())
                .putData("type", notification.getType().name())
                .putData("notificationId", notification.getId().toString());
        if (notification.getPetId() != null) {
            builder.putData("petId", notification.getPetId().toString());
        }
        if (notification.getVisitId() != null) {
            builder.putData("visitId", notification.getVisitId().toString());
        }
        if (notification.getTreatmentEntryId() != null) {
            builder.putData("treatmentEntryId", notification.getTreatmentEntryId().toString());
        }
        return builder.build();
    }

    private void logDelivery(ApiFuture<String> delivery, java.util.UUID notificationId) {
        try {
            log.info("FCM notification {} delivered with message ID {}", notificationId, delivery.get());
        } catch (Exception e) {
            log.error("FCM delivery failed for notification {}: {}", notificationId, e.getMessage());
        }
    }
}
