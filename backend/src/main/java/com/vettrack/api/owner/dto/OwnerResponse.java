package com.vettrack.api.owner.dto;

import com.vettrack.api.owner.Owner;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OwnerResponse {

    private UUID id;
    private String fullName;
    private String email;
    private String phone;
    private String surname;
    private String address;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
    private String profilePhotoUrl;

    public static OwnerResponseBuilder builder() {
        return new OwnerResponseBuilder();
    }

    public static class OwnerResponseBuilder {
        private UUID id;
        private String fullName;
        private String email;
        private String phone;
        private String surname;
        private String address;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;
        private String profilePhotoUrl;

        public OwnerResponseBuilder id(UUID id) { this.id = id; return this; }
        public OwnerResponseBuilder fullName(String fullName) { this.fullName = fullName; return this; }
        public OwnerResponseBuilder email(String email) { this.email = email; return this; }
        public OwnerResponseBuilder phone(String phone) { this.phone = phone; return this; }
        public OwnerResponseBuilder surname(String surname) { this.surname = surname; return this; }
        public OwnerResponseBuilder address(String address) { this.address = address; return this; }
        public OwnerResponseBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public OwnerResponseBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
        public OwnerResponseBuilder profilePhotoUrl(String profilePhotoUrl) { this.profilePhotoUrl = profilePhotoUrl; return this; }

        public OwnerResponse build() {
            OwnerResponse r = new OwnerResponse();
            r.id = this.id;
            r.fullName = this.fullName;
            r.email = this.email;
            r.phone = this.phone;
            r.surname = this.surname;
            r.address = this.address;
            r.createdAt = this.createdAt;
            r.updatedAt = this.updatedAt;
            r.profilePhotoUrl = this.profilePhotoUrl;
            return r;
        }
    }

    public UUID getId() { return id; }
    public String getFullName() { return fullName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public String getSurname() { return surname; }
    public String getAddress() { return address; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
    public String getProfilePhotoUrl() { return profilePhotoUrl; }

    public static OwnerResponse fromEntity(Owner owner) {
        if (owner == null) {
            return null;
        }
        return OwnerResponse.builder()
                .id(owner.getId())
                .fullName(owner.getFullName())
                .email(owner.getEmail())
                .phone(owner.getPhone())
                .surname(owner.getSurname())
                .address(owner.getAddress())
                .createdAt(owner.getCreatedAt())
                .updatedAt(owner.getUpdatedAt())
                .profilePhotoUrl(owner.getProfilePhotoUrl())
                .build();
    }
}
