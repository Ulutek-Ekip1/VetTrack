package com.vettrack.api.treatment;

import com.vettrack.api.common.exception.EditWindowExpiredException;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TreatmentService {

    private final TreatmentEntryRepository treatmentEntryRepository;
    private final VisitRepository visitRepository;

    private static final int EDIT_WINDOW_MINUTES = 15;

    @Transactional
    public TreatmentEntry createTreatment(UUID visitId, TreatmentCreateRequest request, UUID vetStaffId) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı"));

        if (!"ongoing".equals(visit.getStatus())) {
            throw new ConflictException("Kapalı ziyarete tedavi girişi yapılamaz");
        }

        TreatmentEntry entry = TreatmentEntry.builder()
                .visitId(visitId)
                .entryType(request.getEntryType())
                .title(request.getTitle())
                .description(request.getDescription())
                .attachmentUrl(request.getAttachmentUrl())
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

    @Transactional
    public TreatmentEntry updateTreatment(UUID treatmentId, TreatmentUpdateRequest request, UUID vetStaffId) {
        TreatmentEntry entry = getTreatmentById(treatmentId);
        checkOwnership(entry, vetStaffId);
        checkEditWindow(entry);

        if (request.getEntryType() != null) entry.setEntryType(request.getEntryType());
        if (request.getTitle() != null) entry.setTitle(request.getTitle());
        if (request.getDescription() != null) entry.setDescription(request.getDescription());
        if (request.getAttachmentUrl() != null) entry.setAttachmentUrl(request.getAttachmentUrl());
        if (request.getStatus() != null) entry.setStatus(request.getStatus());

        return treatmentEntryRepository.save(entry);
    }

    @Transactional
    public void deleteTreatment(UUID treatmentId, UUID vetStaffId) {
        TreatmentEntry entry = getTreatmentById(treatmentId);
        checkOwnership(entry, vetStaffId);
        checkEditWindow(entry);
        treatmentEntryRepository.delete(entry);
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
        if (entry.getCreatedAt().plusMinutes(EDIT_WINDOW_MINUTES).isBefore(OffsetDateTime.now())) {
            throw new EditWindowExpiredException("15 dakikalık düzenleme süresi doldu");
        }
    }
}