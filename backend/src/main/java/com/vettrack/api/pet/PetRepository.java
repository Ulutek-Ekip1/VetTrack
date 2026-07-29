package com.vettrack.api.pet;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PetRepository extends JpaRepository<Pet, UUID> {
    Optional<Pet> findByUniqueCodeIgnoreCase(String uniqueCode);
    List<Pet> findByOwnerIdOrderByCreatedAtDesc(UUID ownerId);
    boolean existsByUniqueCode(String uniqueCode);
    List<Pet> findByOwnerIdAndDeletedAtIsNullOrderByCreatedAtDesc(UUID ownerId);
    Optional<Pet> findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(String uniqueCode);
}
