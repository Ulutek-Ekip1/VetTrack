package com.vettrack.api.treatment;

import com.vettrack.api.audit.AuditLogRepository;
import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.storage.StorageService;
import com.vettrack.api.notification.NotificationService;
import com.vettrack.api.notification.NotificationType;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TreatmentServiceMutationGuardTest {

    @Mock
    private TreatmentEntryRepository treatmentEntryRepository;

    @Mock
    private VisitRepository visitRepository;

    @Mock
    private AuditLogRepository auditLogRepository;

    @Mock
    private StorageService storageService;

    @Mock
    private PetRepository petRepository;

    @Mock
    private NotificationService notificationService;

    private TreatmentService treatmentService;

    private final UUID vetStaffId = UUID.randomUUID();
    private final UUID visitId = UUID.randomUUID();
    private final UUID treatmentId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        treatmentService = new TreatmentService(
                treatmentEntryRepository,
                visitRepository,
                auditLogRepository,
                storageService,
                petRepository,
                notificationService
        );
    }

    private TreatmentEntry createMockEntry(OffsetDateTime createdAt) {
        return TreatmentEntry.builder()
                .id(treatmentId)
                .visitId(visitId)
                .enteredBy(vetStaffId)
                .createdAt(createdAt)
                .title("Aşı Tedavisi")
                .type("vaccination")
                .status(TreatmentStatus.IN_PROGRESS)
                .build();
    }

    @Test
    @DisplayName("Kapalı (completed) ziyarette updateTreatment ConflictException fırlatmalı")
    void whenVisitIsCompleted_thenUpdateTreatmentThrowsConflictException() {
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(2));
        Visit completedVisit = Visit.builder().id(visitId).status("completed").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(completedVisit));

        TreatmentUpdateRequest request = new TreatmentUpdateRequest();
        request.setTitle("Yeni Başlık");

        ConflictException ex = assertThrows(ConflictException.class, () ->
                treatmentService.updateTreatment(treatmentId, request, vetStaffId)
        );

        assertEquals(ErrorCode.VISIT_CLOSED, ex.getErrorCode());
        verifyNoInteractions(auditLogRepository);
    }

    @Test
    @DisplayName("İptal edilmiş (cancelled) ziyarette updateTreatment ConflictException fırlatmalı")
    void whenVisitIsCancelled_thenUpdateTreatmentThrowsConflictException() {
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(2));
        Visit cancelledVisit = Visit.builder().id(visitId).status("cancelled").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(cancelledVisit));

        TreatmentUpdateRequest request = new TreatmentUpdateRequest();
        request.setTitle("Yeni Başlık");

        ConflictException ex = assertThrows(ConflictException.class, () ->
                treatmentService.updateTreatment(treatmentId, request, vetStaffId)
        );

        assertEquals(ErrorCode.VISIT_CLOSED, ex.getErrorCode());
        verifyNoInteractions(auditLogRepository);
    }

    @Test
    @DisplayName("Guard Sıralaması: Ziyaret kapalıysa 15 dk süre aşılmış olsa dahi öncelikle VISIT_CLOSED dönmeli")
    void whenVisitIsClosedAndEditWindowExpired_thenPrioritizesVisitClosedException() {
        // 20 dakika önce oluşturulmuş (zaman aşımı var) ama aynı zamanda visit de kapalı
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(20));
        Visit completedVisit = Visit.builder().id(visitId).status("completed").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(completedVisit));

        TreatmentUpdateRequest request = new TreatmentUpdateRequest();

        ConflictException ex = assertThrows(ConflictException.class, () ->
                treatmentService.updateTreatment(treatmentId, request, vetStaffId)
        );

        assertEquals(ErrorCode.VISIT_CLOSED, ex.getErrorCode());
    }

    @Test
    @DisplayName("Kapalı ziyarette deleteTreatment ConflictException fırlatmalı")
    void whenVisitIsClosed_thenDeleteTreatmentThrowsConflictException() {
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(2));
        Visit completedVisit = Visit.builder().id(visitId).status("completed").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(completedVisit));

        ConflictException ex = assertThrows(ConflictException.class, () ->
                treatmentService.deleteTreatment(treatmentId, vetStaffId)
        );

        assertEquals(ErrorCode.VISIT_CLOSED, ex.getErrorCode());
        verifyNoInteractions(auditLogRepository);
    }

    @Test
    @DisplayName("Kapalı ziyarette dosya yükleme URL'i oluşturma ConflictException fırlatmalı")
    void whenVisitIsClosed_thenGenerateAttachmentUploadUrlThrowsConflictException() {
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(2));
        Visit completedVisit = Visit.builder().id(visitId).status("completed").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(completedVisit));

        ConflictException ex = assertThrows(ConflictException.class, () ->
                treatmentService.generateAttachmentUploadUrl(treatmentId, "image/png", 1024L, vetStaffId)
        );

        assertEquals(ErrorCode.VISIT_CLOSED, ex.getErrorCode());
        verifyNoInteractions(storageService);
    }

    @Test
    @DisplayName("Ziyaret ID'si veritabanında bulunamazsa ResourceNotFoundException fırlatmalı")
    void whenVisitNotFound_thenThrowsResourceNotFoundException() {
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(2));

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () ->
                treatmentService.deleteTreatment(treatmentId, vetStaffId)
        );
    }

    @Test
    @DisplayName("Açık (ongoing) ziyarette ve 15 dk pencere içindeyken deleteTreatment başarıyla çalışmalı")
    void whenVisitIsOngoing_thenDeleteTreatmentSucceeds() {
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(2));
        Visit ongoingVisit = Visit.builder().id(visitId).status("ongoing").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));

        treatmentService.deleteTreatment(treatmentId, vetStaffId);

        verify(treatmentEntryRepository).delete(entry);
        verify(auditLogRepository).save(any());
    }

    @Test
    @DisplayName("Açık (ongoing) ziyarette ve 15 dk pencere içindeyken generateAttachmentUploadUrl başarıyla çalışmalı")
    void whenVisitIsOngoing_thenGenerateAttachmentUploadUrlSucceeds() {
        TreatmentEntry entry = createMockEntry(OffsetDateTime.now().minusMinutes(2));
        Visit ongoingVisit = Visit.builder().id(visitId).status("ongoing").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));
        when(storageService.generateSignedUploadUrl(anyString(), anyString(), anyLong())).thenReturn("http://upload.url");

        String url = treatmentService.generateAttachmentUploadUrl(treatmentId, "image/png", 1024L, vetStaffId);

        assertNotNull(url);
        verify(treatmentEntryRepository).save(entry);
    }

    @Test
    @DisplayName("Tedavi oluşturulunca sahibine anlık bildirim gönderilmeli")
    void createTreatment_sendsImmediateOwnerNotification() {
        UUID petId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        Visit ongoingVisit = Visit.builder().id(visitId).petId(petId).status("ongoing").build();
        Pet pet = Pet.builder().id(petId).ownerId(ownerId).name("Pamuk").species("Kedi").build();
        TreatmentEntry savedEntry = TreatmentEntry.builder()
                .id(treatmentId).visitId(visitId).title("Kuduz aşısı")
                .type("vaccine").status(TreatmentStatus.PLANNED).build();

        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));
        when(petRepository.findById(petId)).thenReturn(Optional.of(pet));
        when(treatmentEntryRepository.save(any(TreatmentEntry.class))).thenReturn(savedEntry);

        TreatmentCreateRequest request = new TreatmentCreateRequest();
        request.setType("vaccine");
        request.setTitle("Kuduz aşısı");

        TreatmentEntry result = treatmentService.createTreatment(visitId, request, vetStaffId);

        assertEquals(treatmentId, result.getId());
        assertTrue(Boolean.TRUE.equals(result.getNotificationSent()));
        verify(notificationService).sendNotificationToOwner(
                eq(ownerId), eq(petId), eq(NotificationType.TREATMENT),
                anyString(), anyString(), eq(treatmentId));
    }

    @Test
    @DisplayName("Bildirim kaydı oluşturulamazsa tedavi gönderilmiş olarak işaretlenmemeli")
    void createTreatment_doesNotMarkNotificationSentWhenNotificationFails() {
        UUID petId = UUID.randomUUID();
        UUID ownerId = UUID.randomUUID();
        Visit ongoingVisit = Visit.builder().id(visitId).petId(petId).status("ongoing").build();
        Pet pet = Pet.builder().id(petId).ownerId(ownerId).name("Pamuk").species("Kedi").build();
        TreatmentEntry savedEntry = TreatmentEntry.builder()
                .id(treatmentId).visitId(visitId).title("Kuduz aşısı")
                .type("vaccine").status(TreatmentStatus.PLANNED).build();

        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));
        when(petRepository.findById(petId)).thenReturn(Optional.of(pet));
        when(treatmentEntryRepository.save(any(TreatmentEntry.class))).thenReturn(savedEntry);
        doThrow(new IllegalStateException("notification unavailable"))
                .when(notificationService)
                .sendNotificationToOwner(
                        eq(ownerId), eq(petId), eq(NotificationType.TREATMENT),
                        anyString(), anyString(), eq(treatmentId));

        TreatmentCreateRequest request = new TreatmentCreateRequest();
        request.setType("vaccine");
        request.setTitle("Kuduz aşısı");

        assertThrows(IllegalStateException.class, () ->
                treatmentService.createTreatment(visitId, request, vetStaffId));
        assertFalse(Boolean.TRUE.equals(savedEntry.getNotificationSent()));
    }
}
