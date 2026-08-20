package com.vettrack.api.visit;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VisitService {

    private final VisitRepository visitRepository;
    private final PetService petService;
    private final NotificationService notificationService;

    @Transactional
    public Visit createVisit(UUID petId, UUID vetStaffId) {
        Pet pet = petService.getPetById(petId);

        boolean hasActiveVisit = visitRepository.findByPetIdAndStatus(pet.getId(), "ongoing").isPresent();
        if (hasActiveVisit) {
            throw new ConflictException(ErrorCode.VISIT_ALREADY_OPEN, "Bu evcil hayvanın devam eden aktif bir muayenesi/ziyareti bulunmaktadır.");
        }

        Visit visit = Visit.builder()
                .petId(pet.getId())
                .vetStaffId(vetStaffId)
                .status("ongoing")
                .startedAt(OffsetDateTime.now())
                .build();
        return visitRepository.save(visit);
    }

    @Transactional
    public Visit createVisit(UUID petId, UUID vetStaffId, UUID clinicId, String chiefComplaint) {
        Pet pet = petService.getPetById(petId);
        if (visitRepository.findByPetIdAndStatus(pet.getId(), "ongoing").isPresent()) {
            throw new ConflictException(ErrorCode.VISIT_ALREADY_OPEN, "Bu evcil hayvanın devam eden aktif bir muayenesi/ziyareti bulunmaktadır.");
        }
        return visitRepository.save(Visit.builder().petId(pet.getId()).vetStaffId(vetStaffId)
                .clinicId(clinicId).chiefComplaint(chiefComplaint).status("ongoing")
                .startedAt(OffsetDateTime.now()).build());
    }

    @Transactional
    public Visit createVisit(VisitCreateRequest request) {
        boolean hasActiveVisit = visitRepository.findByPetIdAndStatus(request.getPetId(), "ongoing").isPresent();
        if (hasActiveVisit) {
            throw new ConflictException(ErrorCode.VISIT_ALREADY_OPEN, "Bu evcil hayvanın devam eden aktif bir muayenesi/ziyareti bulunmaktadır.");
        }
        Visit visit = Visit.builder()
                .petId(request.getPetId())
                .vetStaffId(request.getVetStaffId())
                .clinicId(request.getClinicId())
                .chiefComplaint(request.getChiefComplaint())
                .status("ongoing")
                .startedAt(OffsetDateTime.now())
                .build();
        return visitRepository.save(visit);
    }

    @Transactional
    public Visit closeVisit(UUID visitId) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı ID: " + visitId));

        if (!"ongoing".equalsIgnoreCase(visit.getStatus())) {
            throw new ConflictException(ErrorCode.VISIT_ALREADY_CLOSED, "Bu ziyaret zaten kapatılmış veya tamamlanmış.");
        }

        visit.setStatus("completed");
        visit.setEndedAt(OffsetDateTime.now());

        Visit closedVisit = visitRepository.save(visit);
        Pet pet = petService.getPetById(visit.getPetId());
        notificationService.sendVisitClosedNotification(pet.getOwnerId(), pet.getId(), closedVisit.getId());
        return closedVisit;
    }

    @Transactional(readOnly = true)
    public List<Visit> getVisitsByUniqueCode(String uniqueCode) {
        Pet pet = petService.getPetByUniqueCode(uniqueCode);
        return visitRepository.findByPetIdOrderByStartedAtDesc(pet.getId());
    }

    @Transactional(readOnly = true)
    public List<Visit> getVisitsByPetId(UUID petId) {
        return visitRepository.findByPetIdOrderByStartedAtDesc(petId);
    }

    /** Sahibin tüm aktif (soft-delete edilmemiş) petlerinin ziyaret geçmişi — tek sorgu. */
    @Transactional(readOnly = true)
    public List<Visit> getVisitsForOwner(UUID ownerId) {
        return visitRepository.findVisitsForOwner(ownerId);
    }

    /** Veteriner hekime atanmış tüm ziyaretler (silinmiş/pasif petlerinki hariç). */
    @Transactional(readOnly = true)
    public List<Visit> getVisitsForVet(UUID vetStaffId) {
        return visitRepository.findVisitsForVet(vetStaffId);
    }

    @Transactional(readOnly = true)
    public List<Visit> getVisitsByPetIdAndClinicId(UUID petId, UUID clinicId) {
        return visitRepository.findByPetIdAndClinicIdOrderByStartedAtDesc(petId, clinicId);
    }

    /** Vet'in cross-clinic tüm ziyaret geçmişini görmesini engeller — sadece kendi aktif kliniklerine ait ziyaretler. */
    @Transactional(readOnly = true)
    public List<Visit> getVisitsByPetIdAndClinicIds(UUID petId, List<UUID> clinicIds) {
        return visitRepository.findByPetIdAndClinicIdInOrderByStartedAtDesc(petId, clinicIds);
    }

    @Transactional(readOnly = true)
    public Page<Visit> getVisitsByPetIdPaginated(UUID petId, Pageable pageable) {
        return visitRepository.findByPetIdOrderByStartedAtDesc(petId, pageable);
    }

    @Transactional(readOnly = true)
    public Page<Visit> getVisitsByPetIdAndClinicIdsPaginated(UUID petId, List<UUID> clinicIds, Pageable pageable) {
        return visitRepository.findByPetIdAndClinicIdInOrderByStartedAtDesc(petId, clinicIds, pageable);
    }

    @Transactional(readOnly = true)
    public Visit getVisit(UUID visitId) {
        return visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı"));
    }

    @Transactional(readOnly = true)
    public Visit getVisitById(UUID id) {
        return visitRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Ziyaret kaydı bulunamadı: " + id));
    }

    @Transactional
    public Visit updateVisitStatus(UUID id, String status) {
        if (status == null || status.isBlank()) {
            throw new IllegalArgumentException("Ziyaret durumu boş olamaz.");
        }
        String normalized = status.toLowerCase().trim();

        // API-CONTRACT-01 fix: kabul edilen ve fiilen kalıcı olan durumlar tek kaynağa
        // indirildi (bkz. docs/openapi.yaml VisitResponse.status enum). "ended" eskiden
        // "completed" için sessiz bir eş anlamlıydı — hiçbir istemci hiç göndermiyordu
        // (grep ile doğrulandı) ve hiçbir zaman kalıcı bir status değeri olarak
        // saklanmıyordu, kaldırıldı.
        if (!List.of("ongoing", "completed", "cancelled").contains(normalized)) {
            throw new IllegalArgumentException("Geçersiz ziyaret durumu: " + status + ". İzin verilen durumlar: completed, cancelled.");
        }

        Visit visit = visitRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı ID: " + id));

        if (!"ongoing".equalsIgnoreCase(visit.getStatus())) {
            throw new ConflictException(ErrorCode.VISIT_ALREADY_CLOSED,
                    "Geçersiz durum geçişi: " + visit.getStatus() + " durumundaki bir ziyaret güncellenemez.");
        }

        if ("ongoing".equals(normalized)) {
            throw new ConflictException(ErrorCode.VISIT_ALREADY_OPEN,
                    "Geçersiz durum geçişi: Ziyaret zaten devam etmektedir.");
        }

        if ("completed".equals(normalized)) {
            return closeVisit(id);
        }

        if ("cancelled".equals(normalized)) {
            visit.setStatus("cancelled");
            visit.setEndedAt(OffsetDateTime.now());
            return visitRepository.save(visit);
        }

        throw new IllegalArgumentException("Geçersiz ziyaret durumu: " + status);
    }
}
