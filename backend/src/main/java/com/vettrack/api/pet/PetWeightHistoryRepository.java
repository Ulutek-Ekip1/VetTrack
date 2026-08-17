package com.vettrack.api.pet;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PetWeightHistoryRepository extends JpaRepository<PetWeightHistory, UUID> {
    List<PetWeightHistory> findByPetIdOrderByRecordedAtAscCreatedAtAsc(UUID petId);
    Page<PetWeightHistory> findByPetIdOrderByRecordedAtAscCreatedAtAsc(UUID petId, Pageable pageable);
    Optional<PetWeightHistory> findTopByPetIdOrderByRecordedAtDescCreatedAtDesc(UUID petId);
}
