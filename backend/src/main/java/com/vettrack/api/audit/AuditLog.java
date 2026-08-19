package com.vettrack.api.audit;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "audit_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "entity_name", nullable = false, length = 100)
    private String entityName;

    @Column(name = "entity_id", nullable = false)
    private UUID entityId;

    @Column(nullable = false, length = 50)
    private String action; // Örn: "UPDATE", "DELETE"

    @Column(name = "changed_by")
    private UUID changedBy;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(columnDefinition = "TEXT")
    private String details;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = OffsetDateTime.now();
        }
    }

    public static AuditLogBuilder builder() {
        return new AuditLogBuilder();
    }

    public static class AuditLogBuilder {
        private UUID id;
        private String entityName;
        private UUID entityId;
        private String action;
        private UUID changedBy;
        private OffsetDateTime createdAt;
        private String details;

        public AuditLogBuilder id(UUID id) { this.id = id; return this; }
        public AuditLogBuilder entityName(String entityName) { this.entityName = entityName; return this; }
        public AuditLogBuilder entityId(UUID entityId) { this.entityId = entityId; return this; }
        public AuditLogBuilder action(String action) { this.action = action; return this; }
        public AuditLogBuilder changedBy(UUID changedBy) { this.changedBy = changedBy; return this; }
        public AuditLogBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public AuditLogBuilder details(String details) { this.details = details; return this; }

        public AuditLog build() {
            AuditLog a = new AuditLog();
            a.id = this.id;
            a.entityName = this.entityName;
            a.entityId = this.entityId;
            a.action = this.action;
            a.changedBy = this.changedBy;
            a.createdAt = this.createdAt;
            a.details = this.details;
            return a;
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getEntityName() { return entityName; }
    public void setEntityName(String entityName) { this.entityName = entityName; }
    public UUID getEntityId() { return entityId; }
    public void setEntityId(UUID entityId) { this.entityId = entityId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public UUID getChangedBy() { return changedBy; }
    public void setChangedBy(UUID changedBy) { this.changedBy = changedBy; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public String getDetails() { return details; }
    public void setDetails(String details) { this.details = details; }
}