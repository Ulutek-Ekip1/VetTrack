package com.vettrack.api.ai;

import com.vettrack.api.ai.service.PetContextService;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.treatment.TreatmentEntry;
import com.vettrack.api.treatment.TreatmentEntryRepository;
import com.vettrack.api.treatment.TreatmentStatus;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class PetContextServiceTest {

    @Mock
    private PetRepository petRepository;

    @Mock
    private VisitRepository visitRepository;

    @Mock
    private TreatmentEntryRepository treatmentEntryRepository;

    @InjectMocks
    private PetContextService petContextService;

    private UUID petId;
    private Pet testPet;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        petId = UUID.randomUUID();
        testPet = Pet.builder()
                .id(petId)
                .name("Pamuk")
                .species("Kedi")
                .breed("Tekir")
                .gender(Gender.female)
                .birthDate(LocalDate.of(2021, 5, 10))
                .isActive(true)
                .deletedAt(null)
                .build();
    }

    @Test
    void testBuildPetContext_Success() {
        when(petRepository.findById(petId)).thenReturn(Optional.of(testPet));

        UUID visitId = UUID.randomUUID();
        Visit visit = Visit.builder().id(visitId).petId(petId).build();
        when(visitRepository.findByPetIdOrderByStartedAtDesc(petId)).thenReturn(List.of(visit));

        TreatmentEntry treatment = TreatmentEntry.builder()
                .id(UUID.randomUUID())
                .visitId(visitId)
                .entryType("Aşı")
                .title("Kuduz Aşısı")
                .description("Yıllık kuduz aşısı uygulandı")
                .status(TreatmentStatus.COMPLETED)
                .build();
        when(treatmentEntryRepository.findByVisitIdOrderByStartDateDesc(visitId)).thenReturn(List.of(treatment));

        String context = petContextService.buildPetContext(petId);

        assertNotNull(context);
        assertTrue(context.contains("Pamuk"));
        assertTrue(context.contains("Kedi"));
        assertTrue(context.contains("Tekir"));
        assertTrue(context.contains("Kuduz Aşısı"));
    }

    @Test
    void testBuildPetContext_SoftDeletedPet_ReturnsInactiveMessage() {
        testPet.setDeletedAt(OffsetDateTime.now());
        when(petRepository.findById(petId)).thenReturn(Optional.of(testPet));

        String context = petContextService.buildPetContext(petId);

        assertTrue(context.contains("aktif değil veya silinmiş"));
        verifyNoInteractions(visitRepository);
    }
}
