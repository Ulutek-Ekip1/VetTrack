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
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Slf4j
@Component
public class ScheduledTreatmentNotifier {

    private final TreatmentEntryRepository treatmentEntryRepository;
    private final VisitRepository visitRepository;
    private final PetRepository petRepository;
    private final NotificationService notificationService;

    public ScheduledTreatmentNotifier(TreatmentEntryRepository treatmentEntryRepository,
                                      VisitRepository visitRepository,
                                      PetRepository petRepository,
                                      NotificationService notificationService) {
        this.treatmentEntryRepository = treatmentEntryRepository;
        this.visitRepository = visitRepository;
        this.petRepository = petRepository;
        this.notificationService = notificationService;
    }

    /**
     * Arka planda her 5 dakikada bir çalışarak zamanı yaklaşan tedavileri tarar
     * ve hayvan sahiplerinin cihazlarına otomatik FCM push bildirimi gönderir.
     * 
     * Cloud Run / Çoklu Instance (Multi-pod) Yarış Durumu (Race Condition) Çözümü:
     * Check-Then-Act anti-pattern'i tamamen kaldırılmıştır. İki veya daha fazla instance
     * aynı anda çalıştığında, bildirim gönderilmeden ÖNCE veritabanı seviyesinde atomik bir 
     * UPDATE sorgusu çalıştırılır:
     * 
     *   UPDATE treatment_entries 
     *   SET notification_sent = true 
     *   WHERE id = :id AND (notification_sent = false OR notification_sent IS NULL);
     * 
     * PostgreSQL row-level locking sayesinde yalnızca TEK BİR INSTANCE 1 etkilenen satır yanıtı alır.
     * Etkilenen satır sayısı 0 olan diğer tüm instance'lar hakkı alamadığı için işlemi sessizce atlar (skip).
     */
    @Scheduled(cron = "0 */5 * * * *")
    @Transactional
    public void scanAndSendTreatmentReminders() {
        log.info("Zamanlanmış tedavi ve aşı hatırlatıcı taraması başlatıldı...");

        try {
            OffsetDateTime now = OffsetDateTime.now();
            OffsetDateTime windowStart = now.minusMinutes(5);
            OffsetDateTime thirtyMinutesLater = now.plusMinutes(30);

            // Bellek/Sorgu Optimizasyonu: findAll() ile tüm tablo JVM belleğine çekilmez —
            // yalnızca PLANNED durumunda ve zamanı yaklaşan tedaviler hedefli sorguyla getirilir.
            List<TreatmentEntry> dueEntries = treatmentEntryRepository
                    .findByStatusAndStartDateBetween(TreatmentStatus.PLANNED, windowStart, thirtyMinutesLater);

            int sentCount = 0;
            for (TreatmentEntry entry : dueEntries) {

                /*
                 * GEREKSİNİM 1 & 2 & 3: ATOMİK VERİTABANI KİLİDİ HAKKI ALMA (CONDITIONAL UPDATE)
                 * Check-Then-Act yapılmaz. Doğrudan tek bir SQL UPDATE sorgusu ile veritabanı
                 * seviyesinde kilit hakkı (lock acquisition) alınır.
                 */
                int affectedRows = 0;
                try {
                    affectedRows = treatmentEntryRepository.markNotificationSentIfNotMarked(entry.getId());
                } catch (Exception e) {
                    log.warn("Atomik bildirim kilidi alınırken hata oluştu (id: {}): {}", entry.getId(), e.getMessage());
                }

                // Etkilenen satır sayısı 0 ise: Başka bir Cloud Run instance'ı hakkı zaten aldı ve kilitledi.
                // Bu instance işlemi sessizce atlar (skip).
                if (affectedRows == 0) {
                    continue;
                }

                /*
                 * GEREKSİNİM 4 & 5: BİLDİRİM GÖNDERİMİ VE HATA / ROLLBACK ELE ALIMI
                 * Satır sayısı 1 ise: Yalnızca bu instance kilit hakkını kazandı. Bildirim gönderimi başlatılır.
                 *
                 * HATA ELE ALIMI / ROLLBACK STRATEJİSİ:
                 * -----------------------------------------------------------------------------------------
                 * 1. Ağ hatası veya FCM Push servisi çökmesi durumunda (catch bloğunda):
                 *    - İsteğe bağlı olarak 'notificationSent' alanını tekrar 'false' yaparak sonraki taramada
                 *      yeniden denenmesi (retry) sağlanabilir:
                 *      treatmentEntryRepository.resetNotificationSent(entry.getId());
                 * 2. Ancak FCM ve üçüncü taraf bildirim servislerinde "at-least-once" teslimat riski bulunduğundan,
                 *    bildirim servisi yanıt vermese dahi mesajın cihaza ulaşmış olma ihtimaline karşı varsayılan olarak
                 *    'notificationSent = true' bırakılması mükerrer bildirim bombardımanını önlemek için daha güvenlidir.
                 * 3. İleri düzey retry mekanizması için başarısız olan bildirimler 'failed_notification_logs'
                 *    tablosuna yazılarak dead-letter queue (DLQ) mantığı ile yönetilebilir.
                 * -----------------------------------------------------------------------------------------
                 */
                try {
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

                            sentCount++;
                        }
                    }
                } catch (Exception pushEx) {
                    log.error("FCM Push bildirimi gönderilirken hata oluştu (Treatment ID: {}): {}", entry.getId(), pushEx.getMessage(), pushEx);
                    // Not: Hata durumunda bildirim kilitli kalır (notification_sent = true).
                    // Eğer retry isteniyorsa: treatmentEntryRepository.resetNotificationSent(entry.getId());
                }
            }
            log.info("Tedavi hatırlatıcı taraması tamamlandı. Toplam {} bildirim gönderildi.", sentCount);

        } catch (Exception e) {
            log.error("Zamanlanmış tedavi hatırlatıcı taramasında hata oluştu: {}", e.getMessage(), e);
        }
    }
}
