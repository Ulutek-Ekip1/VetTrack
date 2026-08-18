package com.vettrack.api.recommendation;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface RecommendationRepository extends JpaRepository<Recommendation, UUID> {

    List<Recommendation> findByVisitId(UUID visitId);

    @Query("SELECT r FROM Recommendation r JOIN Visit v ON r.visitId = v.id WHERE v.petId = :petId ORDER BY r.createdAt DESC")
    List<Recommendation> findByPetId(@Param("petId") UUID petId);

    /** Birden fazla ziyaretin önerilerini oluşturulma tarihine göre azalan sırada getirir */
    List<Recommendation> findByVisitIdInOrderByCreatedAtDesc(List<UUID> visitIds);
}

