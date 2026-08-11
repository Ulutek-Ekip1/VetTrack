package com.vettrack.api.visit;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class VisitCreateRequest {

    @NotBlank(message = "Hayvan benzersiz kodu (unique code) boş olamaz")
    private String uniqueCode;

    @NotNull(message = "Veteriner personel ID alanı boş olamaz")
    private UUID vetStaffId;

    private String chiefComplaint;
}