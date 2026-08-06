package com.vettrack.api.pet;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import java.time.LocalDate;

@Data
public class PetUpdateRequest {

    @NotBlank(message = "Pet adı boş olamaz")
    private String name;
    private String species;
    private String breed;
    private Gender gender;
    private LocalDate birthDate;
    private Short estimatedBirthYear;
}