package com.vettrack.api.visit;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.pet.Pet;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@Getter
@AllArgsConstructor
public class ActiveVisitContextResponse {
    private final Visit visit;
    private final Pet pet;
    private final Owner owner;
    private final List<Visit> history;
}
