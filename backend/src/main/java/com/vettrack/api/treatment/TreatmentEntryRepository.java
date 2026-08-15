package com.vettrack.api.treatment;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

import jakarta.transaction.Transactional;

@Repository
public interface TreatmentEntryRepository extends JpaRepository<TreatmentEntry, UUID> {

    /** Ziyaretin tüm tedavilerini startDate azalan sırada getirir */
    List<TreatmentEntry> findByVisitIdOrderByStartDateDesc(UUID visitId);

    /** Ziyaretin tedavilerini durum filtresine göre startDate azalan sırada getirir */
    List<TreatmentEntry> findByVisitIdAndStatusOrderByStartDateDesc(UUID visitId, TreatmentStatus status);

    /** Ziyaretin tüm tedavilerini getirir (sırasız — eski uyumluluk) */
    List<TreatmentEntry> findByVisitId(UUID visitId);

    /** Atomik olarak notification_sent=true olarak işaretle — çağıran 1 dönerse ilk işaretleme yapıldı */
    @Modifying
    @Transactional
    @Query("UPDATE TreatmentEntry t SET t.notificationSent = true WHERE t.id = :id AND (t.notificationSent = false OR t.notificationSent IS NULL)")
    int markNotificationSentIfNotMarked(@Param("id") UUID id);
}