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
}