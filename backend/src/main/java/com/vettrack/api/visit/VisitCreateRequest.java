package com.vettrack.api.visit;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VisitCreateRequest {

    @NotNull(message = "Pet ID zorunludur.")
    private UUID petId;

    private UUID vetStaffId;
    private UUID clinicId;
    private String chiefComplaint;
}
