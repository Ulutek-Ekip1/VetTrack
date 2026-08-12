package com.vettrack.api.notification;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.context.ApplicationEventPublisher;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock private NotificationRepository notificationRepository;
    @Mock private ApplicationEventPublisher eventPublisher;
    @InjectMocks private NotificationService notificationService;

    @Test
    void visitClosePersistsNotificationAndPublishesPushRequestForAfterCommitDelivery() {
        UUID notificationId = UUID.randomUUID();
        Notification persisted = Notification.builder()
                .id(notificationId)
                .ownerId(UUID.randomUUID())
                .type(NotificationType.VISIT)
                .title("Muayene tamamlandı")
                .isRead(false)
                .build();
        when(notificationRepository.save(any(Notification.class))).thenReturn(persisted);

        notificationService.sendVisitClosedNotification(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID());

        ArgumentCaptor<NotificationPushRequestedEvent> event =
                ArgumentCaptor.forClass(NotificationPushRequestedEvent.class);
        verify(eventPublisher).publishEvent(event.capture());
        assertThat(event.getValue().notificationId()).isEqualTo(notificationId);
    }
}
