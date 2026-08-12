package com.vettrack.api.pet;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import jakarta.persistence.LockModeType;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PetRepository extends JpaRepository<Pet, UUID> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Pet p where p.id = :petId")
    Optional<Pet> findByIdForVisitCreation(@Param("petId") UUID petId);

    Optional<Pet> findByUniqueCodeIgnoreCase(String uniqueCode);
    List<Pet> findByOwnerIdOrderByCreatedAtDesc(UUID ownerId);
    boolean existsByUniqueCode(String uniqueCode);
    List<Pet> findByOwnerIdAndDeletedAtIsNullOrderByCreatedAtDesc(UUID ownerId);
    Optional<Pet> findByUniqueCodeIgnoreCaseAndDeletedAtIsNull(String uniqueCode);
}
