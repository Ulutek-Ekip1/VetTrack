package com.vettrack.api.pet;

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
}