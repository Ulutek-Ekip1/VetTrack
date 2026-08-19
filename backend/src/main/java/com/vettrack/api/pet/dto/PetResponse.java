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
    private Double weight;
    private String microchipNo;
    private Boolean isSpayedOrNeutered;
    private String bloodType;
    private String color;
    private String allergies;
    private String chronicIllnesses;
    private String uniqueCode;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    public static PetResponseBuilder builder() {
        return new PetResponseBuilder();
    }

    public static class PetResponseBuilder {
        private UUID id;
        private UUID ownerId;
        private String name;
        private String species;
        private String breed;
        private Gender gender;
        private LocalDate birthDate;
        private Short estimatedBirthYear;
        private String photoUrl;
        private Double weight;
        private String microchipNo;
        private Boolean isSpayedOrNeutered;
        private String bloodType;
        private String color;
        private String allergies;
        private String chronicIllnesses;
        private String uniqueCode;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;

        public PetResponseBuilder id(UUID id) { this.id = id; return this; }
        public PetResponseBuilder ownerId(UUID ownerId) { this.ownerId = ownerId; return this; }
        public PetResponseBuilder name(String name) { this.name = name; return this; }
        public PetResponseBuilder species(String species) { this.species = species; return this; }
        public PetResponseBuilder breed(String breed) { this.breed = breed; return this; }
        public PetResponseBuilder gender(Gender gender) { this.gender = gender; return this; }
        public PetResponseBuilder birthDate(LocalDate birthDate) { this.birthDate = birthDate; return this; }
        public PetResponseBuilder estimatedBirthYear(Short estimatedBirthYear) { this.estimatedBirthYear = estimatedBirthYear; return this; }
        public PetResponseBuilder photoUrl(String photoUrl) { this.photoUrl = photoUrl; return this; }
        public PetResponseBuilder weight(Double weight) { this.weight = weight; return this; }
        public PetResponseBuilder microchipNo(String microchipNo) { this.microchipNo = microchipNo; return this; }
        public PetResponseBuilder isSpayedOrNeutered(Boolean isSpayedOrNeutered) { this.isSpayedOrNeutered = isSpayedOrNeutered; return this; }
        public PetResponseBuilder bloodType(String bloodType) { this.bloodType = bloodType; return this; }
        public PetResponseBuilder color(String color) { this.color = color; return this; }
        public PetResponseBuilder allergies(String allergies) { this.allergies = allergies; return this; }
        public PetResponseBuilder chronicIllnesses(String chronicIllnesses) { this.chronicIllnesses = chronicIllnesses; return this; }
        public PetResponseBuilder uniqueCode(String uniqueCode) { this.uniqueCode = uniqueCode; return this; }
        public PetResponseBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public PetResponseBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }

        public PetResponse build() {
            PetResponse r = new PetResponse();
            r.id = this.id;
            r.ownerId = this.ownerId;
            r.name = this.name;
            r.species = this.species;
            r.breed = this.breed;
            r.gender = this.gender;
            r.birthDate = this.birthDate;
            r.estimatedBirthYear = this.estimatedBirthYear;
            r.photoUrl = this.photoUrl;
            r.weight = this.weight;
            r.microchipNo = this.microchipNo;
            r.isSpayedOrNeutered = this.isSpayedOrNeutered;
            r.bloodType = this.bloodType;
            r.color = this.color;
            r.allergies = this.allergies;
            r.chronicIllnesses = this.chronicIllnesses;
            r.uniqueCode = this.uniqueCode;
            r.createdAt = this.createdAt;
            r.updatedAt = this.updatedAt;
            return r;
        }
    }

    public UUID getId() { return id; }
    public UUID getOwnerId() { return ownerId; }
    public String getName() { return name; }
    public String getSpecies() { return species; }
    public String getBreed() { return breed; }
    public Gender getGender() { return gender; }
    public LocalDate getBirthDate() { return birthDate; }
    public Short getEstimatedBirthYear() { return estimatedBirthYear; }
    public String getPhotoUrl() { return photoUrl; }
    public Double getWeight() { return weight; }
    public String getMicrochipNo() { return microchipNo; }
    public Boolean getIsSpayedOrNeutered() { return isSpayedOrNeutered; }
    public String getBloodType() { return bloodType; }
    public String getColor() { return color; }
    public String getAllergies() { return allergies; }
    public String getChronicIllnesses() { return chronicIllnesses; }
    public String getUniqueCode() { return uniqueCode; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }

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
                .weight(pet.getWeight())
                .microchipNo(pet.getMicrochipNo())
                .isSpayedOrNeutered(pet.getIsSpayedOrNeutered())
                .bloodType(pet.getBloodType())
                .color(pet.getColor())
                .allergies(pet.getAllergies())
                .chronicIllnesses(pet.getChronicIllnesses())
                .uniqueCode(pet.getUniqueCode())
                .createdAt(pet.getCreatedAt())
                .updatedAt(pet.getUpdatedAt())
                .build();
    }
}
