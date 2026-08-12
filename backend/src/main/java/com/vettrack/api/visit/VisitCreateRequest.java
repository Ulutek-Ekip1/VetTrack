package com.vettrack.api.visit;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class VisitCreateRequest {
    @NotNull(message = "Hayvan ID alanı boş olamaz")
    private UUID petId;
}
