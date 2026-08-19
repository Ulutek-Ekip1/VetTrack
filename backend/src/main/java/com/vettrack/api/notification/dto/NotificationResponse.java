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
    private UUID petId;
    private UUID visitId;
    private Boolean isRead;
    private OffsetDateTime readAt;
    private OffsetDateTime sentAt;

    public static NotificationResponseBuilder builder() {
        return new NotificationResponseBuilder();
    }

    public static class NotificationResponseBuilder {
        private UUID id;
        private NotificationType type;
        private String title;
        private String body;
        private UUID treatmentEntryId;
        private UUID petId;
        private UUID visitId;
        private Boolean isRead;
        private OffsetDateTime readAt;
        private OffsetDateTime sentAt;

        public NotificationResponseBuilder id(UUID id) { this.id = id; return this; }
        public NotificationResponseBuilder type(NotificationType type) { this.type = type; return this; }
        public NotificationResponseBuilder title(String title) { this.title = title; return this; }
        public NotificationResponseBuilder body(String body) { this.body = body; return this; }
        public NotificationResponseBuilder treatmentEntryId(UUID treatmentEntryId) { this.treatmentEntryId = treatmentEntryId; return this; }
        public NotificationResponseBuilder petId(UUID petId) { this.petId = petId; return this; }
        public NotificationResponseBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
        public NotificationResponseBuilder isRead(Boolean isRead) { this.isRead = isRead; return this; }
        public NotificationResponseBuilder readAt(OffsetDateTime readAt) { this.readAt = readAt; return this; }
        public NotificationResponseBuilder sentAt(OffsetDateTime sentAt) { this.sentAt = sentAt; return this; }

        public NotificationResponse build() {
            NotificationResponse r = new NotificationResponse();
            r.id = this.id;
            r.type = this.type;
            r.title = this.title;
            r.body = this.body;
            r.treatmentEntryId = this.treatmentEntryId;
            r.petId = this.petId;
            r.visitId = this.visitId;
            r.isRead = this.isRead;
            r.readAt = this.readAt;
            r.sentAt = this.sentAt;
            return r;
        }
    }

    public UUID getId() { return id; }
    public NotificationType getType() { return type; }
    public String getTitle() { return title; }
    public String getBody() { return body; }
    public UUID getTreatmentEntryId() { return treatmentEntryId; }
    public UUID getPetId() { return petId; }
    public UUID getVisitId() { return visitId; }
    public Boolean getIsRead() { return isRead; }
    public OffsetDateTime getReadAt() { return readAt; }
    public OffsetDateTime getSentAt() { return sentAt; }

    public static NotificationResponse fromEntity(Notification n) {
        return NotificationResponse.builder()
                .id(n.getId())
                .type(n.getType())
                .title(n.getTitle())
                .body(n.getBody())
                .treatmentEntryId(n.getTreatmentEntryId())
                .petId(n.getPetId())
                .visitId(n.getVisitId())
                .isRead(n.getIsRead())
                .readAt(n.getReadAt())
                .sentAt(n.getSentAt())
                .build();
    }
}
