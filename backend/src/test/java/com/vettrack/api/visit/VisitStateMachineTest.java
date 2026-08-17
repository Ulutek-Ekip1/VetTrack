package com.vettrack.api.visit;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.notification.NotificationService;
import com.vettrack.api.pet.Gender;
import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VisitStateMachineTest {

    @Mock
    private VisitRepository visitRepository;

    @Mock
    private PetService petService;

    @Mock
    private NotificationService notificationService;

    @InjectMocks
    private VisitService visitService;

    private UUID visitId;
    private UUID petId;
    private Visit ongoingVisit;

    @BeforeEach
    void setUp() {
        visitId = UUID.randomUUID();
        petId = UUID.randomUUID();

        ongoingVisit = Visit.builder()
                .id(visitId)
                .petId(petId)
                .clinicId(UUID.randomUUID())
                .vetStaffId(UUID.randomUUID())
                .status("ongoing")
                .startedAt(OffsetDateTime.now().minusHours(1))
                .build();
    }

    @Test
    @DisplayName("ongoing durumundaki ziyaret completed yapılabilmeli")
    void shouldTransitionFromOngoingToCompleted() {
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));
        when(visitRepository.save(any(Visit.class))).thenAnswer(inv -> inv.getArgument(0));

        Pet pet = Pet.builder()
                .id(petId)
                .ownerId(UUID.randomUUID())
                .name("Pamuk")
                .species("Kedi")
                .gender(Gender.female)
                .uniqueCode("ABC123")
                .build();
        when(petService.getPetById(petId)).thenReturn(pet);

        Visit result = visitService.updateVisitStatus(visitId, "completed");

        assertNotNull(result);
        assertEquals("completed", result.getStatus());
        assertNotNull(result.getEndedAt());
    }

    @Test
    @DisplayName("ongoing durumundaki ziyaret cancelled yapılabilmeli")
    void shouldTransitionFromOngoingToCancelled() {
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));
        when(visitRepository.save(any(Visit.class))).thenAnswer(inv -> inv.getArgument(0));

        Visit result = visitService.updateVisitStatus(visitId, "cancelled");

        assertNotNull(result);
        assertEquals("cancelled", result.getStatus());
        assertNotNull(result.getEndedAt());
    }

    @Test
    @DisplayName("completed durumundaki ziyaret tekrar ongoing yapılamamalı (409 Conflict)")
    void shouldRejectTransitionFromCompletedToOngoing() {
        ongoingVisit.setStatus("completed");
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));

        assertThrows(ConflictException.class, () -> visitService.updateVisitStatus(visitId, "ongoing"));
    }

    @Test
    @DisplayName("cancelled durumundaki ziyaret tekrar ongoing yapılamamalı (409 Conflict)")
    void shouldRejectTransitionFromCancelledToOngoing() {
        ongoingVisit.setStatus("cancelled");
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));

        assertThrows(ConflictException.class, () -> visitService.updateVisitStatus(visitId, "ongoing"));
    }

    @Test
    @DisplayName("completed durumundaki ziyaret cancelled yapılamamalı (409 Conflict)")
    void shouldRejectTransitionFromCompletedToCancelled() {
        ongoingVisit.setStatus("completed");
        when(visitRepository.findById(visitId)).thenReturn(Optional.of(ongoingVisit));

        assertThrows(ConflictException.class, () -> visitService.updateVisitStatus(visitId, "cancelled"));
    }
}
