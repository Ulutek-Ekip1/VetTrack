package com.vettrack.api.notification;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.treatment.TreatmentEntry;
import com.vettrack.api.treatment.TreatmentEntryRepository;
import com.vettrack.api.treatment.TreatmentStatus;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
@RequiredArgsConstructor
public class ScheduledTreatmentNotifier {

    private final TreatmentEntryRepository treatmentEntryRepository;
    private final VisitRepository visitRepository;
    private final PetRepository petRepository;
    private final NotificationService notificationService;

    // Tekrarlayan push bildirim gönderimini önlemek için bildirim atılan tedavi ID'lerini saklar
    private final Set<UUID> notifiedTreatmentIds = ConcurrentHashMap.newKeySet();

    /**
     * Arka planda her 5 dakikada bir çalışarak zamanı yaklaşan tedavileri tarar
     * ve hayvan sahiplerinin cihazlarına otomatik FCM push bildirimi gönderir.
     */
    @Scheduled(cron = "0 */5 * * * *")
    public void scanAndSendTreatmentReminders() {
        log.info("Zamanlanmış tedavi ve aşı hatırlatıcı taraması başlatıldı...");

        try {
            OffsetDateTime now = OffsetDateTime.now();
            OffsetDateTime thirtyMinutesLater = now.plusMinutes(30);

            List<TreatmentEntry> allEntries = treatmentEntryRepository.findAll();

            int sentCount = 0;
            for (TreatmentEntry entry : allEntries) {
                if (entry.getId() != null && notifiedTreatmentIds.contains(entry.getId())) {
                    continue;
                }

                // Sadece planlanmış ve zamanı yaklaşan tedaviler
                if (entry.getStatus() == TreatmentStatus.PLANNED && entry.getStartDate() != null) {
                    if (entry.getStartDate().isAfter(now.minusMinutes(5)) && entry.getStartDate().isBefore(thirtyMinutesLater)) {
                        Optional<Visit> visitOpt = visitRepository.findById(entry.getVisitId());
                        if (visitOpt.isPresent()) {
                            Optional<Pet> petOpt = petRepository.findById(visitOpt.get().getPetId());
                            if (petOpt.isPresent() && petOpt.get().getOwnerId() != null) {
                                Pet pet = petOpt.get();
                                String title = "⏰ Tedavi / Aşı Hatırlatması: " + pet.getName();
                                String body = String.format("%s için '%s' tedavisi yaklaşmaktadır. Lütfen ilacı/aşıyı zamanında uygulayınız.",
                                        pet.getName(), entry.getTitle());

                                notificationService.sendNotificationToOwner(
                                        pet.getOwnerId(),
                                        NotificationType.TREATMENT,
                                        title,
                                        body,
                                        entry.getId()
                                );
                                notifiedTreatmentIds.add(entry.getId());
                                sentCount++;
                            }
                        }
                    }
                }
            }
            log.info("Tedavi hatırlatıcı taraması tamamlandı. Toplam {} bildirim gönderildi.", sentCount);

        } catch (Exception e) {
            log.error("Zamanlanmış tedavi hatırlatıcı taramasında hata oluştu: {}", e.getMessage(), e);
        }
    }
}
