package com.vettrack.api.pet;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PetRepository extends JpaRepository<Pet, UUID> {
    Optional<Pet> findByUniqueCodeIgnoreCase(String uniqueCode);
    List<Pet> findByOwnerId(UUID ownerId);
    boolean existsByUniqueCode(String uniqueCode);
}
