package com.vettrack.api.pet;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class PetUpdateRequest {

    @NotBlank(message = "Pet adı boş olamaz")
    private String name;

    private String photoUrl;
    private Integer age;
    private String gender;
    private String breed;
}
