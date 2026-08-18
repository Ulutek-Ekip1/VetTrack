package com.vettrack.api.notification;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.treatment.TreatmentEntry;
import com.vettrack.api.treatment.TreatmentEntryRepository;
import com.vettrack.api.treatment.TreatmentStatus;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * ScheduledTreatmentNotifier: findAll() yerine hedefli sorgu (findByStatusAndStartDateBetween)
 * kullanıldığını ve atomik kilit/bildirim akışının değişmediğini doğrular.
 */
class ScheduledTreatmentNotifierTest {

    private TreatmentEntryRepository treatmentEntryRepository;
    private VisitRepository visitRepository;
    private PetRepository petRepository;
    private NotificationService notificationService;
    private ScheduledTreatmentNotifier notifier;

    @BeforeEach
    void setUp() {
        treatmentEntryRepository = mock(TreatmentEntryRepository.class);
        visitRepository = mock(VisitRepository.class);
        petRepository = mock(PetRepository.class);
        notificationService = mock(NotificationService.class);
        notifier = new ScheduledTreatmentNotifier(treatmentEntryRepository, visitRepository, petRepository, notificationService);

        when(treatmentEntryRepository.findByStatusAndStartDateBetween(any(), any(), any()))
                .thenReturn(List.of());
    }

    @Test
    void scan_neverCallsFindAll_usesTargetedQuery() {
        notifier.scanAndSendTreatmentReminders();

        verify(treatmentEntryRepository, never()).findAll();
        verify(treatmentEntryRepository).findByStatusAndStartDateBetween(
                eq(TreatmentStatus.PLANNED), any(OffsetDateTime.class), any(OffsetDateTime.class));
    }

    @Test
    void scan_lockAcquired_sendsNotification() {
        UUID entryId = UUID.randomUUID();
        UUID visitId = UUID.randomUUID();
        UUID petId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();

        TreatmentEntry entry = TreatmentEntry.builder()
                .id(entryId).visitId(visitId).type("medication").title("Aşı")
                .status(TreatmentStatus.PLANNED).startDate(OffsetDateTime.now().plusMinutes(10)).build();
        when(treatmentEntryRepository.findByStatusAndStartDateBetween(any(), any(), any()))
                .thenReturn(List.of(entry));
        when(treatmentEntryRepository.markNotificationSentIfNotMarked(entryId)).thenReturn(1);
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(Visit.builder().id(visitId).petId(petId).build()));
        when(petRepository.findById(petId)).thenReturn(Optional.of(
                Pet.builder().id(petId).ownerId(ownerId).name("Pamuk").species("Kedi").build()));

        notifier.scanAndSendTreatmentReminders();

        verify(notificationService).sendNotificationToOwner(
                eq(ownerId), eq(NotificationType.TREATMENT), anyString(), anyString(), eq(entryId));
    }

    @Test
    void scan_lockNotAcquired_racedByAnotherInstance_skipsNotification() {
        UUID entryId = UUID.randomUUID();
        TreatmentEntry entry = TreatmentEntry.builder()
                .id(entryId).visitId(UUID.randomUUID()).type("medication").title("Aşı")
                .status(TreatmentStatus.PLANNED).startDate(OffsetDateTime.now().plusMinutes(10)).build();
        when(treatmentEntryRepository.findByStatusAndStartDateBetween(any(), any(), any()))
                .thenReturn(List.of(entry));
        when(treatmentEntryRepository.markNotificationSentIfNotMarked(entryId)).thenReturn(0);

        notifier.scanAndSendTreatmentReminders();

        verifyNoInteractions(notificationService);
        verifyNoInteractions(visitRepository);
    }
}
