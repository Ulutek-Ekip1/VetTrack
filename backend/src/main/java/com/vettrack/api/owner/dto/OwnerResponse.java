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
