package com.vettrack.api.pet;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.UUID;

@Data
public class PetCreateRequest {

    @NotNull(message = "Owner ID boş olamaz")
    private UUID ownerId;

    @NotBlank(message = "Pet adı boş olamaz")
    private String name;

    private String photoUrl;
    private Integer age;
    private String gender;
    private String breed;
}
