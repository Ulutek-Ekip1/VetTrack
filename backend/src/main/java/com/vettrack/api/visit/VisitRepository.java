package com.vettrack.api.visit;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VisitRepository extends JpaRepository<Visit, UUID> {
    Optional<Visit> findByPetIdAndStatus(UUID petId, String status);
    List<Visit> findByPetIdOrderByStartedAtDesc(UUID petId);
    List<Visit> findByPetIdAndClinicIdOrderByStartedAtDesc(UUID petId, UUID clinicId);
    Page<Visit> findByPetIdOrderByStartedAtDesc(UUID petId, Pageable pageable);
    Page<Visit> findByPetIdAndClinicIdInOrderByStartedAtDesc(UUID petId, List<UUID> clinicIds, Pageable pageable);

    /**
     * Sahibin (owner) tüm aktif petlerinin ziyaret geçmişini tek sorguda getirir (N+1 önleme).
     * Soft-delete edilmiş (deletedAt dolu) veya pasif (isActive=false) petlerin ziyaretleri hariç.
     */
    @Query("""
            SELECT v FROM Visit v, Pet p
            WHERE v.petId = p.id
              AND p.ownerId = :ownerId
              AND p.deletedAt IS NULL
              AND p.isActive = true
            ORDER BY v.startedAt DESC
            """)
    List<Visit> findVisitsForOwner(@Param("ownerId") UUID ownerId);
}
