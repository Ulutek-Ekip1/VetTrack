package com.vettrack.api.clinic;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;
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

    /** Kullanıcının aktif üyeliği bulunan tüm kliniklerin id listesi (boş liste = hiç aktif üyelik yok). */
    public List<UUID> getActiveClinicIds(UUID userId) {
        return membershipService.getMembershipsByUser(userId).stream()
                .filter(m -> "active".equalsIgnoreCase(m.getStatus()))
                .map(ClinicMembership::getClinicId)
                .toList();
    }

    /**
     * Bir vet_staff/admin'in bir pet'e "klinik bağlamı" üzerinden erişimi olup olmadığını doğrular:
     * pet'in en az bir ziyareti, çağıranın aktif üyeliği olan kliniklerden birine ait olmalıdır.
     * "Vet olmak" tek başına yeterli değildir — BOLA/cross-clinic sızıntısını önler.
     */
    public void requirePetAccessForVet(UUID userId, UUID petId) {
        List<UUID> activeClinicIds = getActiveClinicIds(userId);
        if (activeClinicIds.isEmpty() || !visitRepository.existsByPetIdAndClinicIdIn(petId, activeClinicIds)) {
            throw new AccessDeniedException("Bu hayvana klinik bağlamında erişim yetkiniz yok.");
        }
    }
}
