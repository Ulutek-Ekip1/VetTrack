package com.vettrack.api.pet;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import java.time.LocalDate;

@Data
public class PetUpdateRequest {

    private String name;
    private String species;
    private String breed;
    private Gender gender;
    private LocalDate birthDate;
    private Short estimatedBirthYear;
    @Positive(message = "Kilo değeri pozitif olmalıdır")
    @DecimalMax(value = "2000.0", message = "Kilo değeri gerçekçi olmalıdır")
    private Double weight;
    private String microchipNo;
    private Boolean isSpayedOrNeutered;
    private String bloodType;
    private String color;
    private String allergies;
    private String chronicIllnesses;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }
    public String getBreed() { return breed; }
    public void setBreed(String breed) { this.breed = breed; }
    public Gender getGender() { return gender; }
    public void setGender(Gender gender) { this.gender = gender; }
    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }
    public Short getEstimatedBirthYear() { return estimatedBirthYear; }
    public void setEstimatedBirthYear(Short estimatedBirthYear) { this.estimatedBirthYear = estimatedBirthYear; }
    public Double getWeight() { return weight; }
    public void setWeight(Double weight) { this.weight = weight; }
    public String getMicrochipNo() { return microchipNo; }
    public void setMicrochipNo(String microchipNo) { this.microchipNo = microchipNo; }
    public Boolean getIsSpayedOrNeutered() { return isSpayedOrNeutered; }
    public void setIsSpayedOrNeutered(Boolean isSpayedOrNeutered) { this.isSpayedOrNeutered = isSpayedOrNeutered; }
    public String getBloodType() { return bloodType; }
    public void setBloodType(String bloodType) { this.bloodType = bloodType; }
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }
    public String getAllergies() { return allergies; }
    public void setAllergies(String allergies) { this.allergies = allergies; }
    public String getChronicIllnesses() { return chronicIllnesses; }
    public void setChronicIllnesses(String chronicIllnesses) { this.chronicIllnesses = chronicIllnesses; }
}