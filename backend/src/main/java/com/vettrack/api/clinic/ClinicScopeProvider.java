package com.vettrack.api.clinic;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Helper component that extracts the list of active clinic IDs for the authenticated user.
 * It uses {@link ClinicMembershipService} which already provides membership lookup.
 */
@Component
@RequiredArgsConstructor
public class ClinicScopeProvider {
    private final ClinicMembershipService membershipService;

    /**
     * Returns a list of clinic UUIDs where the user has an active membership.
     */
    public List<UUID> getActiveClinicIds(UUID userId) {
        return membershipService.getMembershipsByUser(userId).stream()
                .filter(m -> "active".equalsIgnoreCase(m.getStatus()))
                .map(ClinicMembership::getClinicId)
                .collect(Collectors.toList());
    }
}
