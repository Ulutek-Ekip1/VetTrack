package com.vettrack.api.visit;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.notification.NotificationService;
import lombok.RequiredArgsConstructor;
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
    private final PetRepository petRepository;
    private final NotificationService notificationService;

    @Transactional
    public Visit createVisit(UUID petId, UUID vetStaffId) {
        // Lock the parent pet row first. Concurrent requests for the same pet
        // serialize here; after the first transaction commits, the second one
        // observes its ongoing visit and receives the documented 409 response.
        Pet pet = petRepository.findByIdForVisitCreation(petId)
                .orElseThrow(() -> new ResourceNotFoundException("Evcil hayvan bulunamadı ID: " + petId));
        if (pet.getDeletedAt() != null) {
            throw new ResourceNotFoundException("Evcil hayvan bulunamadı ID: " + petId);
        }

        boolean hasActiveVisit = visitRepository.findByPetIdAndStatus(pet.getId(), "ongoing").isPresent();
        if (hasActiveVisit) {
            throw new ConflictException("Bu evcil hayvanın devam eden aktif bir muayenesi/ziyareti bulunmaktadır.");
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
    public Visit closeVisit(UUID visitId) {
        Visit visit = visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı ID: " + visitId));

        if (!"ongoing".equalsIgnoreCase(visit.getStatus())) {
            throw new ConflictException("Bu ziyaret zaten kapatılmış veya tamamlanmış.");
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
        petService.getPetById(petId);
        return visitRepository.findByPetIdOrderByStartedAtDesc(petId);
    }

    @Transactional(readOnly = true)
    public Visit getVisit(UUID visitId) {
        return visitRepository.findById(visitId)
                .orElseThrow(() -> new ResourceNotFoundException("Ziyaret bulunamadı"));
    }
}
