package com.vettrack.api.clinic;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.UUID;

/** Resolves clinic scope on the server; client-provided identifiers are never trusted alone. */
@Service
@RequiredArgsConstructor
public class ClinicAccessService {
    private final ClinicMembershipService membershipService;
    private final VisitRepository visitRepository;

    public void requireClinicAccess(UUID userId, UUID clinicId) {
        if (clinicId == null) throw new AccessDeniedException("Klinik bağlamı zorunludur.");
        membershipService.getActiveMembership(userId, clinicId);
    }

    public Visit requireVisitAccess(UUID userId, UUID visitId) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı."));
        requireClinicAccess(userId, visit.getClinicId());
        return visit;
    }
}
