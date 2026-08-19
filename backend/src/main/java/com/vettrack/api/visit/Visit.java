package com.vettrack.api.visit;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "visits")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Visit {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "pet_id", nullable = false)
    private UUID petId;

    @Column(name = "vet_staff_id")
    private UUID vetStaffId;

    @Column(name = "clinic_id")
    private UUID clinicId;

    @Column(nullable = false, length = 20)
    @Builder.Default
    private String status = "ongoing";

    @Column(name = "chief_complaint", columnDefinition = "TEXT")
    private String chiefComplaint;

    @Column(name = "started_at")
    private OffsetDateTime startedAt;

    @Column(name = "ended_at")
    private OffsetDateTime endedAt;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) this.createdAt = OffsetDateTime.now();
        if (this.startedAt == null) this.startedAt = OffsetDateTime.now();
        this.updatedAt = OffsetDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }

    public UUID getId() {
        return id;
    }

    public UUID getPetId() {
        return petId;
    }

    public UUID getVetStaffId() {
        return vetStaffId;
    }

    public UUID getClinicId() {
        return clinicId;
    }

    public String getStatus() {
        return status;
    }

    public String getChiefComplaint() {
        return chiefComplaint;
    }

    public OffsetDateTime getStartedAt() {
        return startedAt;
    }

    public OffsetDateTime getEndedAt() {
        return endedAt;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setStatus(String status) { this.status = status; }
    public void setEndedAt(OffsetDateTime endedAt) { this.endedAt = endedAt; }
    public void setStartedAt(OffsetDateTime startedAt) { this.startedAt = startedAt; }
    public void setChiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; }
    public void setClinicId(UUID clinicId) { this.clinicId = clinicId; }
    public void setVetStaffId(UUID vetStaffId) { this.vetStaffId = vetStaffId; }
    public void setPetId(UUID petId) { this.petId = petId; }
    public void setId(UUID id) { this.id = id; }

    public static VisitBuilder builder() {
        return new VisitBuilder();
    }

    public static class VisitBuilder {
        private UUID id;
        private UUID petId;
        private UUID vetStaffId;
        private UUID clinicId;
        private String status = "in_progress";
        private String chiefComplaint;
        private OffsetDateTime startedAt;
        private OffsetDateTime endedAt;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public VisitBuilder id(UUID id) { this.id = id; return this; }
        public VisitBuilder petId(UUID petId) { this.petId = petId; return this; }
        public VisitBuilder vetStaffId(UUID vetStaffId) { this.vetStaffId = vetStaffId; return this; }
        public VisitBuilder clinicId(UUID clinicId) { this.clinicId = clinicId; return this; }
        public VisitBuilder status(String status) { this.status = status; return this; }
        public VisitBuilder chiefComplaint(String chiefComplaint) { this.chiefComplaint = chiefComplaint; return this; }
        public VisitBuilder startedAt(OffsetDateTime startedAt) { this.startedAt = startedAt; return this; }
        public VisitBuilder endedAt(OffsetDateTime endedAt) { this.endedAt = endedAt; return this; }
        public VisitBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public VisitBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public Visit build() {
            Visit v = new Visit();
            v.id = this.id;
            v.petId = this.petId;
            v.vetStaffId = this.vetStaffId;
            v.clinicId = this.clinicId;
            v.status = this.status;
            v.chiefComplaint = this.chiefComplaint;
            v.startedAt = this.startedAt;
            v.endedAt = this.endedAt;
            v.createdAt = this.createdAt;
            v.updatedAt = this.updatedAt;
            return v;
        }
    }
}
