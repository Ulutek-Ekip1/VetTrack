package com.vettrack.api.visit;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
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

    @Transactional
    public Visit createVisit(UUID petId, UUID vetStaffId) {
        Pet pet = petService.getPetById(petId);

        // Eşzamanlı Ziyaret Kilidi (EC-02): Repository'deki findByPetIdAndStatus metodunu kullanıyoruz
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

        return visitRepository.save(visit);
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
}
