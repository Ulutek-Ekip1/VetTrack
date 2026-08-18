package com.vettrack.api.treatment;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * ScheduledTreatmentNotifier'ın findAll() yerine kullandığı hedefli sorgu
 * (findByStatusAndStartDateBetween) doğru filtreliyor mu — durum, tarih aralığı
 * ve null startDate senaryoları.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:treatmentscheduledquerydb;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "SUPABASE_URL=https://localhost",
    "SUPABASE_JWKS_URL=https://localhost/auth/v1/.well-known/jwks.json",
    "SUPABASE_JWT_ISSUER=https://localhost/auth/v1",
    "SUPABASE_STORAGE_URL=https://localhost/storage/v1",
    "SUPABASE_SERVICE_KEY=mock-key",
    "supabase.storage.url=https://localhost/storage/v1",
    "supabase.storage.service-key=mock-key",
    "FIREBASE_CREDENTIALS_PATH=mock-path"
})
class TreatmentEntryRepositoryScheduledQueryTest {

    @Autowired
    private TreatmentEntryRepository treatmentEntryRepository;

    private OffsetDateTime windowStart;
    private OffsetDateTime windowEnd;

    private TreatmentEntry inWindowPlanned;

    @BeforeEach
    void setUp() {
        treatmentEntryRepository.deleteAll();

        OffsetDateTime now = OffsetDateTime.now();
        windowStart = now.minusMinutes(5);
        windowEnd = now.plusMinutes(30);

        inWindowPlanned = save(TreatmentStatus.PLANNED, now.plusMinutes(10));
        save(TreatmentStatus.COMPLETED, now.plusMinutes(10)); // yanlış durum
        save(TreatmentStatus.PLANNED, now.plusHours(2)); // pencere dışı (çok ileri)
        save(TreatmentStatus.PLANNED, now.minusHours(2)); // pencere dışı (çok geride)
        save(TreatmentStatus.PLANNED, null); // startDate null
    }

    private TreatmentEntry save(TreatmentStatus status, OffsetDateTime startDate) {
        return treatmentEntryRepository.save(TreatmentEntry.builder()
                .visitId(UUID.randomUUID())
                .type("medication")
                .title("Test Tedavi")
                .status(status)
                .startDate(startDate)
                .build());
    }

    @Test
    @DisplayName("Sadece PLANNED + pencere içindeki kayıt döner; yanlış durum/pencere dışı/null hariç")
    void returnsOnlyMatchingEntries() {
        List<TreatmentEntry> result =
                treatmentEntryRepository.findByStatusAndStartDateBetween(TreatmentStatus.PLANNED, windowStart, windowEnd);

        assertEquals(1, result.size());
        assertEquals(inWindowPlanned.getId(), result.get(0).getId());
    }

    @Test
    @DisplayName("Pencere sınırları dahil (BETWEEN inclusive)")
    void boundaryTimestamps_areIncluded() {
        TreatmentEntry atStart = save(TreatmentStatus.PLANNED, windowStart);
        TreatmentEntry atEnd = save(TreatmentStatus.PLANNED, windowEnd);

        List<TreatmentEntry> result =
                treatmentEntryRepository.findByStatusAndStartDateBetween(TreatmentStatus.PLANNED, windowStart, windowEnd);

        List<UUID> ids = result.stream().map(TreatmentEntry::getId).toList();
        assertTrue(ids.contains(atStart.getId()));
        assertTrue(ids.contains(atEnd.getId()));
    }
}
