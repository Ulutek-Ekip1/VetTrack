package com.vettrack.api.owner;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Owner {

    @Id
    private UUID id;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(length = 20)
    private String phone;

    @Column(nullable = false)
    private String role;

    @Column(length = 50)
    private String surname;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "profile_photo_url", length = 512)
    private String profilePhotoUrl;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null)
            this.createdAt = OffsetDateTime.now();
        this.updatedAt = OffsetDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }

    public UUID getId() {
        return id;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getRole() {
        return role;
    }

    public String getSurname() {
        return surname;
    }

    public String getAddress() {
        return address;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public String getProfilePhotoUrl() {
        return profilePhotoUrl;
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

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public void setProfilePhotoUrl(String profilePhotoUrl) {
        this.profilePhotoUrl = profilePhotoUrl;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(OffsetDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public static OwnerBuilder builder() {
        return new OwnerBuilder();
    }

    public static class OwnerBuilder {
        private UUID id;
        private String fullName;
        private String email;
        private String phone;
        private String role;
        private String surname;
        private String address;
        private Boolean isActive = true;
        private String profilePhotoUrl;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public OwnerBuilder id(UUID id) { this.id = id; return this; }
        public OwnerBuilder fullName(String fullName) { this.fullName = fullName; return this; }
        public OwnerBuilder email(String email) { this.email = email; return this; }
        public OwnerBuilder phone(String phone) { this.phone = phone; return this; }
        public OwnerBuilder role(String role) { this.role = role; return this; }
        public OwnerBuilder surname(String surname) { this.surname = surname; return this; }
        public OwnerBuilder address(String address) { this.address = address; return this; }
        public OwnerBuilder isActive(Boolean isActive) { this.isActive = isActive; return this; }
        public OwnerBuilder profilePhotoUrl(String profilePhotoUrl) { this.profilePhotoUrl = profilePhotoUrl; return this; }
        public OwnerBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public OwnerBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public Owner build() {
            Owner o = new Owner();
            o.id = this.id;
            o.fullName = this.fullName;
            o.email = this.email;
            o.phone = this.phone;
            o.role = this.role;
            o.surname = this.surname;
            o.address = this.address;
            o.isActive = this.isActive;
            o.profilePhotoUrl = this.profilePhotoUrl;
            o.createdAt = this.createdAt;
            o.updatedAt = this.updatedAt;
            return o;
        }
    }
}