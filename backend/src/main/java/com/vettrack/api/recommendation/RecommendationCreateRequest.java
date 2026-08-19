package com.vettrack.api.recommendation;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecommendationCreateRequest {

    private UUID visitId;

    @NotBlank(message = "Tavsiye türü (mama, kum, egzersiz, genel vb.) zorunludur.")
    private String type;

    @NotBlank(message = "Tavsiye açıklaması zorunludur.")
    private String description;

    public static RecommendationCreateRequestBuilder builder() {
        return new RecommendationCreateRequestBuilder();
    }

    public static class RecommendationCreateRequestBuilder {
        private UUID visitId;
        private String type;
        private String description;

        public RecommendationCreateRequestBuilder visitId(UUID visitId) { this.visitId = visitId; return this; }
        public RecommendationCreateRequestBuilder type(String type) { this.type = type; return this; }
        public RecommendationCreateRequestBuilder description(String description) { this.description = description; return this; }

        public RecommendationCreateRequest build() {
            RecommendationCreateRequest r = new RecommendationCreateRequest();
            r.visitId = this.visitId;
            r.type = this.type;
            r.description = this.description;
            return r;
        }
    }

    public UUID getVisitId() { return visitId; }
    public void setVisitId(UUID visitId) { this.visitId = visitId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
