package com.vettrack.api.visit;

import com.vettrack.api.auth.AccessControlService;
import com.vettrack.api.owner.OwnerService;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.vetstaff.VetStaff;
import com.vettrack.api.vetstaff.VetStaffService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class VisitControllerTest {

    @Mock private VisitService visitService;
    @Mock private PetService petService;
    @Mock private VetStaffService vetStaffService;
    @Mock private OwnerService ownerService;
    @Mock private AccessControlService accessControlService;

    @InjectMocks private VisitController visitController;

    @Test
    void ownerCannotCreateVisitOrTriggerVetStaffProvisioning() {
        UUID userId = UUID.randomUUID();
        Jwt ownerJwt = jwt(userId, "owner");
        doThrow(new AccessDeniedException("Bu işlem yalnızca veteriner personel tarafından yapılabilir"))
                .when(accessControlService).requireVetOrAdmin(ownerJwt);

        assertThatThrownBy(() -> visitController.createVisit(
                ownerJwt, createRequest()
        )).isInstanceOf(AccessDeniedException.class);

        verify(vetStaffService, never()).getOrCreateByUserId(any(), any());
        verify(visitService, never()).createVisit(any(), any());
    }

    @Test
    void vetStaffCanCreateVisit() {
        UUID userId = UUID.randomUUID();
        UUID petId = UUID.randomUUID();
        UUID vetStaffId = UUID.randomUUID();
        VetStaff vetStaff = org.mockito.Mockito.mock(VetStaff.class);
        Visit visit = org.mockito.Mockito.mock(Visit.class);

        when(vetStaff.getId()).thenReturn(vetStaffId);
        when(vetStaffService.getOrCreateByUserId(eq(userId), any(Jwt.class))).thenReturn(vetStaff);
        when(visitService.createVisit(petId, vetStaffId)).thenReturn(visit);

        VisitCreateRequest request = new VisitCreateRequest();
        request.setPetId(petId);
        Jwt vetJwt = jwt(userId, "vet_staff");
        visitController.createVisit(vetJwt, request);

        verify(accessControlService).requireVetOrAdmin(vetJwt);
        verify(vetStaffService).getOrCreateByUserId(eq(userId), any(Jwt.class));
        verify(visitService).createVisit(petId, vetStaffId);
    }

    private VisitCreateRequest createRequest() {
        VisitCreateRequest request = new VisitCreateRequest();
        request.setPetId(UUID.randomUUID());
        return request;
    }

    private Jwt jwt(UUID userId, String role) {
        Instant now = Instant.now();
        return new Jwt(
                "token",
                now,
                now.plusSeconds(300),
                Map.of("alg", "none"),
                Map.of("sub", userId.toString(), "user_metadata", Map.of("role", role))
        );
    }
}
