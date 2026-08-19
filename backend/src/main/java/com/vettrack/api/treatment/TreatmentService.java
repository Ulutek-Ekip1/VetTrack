package com.vettrack.api.treatment;

import com.vettrack.api.audit.AuditLog;
import com.vettrack.api.audit.AuditLogRepository;
import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.EditWindowExpiredException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.storage.StorageService;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TreatmentService {

    private final TreatmentEntryRepository treatmentEntryRepository;
    private final VisitRepository visitRepository;
    private final AuditLogRepository auditLogRepository;
    private final StorageService storageService;

    private static final int EDIT_WINDOW_MINUTES = 15;

    @Transactional
    public TreatmentEntry createTreatment(UUID visitId, TreatmentCreateRequest request, UUID vetStaffId) {
        checkVisitOngoing(visitId);

        TreatmentEntry entry = TreatmentEntry.builder()
                .visitId(visitId)
                .type(request.getType())
                .title(request.getTitle())
                .description(request.getDescription())
                .status(request.getStatus() != null ? request.getStatus() : TreatmentStatus.PLANNED)
                .startDate(OffsetDateTime.now())
                .enteredBy(vetStaffId)
                .build();

        return treatmentEntryRepository.save(entry);
    }

    @Transactional(readOnly = true)
    public List<TreatmentEntry> getTreatmentsByVisit(UUID visitId, TreatmentStatus status) {
        visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı"));

        if (status != null) {
            return treatmentEntryRepository.findByVisitIdAndStatusOrderByStartDateDesc(visitId, status);
        }
        return treatmentEntryRepository.findByVisitIdOrderByStartDateDesc(visitId);
    }

    @Transactional(readOnly = true)
    public List<TreatmentEntry> getTreatmentsByPet(UUID petId) {
        return visitRepository.findByPetIdOrderByStartedAtDesc(petId).stream()
                .flatMap(visit -> treatmentEntryRepository.findByVisitIdOrderByStartDateDesc(visit.getId()).stream())
                .sorted(Comparator.comparing(TreatmentEntry::getStartDate, Comparator.nullsLast(Comparator.reverseOrder())))
                .toList();
    }

    @Transactional(readOnly = true)
    public UUID getVisitIdForTreatment(UUID treatmentId) {
        return getTreatmentById(treatmentId).getVisitId();
    }

    @Transactional
    public TreatmentEntry updateTreatment(UUID treatmentId, TreatmentUpdateRequest request, UUID vetStaffId) {
        TreatmentEntry entry = getTreatmentById(treatmentId);
        checkOwnership(entry, vetStaffId);
        checkVisitOngoing(entry.getVisitId());
        checkEditWindow(entry);

        if (request.getType() != null) entry.setType(request.getType());
        if (request.getTitle() != null) entry.setTitle(request.getTitle());
        if (request.getDescription() != null) entry.setDescription(request.getDescription());
        if (request.getStatus() != null) entry.setStatus(request.getStatus());

        TreatmentEntry updatedEntry = treatmentEntryRepository.save(entry);

        AuditLog auditLog = AuditLog.builder()
                .entityName("TreatmentEntry")
                .entityId(updatedEntry.getId())
                .action("UPDATE")
                .changedBy(vetStaffId)
                .details("Treatment entry updated within the 15-minute edit window. Title: " + updatedEntry.getTitle())
                .build();
        auditLogRepository.save(auditLog);

        return updatedEntry;
    }

    @Transactional
    public void deleteTreatment(UUID treatmentId, UUID vetStaffId) {
        TreatmentEntry entry = getTreatmentById(treatmentId);
        checkOwnership(entry, vetStaffId);
        checkVisitOngoing(entry.getVisitId());
        checkEditWindow(entry);

        treatmentEntryRepository.delete(entry);

        AuditLog auditLog = AuditLog.builder()
                .entityName("TreatmentEntry")
                .entityId(treatmentId)
                .action("DELETE")
                .changedBy(vetStaffId)
                .details("Treatment entry deleted within the 15-minute edit window.")
                .build();
        auditLogRepository.save(auditLog);
    }

    @Transactional
    public String generateAttachmentUploadUrl(UUID treatmentId, String contentType, long fileSize, UUID vetStaffId) {
        TreatmentEntry entry = getTreatmentById(treatmentId);
        checkOwnership(entry, vetStaffId);
        checkVisitOngoing(entry.getVisitId());
        checkEditWindow(entry);

        String path = "treatments/" + entry.getVisitId() + "/" + treatmentId;
        String signedUrl = storageService.generateSignedUploadUrl(path, contentType, fileSize);

        entry.setAttachmentUrl(path);
        treatmentEntryRepository.save(entry);

        return signedUrl;
    }

    @Transactional(readOnly = true)
    public String generateAttachmentReadUrl(UUID treatmentId) {
        TreatmentEntry entry = getTreatmentById(treatmentId);

        if (entry.getAttachmentUrl() == null || entry.getAttachmentUrl().isBlank()) {
            throw new ResourceNotFoundException("Bu tedavi kaydına ait ek bulunmamaktadır.");
        }

        return storageService.generateSignedReadUrl(entry.getAttachmentUrl());
    }

    private TreatmentEntry getTreatmentById(UUID id) {
        return treatmentEntryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tedavi kaydı bulunamadı"));
    }

    private void checkOwnership(TreatmentEntry entry, UUID vetStaffId) {
        if (!entry.getEnteredBy().equals(vetStaffId)) {
            throw new AccessDeniedException("Bu tedavi kaydı size ait değil");
        }
    }

    private void checkEditWindow(TreatmentEntry entry) {
        if (entry.getCreatedAt() != null && entry.getCreatedAt().plusMinutes(EDIT_WINDOW_MINUTES).isBefore(OffsetDateTime.now())) {
            throw new EditWindowExpiredException("15 dakikalık düzenleme süresi doldu");
        }
    }

    private void checkVisitOngoing(UUID visitId) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı"));

        if (!"ongoing".equalsIgnoreCase(visit.getStatus())) {
            throw new ConflictException(ErrorCode.VISIT_CLOSED, "Kapalı ziyaretteki tedavi kaydı değiştirilemez veya silinemez");
        }
    }
}