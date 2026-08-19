package com.vettrack.api.treatment;

import com.vettrack.api.audit.AuditLogRepository;
import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.storage.StorageService;
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
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

/**
 * QA Bulgu BE-FINDING-04: Kapalı muayenedeki treatment kayıtları kilitli (immutable) olmalıdır.
 * 15 dakikalık pencere dolmamış olsa bile visit kapandıysa (completed/ended/cancelled)
 * hiçbir güncelleme, silme veya dosya yükleme işlemi yapılamaz.
 */
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
                storageService
        );
    }

    private TreatmentEntry createMockEntry() {
        return TreatmentEntry.builder()
                .id(treatmentId)
                .visitId(visitId)
                .enteredBy(vetStaffId)
                .createdAt(OffsetDateTime.now().minusMinutes(2)) // 15 dk edit penceresi içinde
                .title("Aşı Tedavisi")
                .type("vaccination")
                .status(TreatmentStatus.IN_PROGRESS)
                .build();
    }

    @Test
    @DisplayName("Kapalı (completed) ziyarette 15 dk pencere dolmamış olsa bile updateTreatment ConflictException fırlatmalı")
    void whenVisitIsClosed_thenUpdateTreatmentThrowsConflictException() {
        TreatmentEntry entry = createMockEntry();
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
    @DisplayName("Kapalı (completed) ziyarette 15 dk pencere dolmamış olsa bile deleteTreatment ConflictException fırlatmalı")
    void whenVisitIsClosed_thenDeleteTreatmentThrowsConflictException() {
        TreatmentEntry entry = createMockEntry();
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
    @DisplayName("Kapalı (completed) ziyarette dosya yükleme URL'i oluşturma ConflictException fırlatmalı")
    void whenVisitIsClosed_thenGenerateAttachmentUploadUrlThrowsConflictException() {
        TreatmentEntry entry = createMockEntry();
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
    @DisplayName("Açık (ongoing) ziyarette ve 15 dk pencere içindeyken updateTreatment başarıyla çalışmalı")
    void whenVisitIsOngoing_thenUpdateTreatmentSucceeds() {
        TreatmentEntry entry = createMockEntry();
        Visit ongoingVisit = Visit.builder().id(visitId).status("ongoing").build();

        when(treatmentEntryRepository.findById(treatmentId)).thenReturn(Optional.of(entry));
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));
        when(treatmentEntryRepository.save(any(TreatmentEntry.class))).thenReturn(entry);

        TreatmentUpdateRequest request = new TreatmentUpdateRequest();
        request.setTitle("Güncellenmiş Başlık");

        TreatmentEntry result = treatmentService.updateTreatment(treatmentId, request, vetStaffId);

        assertNotNull(result);
        verify(auditLogRepository).save(any());
    }
}
