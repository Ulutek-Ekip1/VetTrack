package com.vettrack.api.treatment;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "treatment_entries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TreatmentEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "visit_id", nullable = false)
    private UUID visitId;

    @Column(name = "type", nullable = false)
    private String type;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    @Builder.Default
    private TreatmentStatus status = TreatmentStatus.PLANNED;

    @Column(name = "start_date")
    private OffsetDateTime startDate;

    @Column(name = "end_date")
    private OffsetDateTime endDate;

    @Column(name = "attachment_url", columnDefinition = "TEXT")
    private String attachmentUrl;

    @Column(name = "entered_by")
    private UUID enteredBy;

    @Column(name = "is_editable")
    @Builder.Default
    private Boolean isEditable = true;

    @Column(name = "notification_sent")
    @Builder.Default
    private Boolean notificationSent = false;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) this.createdAt = OffsetDateTime.now();
        this.updatedAt = OffsetDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }

    public UUID getId() {
        return id;
    }

    public UUID getVisitId() {
        return visitId;
    }

    public String getType() {
        return type;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public TreatmentStatus getStatus() {
        return status;
    }

    public OffsetDateTime getStartDate() {
        return startDate;
    }

    public OffsetDateTime getEndDate() {
        return endDate;
    }

    public String getAttachmentUrl() {
        return attachmentUrl;
    }

    public UUID getEnteredBy() {
        return enteredBy;
    }

    public Boolean getIsEditable() {
        return isEditable;
    }

    public Boolean getNotificationSent() {
        return notificationSent;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setId(UUID id) { this.id = id; }
    public void setVisitId(UUID visitId) { this.visitId = visitId; }
    public void setType(String type) { this.type = type; }
    public void setTitle(String title) { this.title = title; }
    public void setDescription(String description) { this.description = description; }
    public void setStatus(TreatmentStatus status) { this.status = status; }
    public void setStartDate(OffsetDateTime startDate) { this.startDate = startDate; }
    public void setEndDate(OffsetDateTime endDate) { this.endDate = endDate; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }
    public void setEnteredBy(UUID enteredBy) { this.enteredBy = enteredBy; }
    public void setIsEditable(Boolean isEditable) { this.isEditable = isEditable; }
    public void setNotificationSent(Boolean notificationSent) { this.notificationSent = notificationSent; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }

    public static TreatmentEntryBuilder builder() {
        return new TreatmentEntryBuilder();
    }

    public static class TreatmentEntryBuilder {
        private UUID id;
        private UUID visitId;
        private String type;
        private String title;
        private String description;
        private TreatmentStatus status = TreatmentStatus.PLANNED;
        private OffsetDateTime startDate;
        private OffsetDateTime endDate;
        private String attachmentUrl;
        private UUID enteredBy;
        private Boolean isEditable = true;
        private Boolean notificationSent = false;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public TreatmentEntryBuilder id(UUID id) { this.id = id; return this; }
        public TreatmentEntryBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
        public TreatmentEntryBuilder type(String type) { this.type = type; return this; }
        public TreatmentEntryBuilder title(String title) { this.title = title; return this; }
        public TreatmentEntryBuilder description(String description) { this.description = description; return this; }
        public TreatmentEntryBuilder status(TreatmentStatus status) { this.status = status; return this; }
        public TreatmentEntryBuilder startDate(OffsetDateTime startDate) { this.startDate = startDate; return this; }
        public TreatmentEntryBuilder endDate(OffsetDateTime endDate) { this.endDate = endDate; return this; }
        public TreatmentEntryBuilder attachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; return this; }
        public TreatmentEntryBuilder enteredBy(UUID enteredBy) { this.enteredBy = enteredBy; return this; }
        public TreatmentEntryBuilder isEditable(Boolean isEditable) { this.isEditable = isEditable; return this; }
        public TreatmentEntryBuilder notificationSent(Boolean notificationSent) { this.notificationSent = notificationSent; return this; }
        public TreatmentEntryBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public TreatmentEntryBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public TreatmentEntry build() {
            TreatmentEntry t = new TreatmentEntry();
            t.id = this.id;
            t.visitId = this.visitId;
            t.type = this.type;
            t.title = this.title;
            t.description = this.description;
            t.status = this.status;
            t.startDate = this.startDate;
            t.endDate = this.endDate;
            t.attachmentUrl = this.attachmentUrl;
            t.enteredBy = this.enteredBy;
            t.isEditable = this.isEditable;
            t.notificationSent = this.notificationSent;
            t.createdAt = this.createdAt;
            t.updatedAt = this.updatedAt;
            return t;
        }
    }
}
