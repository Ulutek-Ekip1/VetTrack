package com.vettrack.api.clinic;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "clinic_memberships")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClinicMembership {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private UUID clinicId;

    @Column(nullable = false)
    private String role; // 'doctor', 'staff'

    @Column(nullable = false)
    private Boolean isClinicAdmin = false;

    @Column(nullable = false)
    private String status = "active"; // 'invited', 'active', 'disabled'

    private OffsetDateTime joinedAt;

    @CreationTimestamp
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    private OffsetDateTime updatedAt;

    public UUID getId() {
        return id;
    }

    public UUID getUserId() {
        return userId;
    }

    public UUID getClinicId() {
        return clinicId;
    }

    public String getRole() {
        return role;
    }

    public Boolean getIsClinicAdmin() {
        return isClinicAdmin;
    }

    public String getStatus() {
        return status;
    }

    public OffsetDateTime getJoinedAt() {
        return joinedAt;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public void setUserId(UUID userId) {
        this.userId = userId;
    }

    public void setClinicId(UUID clinicId) {
        this.clinicId = clinicId;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setIsClinicAdmin(Boolean isClinicAdmin) {
        this.isClinicAdmin = isClinicAdmin;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setJoinedAt(OffsetDateTime joinedAt) {
        this.joinedAt = joinedAt;
    }

    public static ClinicMembershipBuilder builder() {
        return new ClinicMembershipBuilder();
    }

    public static class ClinicMembershipBuilder {
        private UUID id;
        private UUID userId;
        private UUID clinicId;
        private String role;
        private Boolean isClinicAdmin = false;
        private String status = "active";
        private OffsetDateTime joinedAt;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public ClinicMembershipBuilder id(UUID id) { this.id = id; return this; }
        public ClinicMembershipBuilder userId(UUID userId) { this.userId = userId; return this; }
        public ClinicMembershipBuilder clinicId(UUID clinicId) { this.clinicId = clinicId; return this; }
        public ClinicMembershipBuilder role(String role) { this.role = role; return this; }
        public ClinicMembershipBuilder isClinicAdmin(Boolean isClinicAdmin) { this.isClinicAdmin = isClinicAdmin; return this; }
        public ClinicMembershipBuilder status(String status) { this.status = status; return this; }
        public ClinicMembershipBuilder joinedAt(OffsetDateTime joinedAt) { this.joinedAt = joinedAt; return this; }
        public ClinicMembershipBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public ClinicMembershipBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public ClinicMembership build() {
            ClinicMembership c = new ClinicMembership();
            c.id = this.id;
            c.userId = this.userId;
            c.clinicId = this.clinicId;
            c.role = this.role;
            c.isClinicAdmin = this.isClinicAdmin;
            c.status = this.status;
            c.joinedAt = this.joinedAt;
            c.createdAt = this.createdAt;
            c.updatedAt = this.updatedAt;
            return c;
        }
    }
}
