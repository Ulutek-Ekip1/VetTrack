package com.vettrack.api.pet.dto;

import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PetResponse {

    private UUID id;
    private UUID ownerId;
    private String name;
    private String species;
    private String breed;
    private Gender gender;
    private LocalDate birthDate;
    private Short estimatedBirthYear;
    private String photoUrl;
    private String uniqueCode;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public static PetResponse fromEntity(Pet pet) {
        if (pet == null) {
            return null;
        }
        return PetResponse.builder()
                .id(pet.getId())
                .ownerId(pet.getOwnerId())
                .name(pet.getName())
                .species(pet.getSpecies())
                .breed(pet.getBreed())
                .gender(pet.getGender())
                .birthDate(pet.getBirthDate())
                .estimatedBirthYear(pet.getEstimatedBirthYear())
                .photoUrl(pet.getPhotoUrl())
                .uniqueCode(pet.getUniqueCode())
                .createdAt(pet.getCreatedAt())
                .updatedAt(pet.getUpdatedAt())
                .build();
    }
}
