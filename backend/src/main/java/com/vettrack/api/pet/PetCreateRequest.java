package com.vettrack.api.pet;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
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
}