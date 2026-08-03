package com.vettrack.api.treatment;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface TreatmentEntryRepository extends JpaRepository<TreatmentEntry, UUID> {

    /** Ziyaretin tüm tedavilerini startDate azalan sırada getirir */
    List<TreatmentEntry> findByVisitIdOrderByStartDateDesc(UUID visitId);

    /** Ziyaretin tedavilerini durum filtresine göre startDate azalan sırada getirir */
    List<TreatmentEntry> findByVisitIdAndStatusOrderByStartDateDesc(UUID visitId, TreatmentStatus status);

    /** Ziyaretin tüm tedavilerini getirir (sırasız — eski uyumluluk) */
    List<TreatmentEntry> findByVisitId(UUID visitId);
}