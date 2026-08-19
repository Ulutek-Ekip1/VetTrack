package com.vettrack.api.notification;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "owner_id", nullable = false)
    private UUID ownerId;

    @Column(name = "treatment_entry_id")
    private UUID treatmentEntryId;

    @Column(name = "pet_id")
    private UUID petId;

    @Column(name = "visit_id")
    private UUID visitId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private NotificationType type;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String body;

    @Column(name = "is_read", nullable = false)
    @Builder.Default
    private Boolean isRead = false;

    @Column(name = "read_at")
    private OffsetDateTime readAt;

    @Column(name = "sent_at", nullable = false, updatable = false)
    private OffsetDateTime sentAt;

    @PrePersist
    protected void onCreate() {
        if (this.sentAt == null) {
            this.sentAt = OffsetDateTime.now();
        }
        if (this.type == null) {
            this.type = NotificationType.SYSTEM;
        }
    }

    public static NotificationBuilder builder() {
        return new NotificationBuilder();
    }

    public static class NotificationBuilder {
        private UUID id;
        private UUID ownerId;
        private UUID treatmentEntryId;
        private UUID petId;
        private UUID visitId;
        private NotificationType type;
        private String title;
        private String body;
        private Boolean isRead = false;
        private OffsetDateTime readAt;
        private OffsetDateTime sentAt;

        public NotificationBuilder id(UUID id) { this.id = id; return this; }
        public NotificationBuilder ownerId(UUID ownerId) { this.ownerId = ownerId; return this; }
        public NotificationBuilder treatmentEntryId(UUID treatmentEntryId) { this.treatmentEntryId = treatmentEntryId; return this; }
        public NotificationBuilder petId(UUID petId) { this.petId = petId; return this; }
        public NotificationBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
        public NotificationBuilder type(NotificationType type) { this.type = type; return this; }
        public NotificationBuilder title(String title) { this.title = title; return this; }
        public NotificationBuilder body(String body) { this.body = body; return this; }
        public NotificationBuilder isRead(Boolean isRead) { this.isRead = isRead; return this; }
        public NotificationBuilder readAt(OffsetDateTime readAt) { this.readAt = readAt; return this; }
        public NotificationBuilder sentAt(OffsetDateTime sentAt) { this.sentAt = sentAt; return this; }

        public Notification build() {
            Notification n = new Notification();
            n.id = this.id;
            n.ownerId = this.ownerId;
            n.treatmentEntryId = this.treatmentEntryId;
            n.petId = this.petId;
            n.visitId = this.visitId;
            n.type = this.type;
            n.title = this.title;
            n.body = this.body;
            n.isRead = this.isRead;
            n.readAt = this.readAt;
            n.sentAt = this.sentAt;
            return n;
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getOwnerId() { return ownerId; }
    public void setOwnerId(UUID ownerId) { this.ownerId = ownerId; }
    public UUID getTreatmentEntryId() { return treatmentEntryId; }
    public void setTreatmentEntryId(UUID treatmentEntryId) { this.treatmentEntryId = treatmentEntryId; }
    public UUID getPetId() { return petId; }
    public void setPetId(UUID petId) { this.petId = petId; }
    public UUID getVisitId() { return visitId; }
    public void setVisitId(UUID visitId) { this.visitId = visitId; }
    public NotificationType getType() { return type; }
    public void setType(NotificationType type) { this.type = type; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
    public Boolean getIsRead() { return isRead; }
    public void setIsRead(Boolean isRead) { this.isRead = isRead; }
    public OffsetDateTime getReadAt() { return readAt; }
    public void setReadAt(OffsetDateTime readAt) { this.readAt = readAt; }
    public OffsetDateTime getSentAt() { return sentAt; }
    public void setSentAt(OffsetDateTime sentAt) { this.sentAt = sentAt; }
}
