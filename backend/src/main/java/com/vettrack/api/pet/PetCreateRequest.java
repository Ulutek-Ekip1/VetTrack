package com.vettrack.api.pet;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import java.time.LocalDate;

@Data
public class PetCreateRequest {

    @NotBlank(message = "Pet adı boş olamaz")
    private String name;

    @NotBlank(message = "Tür bilgisi boş olamaz")
    private String species;

    private String breed;

    @NotNull(message = "Cinsiyet alanı MALE, FEMALE veya UNKNOWN olmalıdır")
    private Gender gender;

    private LocalDate birthDate;
    private Short estimatedBirthYear;
    private String photoUrl;
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