package com.vettrack.api.auth;

import com.vettrack.api.pet.Pet;
import com.vettrack.api.pet.PetService;
import com.vettrack.api.visit.Visit;
import com.vettrack.api.visit.VisitService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

/**
 * Explicit endpoint authorization while Supabase roles are not yet mapped to
 * Spring Security authorities. Keep all role-claim parsing in one place.
 */
@Service
@RequiredArgsConstructor
public class AccessControlService {

    private final PetService petService;
    private final VisitService visitService;

    public void requireVetOrAdmin(Jwt jwt) {
        if (!isVetOrAdmin(jwt)) {
            throw new AccessDeniedException("Bu işlem yalnızca veteriner personel tarafından yapılabilir");
        }
    }

    public void requireVetOrOwnerOfPet(Jwt jwt, UUID petId) {
        if (isVetOrAdmin(jwt)) {
            return;
        }

        Pet pet = petService.getPetById(petId);
        if (!pet.getOwnerId().equals(userId(jwt))) {
            throw new AccessDeniedException("Bu hayvanın verilerine erişim yetkiniz yok");
        }
    }

    public void requireVetOrOwnerOfVisit(Jwt jwt, UUID visitId) {
        Visit visit = visitService.getVisit(visitId);
        requireVetOrOwnerOfPet(jwt, visit.getPetId());
    }

    private boolean isVetOrAdmin(Jwt jwt) {
        String role = resolveRole(jwt);
        return "vet_staff".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(role);
    }

    @SuppressWarnings("unchecked")
    private String resolveRole(Jwt jwt) {
        Object userMetadata = jwt.getClaim("user_metadata");
        if (userMetadata instanceof Map<?, ?> metadata) {
            Object role = metadata.get("role");
            if (role instanceof String roleValue && !roleValue.isBlank()) {
                return roleValue;
            }
        }

        String topLevelRole = jwt.getClaimAsString("role");
        return topLevelRole == null || topLevelRole.isBlank() ? "owner" : topLevelRole;
    }

    private UUID userId(Jwt jwt) {
        return UUID.fromString(jwt.getSubject());
    }
}
