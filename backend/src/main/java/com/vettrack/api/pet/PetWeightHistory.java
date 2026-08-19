package com.vettrack.api.pet;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "pet_weight_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PetWeightHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "pet_id", nullable = false)
    private UUID petId;

    @Column(nullable = false)
    private Double weight;

    @Column(name = "recorded_at", nullable = false)
    private OffsetDateTime recordedAt;

    @Column(name = "recorded_by")
    private UUID recordedBy;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = OffsetDateTime.now();
        }
        if (this.recordedAt == null) {
            this.recordedAt = OffsetDateTime.now();
        }
    }

    public static PetWeightHistoryBuilder builder() {
        return new PetWeightHistoryBuilder();
    }

    public static class PetWeightHistoryBuilder {
        private UUID id;
        private UUID petId;
        private Double weight;
        private OffsetDateTime recordedAt;
        private UUID recordedBy;
        private OffsetDateTime createdAt;

        public PetWeightHistoryBuilder id(UUID id) { this.id = id; return this; }
        public PetWeightHistoryBuilder petId(UUID petId) { this.petId = petId; return this; }
        public PetWeightHistoryBuilder weight(Double weight) { this.weight = weight; return this; }
        public PetWeightHistoryBuilder recordedAt(OffsetDateTime recordedAt) { this.recordedAt = recordedAt; return this; }
        public PetWeightHistoryBuilder recordedBy(UUID recordedBy) { this.recordedBy = recordedBy; return this; }
        public PetWeightHistoryBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }

        public PetWeightHistory build() {
            PetWeightHistory p = new PetWeightHistory();
            p.id = this.id;
            p.petId = this.petId;
            p.weight = this.weight;
            p.recordedAt = this.recordedAt;
            p.recordedBy = this.recordedBy;
            p.createdAt = this.createdAt;
            return p;
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getPetId() { return petId; }
    public void setPetId(UUID petId) { this.petId = petId; }
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }
    public OffsetDateTime getRecordedAt() { return recordedAt; }
    public void setRecordedAt(OffsetDateTime recordedAt) { this.recordedAt = recordedAt; }
    public UUID getRecordedBy() { return recordedBy; }
    public void setRecordedBy(UUID recordedBy) { this.recordedBy = recordedBy; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
