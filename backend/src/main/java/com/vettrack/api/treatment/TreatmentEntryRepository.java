package com.vettrack.api.treatment;

import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
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

    /** Birden fazla ziyaretin tedavilerini oluşturulma tarihine göre azalan sırada getirir */
    List<TreatmentEntry> findByVisitIdInOrderByCreatedAtDesc(List<UUID> visitIds);

    /**
     * Zamanlanmış bildirim taraması (ScheduledTreatmentNotifier) için hedefli sorgu.
     * findAll() ile tüm tabloyu JVM belleğine çekmek yerine, sadece belirli durumda ve
     * tarih aralığındaki kayıtları döner — OOM riskini ortadan kaldırır.
     */
    List<TreatmentEntry> findByStatusAndStartDateBetween(TreatmentStatus status, OffsetDateTime start, OffsetDateTime end);

    /** Atomik olarak notification_sent=true olarak işaretle — çağıran 1 dönerse ilk işaretleme yapıldı */
    @Modifying
    @Transactional
    @Query("UPDATE TreatmentEntry t SET t.notificationSent = true WHERE t.id = :id AND (t.notificationSent = false OR t.notificationSent IS NULL)")
    int markNotificationSentIfNotMarked(@Param("id") UUID id);
}
