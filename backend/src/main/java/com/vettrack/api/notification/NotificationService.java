package com.vettrack.api.notification;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.notification.dto.NotificationListResponse;
import com.vettrack.api.notification.dto.NotificationResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final ApplicationEventPublisher eventPublisher;

    @Transactional
    public Notification sendNotificationToOwner(UUID ownerId,
                                                NotificationType type,
                                                String title,
                                                String body,
                                                UUID treatmentEntryId) {
        Notification savedNotification = notificationRepository.save(Notification.builder()
                .ownerId(ownerId)
                .type(type != null ? type : NotificationType.SYSTEM)
                .title(title)
                .body(body)
                .treatmentEntryId(treatmentEntryId)
                .isRead(false)
                .build());

        eventPublisher.publishEvent(new NotificationPushRequestedEvent(savedNotification.getId()));
        return savedNotification;
    }

    @Transactional
    public Notification sendVisitClosedNotification(UUID ownerId, UUID petId, UUID visitId) {
        Notification savedNotification = notificationRepository.save(Notification.builder()
                .ownerId(ownerId)
                .petId(petId)
                .visitId(visitId)
                .type(NotificationType.VISIT)
                .title("Muayene tamamlandı")
                .body("Evcil hayvanınızın muayenesi tamamlandı. Tedavi ve önerileri görüntüleyebilirsiniz.")
                .isRead(false)
                .build());

        eventPublisher.publishEvent(new NotificationPushRequestedEvent(savedNotification.getId()));
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
