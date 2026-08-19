package com.vettrack.api.clinic;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "clinic_invites")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClinicInvite {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID clinicId;

    private String email;

    @Column(nullable = false, unique = true, length = 64)
    private String tokenHash;

    @Column(nullable = false)
    private OffsetDateTime expiresAt;

    private OffsetDateTime acceptedAt;

    private OffsetDateTime revokedAt;

    @Column(nullable = false)
    private UUID createdBy;

    @CreationTimestamp
    private OffsetDateTime createdAt;

    public static ClinicInviteBuilder builder() {
        return new ClinicInviteBuilder();
    }

    public static class ClinicInviteBuilder {
        private UUID id;
        private UUID clinicId;
        private String email;
        private String tokenHash;
        private OffsetDateTime expiresAt;
        private OffsetDateTime acceptedAt;
        private OffsetDateTime revokedAt;
        private UUID createdBy;
        private OffsetDateTime createdAt;

        public ClinicInviteBuilder id(UUID id) { this.id = id; return this; }
        public ClinicInviteBuilder clinicId(UUID clinicId) { this.clinicId = clinicId; return this; }
        public ClinicInviteBuilder email(String email) { this.email = email; return this; }
        public ClinicInviteBuilder tokenHash(String tokenHash) { this.tokenHash = tokenHash; return this; }
        public ClinicInviteBuilder expiresAt(OffsetDateTime expiresAt) { this.expiresAt = expiresAt; return this; }
        public ClinicInviteBuilder acceptedAt(OffsetDateTime acceptedAt) { this.acceptedAt = acceptedAt; return this; }
        public ClinicInviteBuilder revokedAt(OffsetDateTime revokedAt) { this.revokedAt = revokedAt; return this; }
        public ClinicInviteBuilder createdBy(UUID createdBy) { this.createdBy = createdBy; return this; }
        public ClinicInviteBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }

        public ClinicInvite build() {
            ClinicInvite c = new ClinicInvite();
            c.id = this.id;
            c.clinicId = this.clinicId;
            c.email = this.email;
            c.tokenHash = this.tokenHash;
            c.expiresAt = this.expiresAt;
            c.acceptedAt = this.acceptedAt;
            c.revokedAt = this.revokedAt;
            c.createdBy = this.createdBy;
            c.createdAt = this.createdAt;
            return c;
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getClinicId() { return clinicId; }
    public void setClinicId(UUID clinicId) { this.clinicId = clinicId; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTokenHash() { return tokenHash; }
    public void setTokenHash(String tokenHash) { this.tokenHash = tokenHash; }
    public OffsetDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(OffsetDateTime expiresAt) { this.expiresAt = expiresAt; }
    public OffsetDateTime getAcceptedAt() { return acceptedAt; }
    public void setAcceptedAt(OffsetDateTime acceptedAt) { this.acceptedAt = acceptedAt; }
    public OffsetDateTime getRevokedAt() { return revokedAt; }
    public void setRevokedAt(OffsetDateTime revokedAt) { this.revokedAt = revokedAt; }
    public UUID getCreatedBy() { return createdBy; }
    public void setCreatedBy(UUID createdBy) { this.createdBy = createdBy; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}
