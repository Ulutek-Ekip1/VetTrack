package com.vettrack.api.pet;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "pets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Pet {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Version
    @Column(name = "version")
    private Long version;

    @Column(name = "owner_id", nullable = false)
    private UUID ownerId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String species;

    @Column
    private String breed;

    @Column(nullable = false, length = 10)
    @Enumerated(EnumType.STRING)
    private Gender gender;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "estimated_birth_year")
    private Short estimatedBirthYear;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;

    @Column
    private Double weight;

    @Column(name = "microchip_no", length = 50)
    private String microchipNo;

    @Column(name = "is_spayed_or_neutered")
    private Boolean isSpayedOrNeutered;

    @Column(name = "blood_type", length = 20)
    private String bloodType;

    @Column(length = 50)
    private String color;

    @Column(columnDefinition = "TEXT")
    private String allergies;

    @Column(name = "chronic_illnesses", columnDefinition = "TEXT")
    private String chronicIllnesses;

    @Column(name = "unique_code", nullable = false, unique = true, length = 6)
    private String uniqueCode;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) this.createdAt = OffsetDateTime.now();
        this.updatedAt = OffsetDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }

    public UUID getId() {
        return id;
    }

    public Long getVersion() {
        return version;
    }

    public UUID getOwnerId() {
        return ownerId;
    }

    public String getName() {
        return name;
    }

    public String getSpecies() {
        return species;
    }

    public String getBreed() {
        return breed;
    }

    public Gender getGender() {
        return gender;
    }

    public LocalDate getBirthDate() {
        return birthDate;
    }

    public Short getEstimatedBirthYear() {
        return estimatedBirthYear;
    }

    public String getPhotoUrl() {
        return photoUrl;
    }

    public Double getWeight() {
        return weight;
    }

    public String getMicrochipNo() {
        return microchipNo;
    }

    public Boolean getIsSpayedOrNeutered() {
        return isSpayedOrNeutered;
    }

    public String getBloodType() {
        return bloodType;
    }

    public String getColor() {
        return color;
    }

    public String getAllergies() {
        return allergies;
    }

    public String getChronicIllnesses() {
        return chronicIllnesses;
    }

    public String getUniqueCode() {
        return uniqueCode;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }

    public OffsetDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(OffsetDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public void setPhotoUrl(String photoUrl) {
        this.photoUrl = photoUrl;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setSpecies(String species) {
        this.species = species;
    }

    public void setBreed(String breed) {
        this.breed = breed;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }

    public void setBirthDate(LocalDate birthDate) {
        this.birthDate = birthDate;
    }

    public void setEstimatedBirthYear(Short estimatedBirthYear) {
        this.estimatedBirthYear = estimatedBirthYear;
    }

    public void setMicrochipNo(String microchipNo) {
        this.microchipNo = microchipNo;
    }

    public void setIsSpayedOrNeutered(Boolean isSpayedOrNeutered) {
        this.isSpayedOrNeutered = isSpayedOrNeutered;
    }

    public void setBloodType(String bloodType) {
        this.bloodType = bloodType;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public void setAllergies(String allergies) {
        this.allergies = allergies;
    }

    public void setChronicIllnesses(String chronicIllnesses) {
        this.chronicIllnesses = chronicIllnesses;
    }

    public void setUniqueCode(String uniqueCode) {
        this.uniqueCode = uniqueCode;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public static PetBuilder builder() {
        return new PetBuilder();
    }

    public static class PetBuilder {
        private UUID id;
        private Long version;
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
        private Boolean isActive = true;
        private OffsetDateTime createdAt;
        private OffsetDateTime updatedAt;
        private OffsetDateTime deletedAt;

        public PetBuilder id(UUID id) { this.id = id; return this; }
        public PetBuilder version(Long version) { this.version = version; return this; }
        public PetBuilder ownerId(UUID ownerId) { this.ownerId = ownerId; return this; }
        public PetBuilder name(String name) { this.name = name; return this; }
        public PetBuilder species(String species) { this.species = species; return this; }
        public PetBuilder breed(String breed) { this.breed = breed; return this; }
        public PetBuilder gender(Gender gender) { this.gender = gender; return this; }
        public PetBuilder birthDate(LocalDate birthDate) { this.birthDate = birthDate; return this; }
        public PetBuilder estimatedBirthYear(Short estimatedBirthYear) { this.estimatedBirthYear = estimatedBirthYear; return this; }
        public PetBuilder photoUrl(String photoUrl) { this.photoUrl = photoUrl; return this; }
        public PetBuilder weight(Double weight) { this.weight = weight; return this; }
        public PetBuilder microchipNo(String microchipNo) { this.microchipNo = microchipNo; return this; }
        public PetBuilder isSpayedOrNeutered(Boolean isSpayedOrNeutered) { this.isSpayedOrNeutered = isSpayedOrNeutered; return this; }
        public PetBuilder bloodType(String bloodType) { this.bloodType = bloodType; return this; }
        public PetBuilder color(String color) { this.color = color; return this; }
        public PetBuilder allergies(String allergies) { this.allergies = allergies; return this; }
        public PetBuilder chronicIllnesses(String chronicIllnesses) { this.chronicIllnesses = chronicIllnesses; return this; }
        public PetBuilder uniqueCode(String uniqueCode) { this.uniqueCode = uniqueCode; return this; }
        public PetBuilder isActive(Boolean isActive) { this.isActive = isActive; return this; }
        public PetBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }
        public PetBuilder updatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; return this; }
        public PetBuilder deletedAt(OffsetDateTime deletedAt) { this.deletedAt = deletedAt; return this; }

        public Pet build() {
            Pet p = new Pet();
            p.id = this.id;
            p.version = this.version;
            p.ownerId = this.ownerId;
            p.name = this.name;
            p.species = this.species;
            p.breed = this.breed;
            p.gender = this.gender;
            p.birthDate = this.birthDate;
            p.estimatedBirthYear = this.estimatedBirthYear;
            p.photoUrl = this.photoUrl;
            p.weight = this.weight;
            p.microchipNo = this.microchipNo;
            p.isSpayedOrNeutered = this.isSpayedOrNeutered;
            p.bloodType = this.bloodType;
            p.color = this.color;
            p.allergies = this.allergies;
            p.chronicIllnesses = this.chronicIllnesses;
            p.uniqueCode = this.uniqueCode;
            p.isActive = this.isActive;
            p.createdAt = this.createdAt;
            p.updatedAt = this.updatedAt;
            p.deletedAt = this.deletedAt;
            return p;
        }
    }
}