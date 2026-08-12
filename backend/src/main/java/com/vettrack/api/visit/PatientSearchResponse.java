package com.vettrack.api.visit;

import com.vettrack.api.pet.Pet;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

/** The patient and their visit history returned after a vet searches an access code. */
@Getter
@AllArgsConstructor
public class PatientSearchResponse {
    private final Pet pet;
    private final List<Visit> visits;
}
