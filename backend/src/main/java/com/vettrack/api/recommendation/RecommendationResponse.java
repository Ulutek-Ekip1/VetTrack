package com.vettrack.api.recommendation;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationResponse {
    private UUID id;
    private UUID visitId;
    private String type;
    private String description;
    private UUID createdBy;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public static RecommendationResponseBuilder builder() {
        return new RecommendationResponseBuilder();
    }

    public static class RecommendationResponseBuilder {
        private UUID id;
        private UUID visitId;
        private String type;
        private String description;
        private UUID createdBy;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public RecommendationResponseBuilder id(UUID id) { this.id = id; return this; }
        public RecommendationResponseBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
        public RecommendationResponseBuilder type(String type) { this.type = type; return this; }
        public RecommendationResponseBuilder description(String description) { this.description = description; return this; }
        public RecommendationResponseBuilder createdBy(UUID createdBy) { this.createdBy = createdBy; return this; }
        public RecommendationResponseBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public RecommendationResponseBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public RecommendationResponse build() {
            RecommendationResponse r = new RecommendationResponse();
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