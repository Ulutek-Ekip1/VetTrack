package com.vettrack.api.visit;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.notification.NotificationService;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetRepository;
import com.vettrack.api.pet.PetService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VisitServiceTest {

    @Mock private VisitRepository visitRepository;
    @Mock private PetService petService;
    @Mock private PetRepository petRepository;
    @Mock private NotificationService notificationService;

    @InjectMocks private VisitService visitService;

    @Test
    void creationChecksForOngoingVisitOnlyAfterAcquiringPetLock() {
        UUID petId = UUID.randomUUID();
        Pet pet = Pet.builder().id(petId).build();
        Visit ongoingVisit = Visit.builder().id(UUID.randomUUID()).status("ongoing").build();
        when(petRepository.findByIdForVisitCreation(petId)).thenReturn(Optional.of(pet));
        when(visitRepository.findByPetIdAndStatus(petId, "ongoing"))
                .thenReturn(Optional.of(ongoingVisit));

        assertThatThrownBy(() -> visitService.createVisit(petId, UUID.randomUUID()))
                .isInstanceOf(ConflictException.class);

        verify(petRepository).findByIdForVisitCreation(petId);
        verify(visitRepository).findByPetIdAndStatus(petId, "ongoing");
        verify(visitRepository, never()).save(org.mockito.ArgumentMatchers.any());
    }
}
