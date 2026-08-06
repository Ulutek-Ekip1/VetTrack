package com.vettrack.api.notification.dto;

import com.vettrack.api.notification.Notification;
import com.vettrack.api.notification.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationResponse {

    private UUID id;
    private NotificationType type;
    private String title;
    private String body;
    private UUID treatmentEntryId;
    private Boolean isRead;
    private OffsetDateTime readAt;
    private OffsetDateTime sentAt;

    public static NotificationResponse fromEntity(Notification n) {
        return NotificationResponse.builder()
                .id(n.getId())
                .type(n.getType())
                .title(n.getTitle())
                .body(n.getBody())
                .treatmentEntryId(n.getTreatmentEntryId())
                .isRead(n.getIsRead())
                .readAt(n.getReadAt())
                .sentAt(n.getSentAt())
                .build();
    }
}
