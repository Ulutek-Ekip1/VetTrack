package com.vettrack.api.auth;

import com.vettrack.api.pet.PetService;
import com.vettrack.api.visit.VisitService;
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

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verifyNoInteractions;

@ExtendWith(MockitoExtension.class)
class AccessControlServiceTest {

    @Mock private PetService petService;
    @Mock private VisitService visitService;

    @InjectMocks private AccessControlService accessControlService;

    @Test
    void ownerCannotPassVetOnlyGuard() {
        assertThatThrownBy(() -> accessControlService.requireVetOrAdmin(jwt("owner")))
                .isInstanceOf(AccessDeniedException.class);
        verifyNoInteractions(petService, visitService);
    }

    @Test
    void vetStaffCanPassVetOnlyGuard() {
        assertThatCode(() -> accessControlService.requireVetOrAdmin(jwt("vet_staff")))
                .doesNotThrowAnyException();
    }

    @Test
    void adminRoleCanComeFromTopLevelJwtClaim() {
        Instant now = Instant.now();
        Jwt jwt = new Jwt(
                "token",
                now,
                now.plusSeconds(300),
                Map.of("alg", "none"),
                Map.of("sub", UUID.randomUUID().toString(), "role", "admin")
        );

        assertThatCode(() -> accessControlService.requireVetOrAdmin(jwt))
                .doesNotThrowAnyException();
    }

    private Jwt jwt(String role) {
        Instant now = Instant.now();
        return new Jwt(
                "token",
                now,
                now.plusSeconds(300),
                Map.of("alg", "none"),
                Map.of("sub", UUID.randomUUID().toString(), "user_metadata", Map.of("role", role))
        );
    }
}
