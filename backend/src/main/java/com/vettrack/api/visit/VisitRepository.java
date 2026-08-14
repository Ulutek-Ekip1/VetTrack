package com.vettrack.api.visit;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VisitRepository extends JpaRepository<Visit, UUID> {
    Optional<Visit> findByPetIdAndStatus(UUID petId, String status);
    List<Visit> findByPetIdOrderByStartedAtDesc(UUID petId);
    List<Visit> findByPetIdInOrderByStartedAtDesc(List<UUID> petIds);
    List<Visit> findByVetStaffIdOrderByStartedAtDesc(UUID vetStaffId);
    List<Visit> findAllByOrderByStartedAtDesc();
    Page<Visit> findByPetIdOrderByStartedAtDesc(UUID petId, Pageable pageable);
}
