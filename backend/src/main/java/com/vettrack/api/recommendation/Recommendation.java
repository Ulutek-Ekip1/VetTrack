package com.vettrack.api.recommendation;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "recommendations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Recommendation {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "visit_id", nullable = false)
    private UUID visitId;

    @Column(nullable = false, length = 20)
    private String type;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "created_by")
    private UUID createdBy;

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

    public static RecommendationBuilder builder() {
        return new RecommendationBuilder();
    }

    public static class RecommendationBuilder {
        private UUID id;
        private UUID visitId;
        private String type;
        private String description;
        private UUID createdBy;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public RecommendationBuilder id(UUID id) { this.id = id; return this; }
        public RecommendationBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
        public RecommendationBuilder type(String type) { this.type = type; return this; }
        public RecommendationBuilder description(String description) { this.description = description; return this; }
        public RecommendationBuilder createdBy(UUID createdBy) { this.createdBy = createdBy; return this; }
        public RecommendationBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public RecommendationBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public Recommendation build() {
            Recommendation r = new Recommendation();
            r.id = this.id;
            r.visitId = this.visitId;
            r.type = this.type;
            r.description = this.description;
            r.createdBy = this.createdBy;
            r.createdAt = this.createdAt;
            r.updatedAt = this.updatedAt;
            return r;
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getVisitId() { return visitId; }
    public void setVisitId(UUID visitId) { this.visitId = visitId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public UUID getCreatedBy() { return createdBy; }
    public void setCreatedBy(UUID createdBy) { this.createdBy = createdBy; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }
}