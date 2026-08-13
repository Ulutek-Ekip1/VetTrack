package com.vettrack.api.vetstaff;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

/**
 * Manages VetStaff (clinic_staff) profiles.
 * <p>
 * Supports Just-In-Time (JIT) profile provisioning: when a Supabase-authenticated user hits
 * a protected endpoint for the first time (e.g. after Google OAuth login) their VetStaff row
 * is created automatically from JWT claims.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class VetStaffService {

    // Gerçek Supabase şemasında clinic_staff_staff_role_check sadece 'doctor'/'staff'
    // kabul ediyor — 'vet' bu constraint'i ihlal edip her JIT provisioning'i 500'e düşürüyordu.
    private static final String DEFAULT_STAFF_ROLE = "doctor";

    private final VetStaffRepository vetStaffRepository;

    /**
     * Returns the VetStaff row for the given Supabase user id, creating it on first access.
     * <p>
     * Called from AuthController.me when the JWT role claim resolves to 'vet_staff'.
     * <p>
     * Concurrency: if two requests race on the very first login, one INSERT will win and the
     * other will hit the UNIQUE(user_id) constraint. We catch DataIntegrityViolationException
     * and re-read the row.
     */
    @Transactional
    public VetStaff getOrCreateByUserId(UUID userId, Jwt jwt) {
        return vetStaffRepository.findByUserId(userId)
                .orElseGet(() -> createFromJwt(userId, jwt));
    }

    private VetStaff createFromJwt(UUID userId, Jwt jwt) {
        String staffRole = resolveStaffRole(jwt);

        VetStaff vetStaff = VetStaff.builder()
                .userId(userId)
                .staffRole(staffRole)
                .isActive(true)
                .build();

        try {
            VetStaff saved = vetStaffRepository.save(vetStaff);
            log.info("VetStaff JIT-provisioned userId={} role={}", userId, staffRole);
            return saved;
        } catch (DataIntegrityViolationException ex) {
            // Race condition — another request created the row first. Read it back.
            log.info("VetStaff JIT race resolved for userId={}", userId);
            return vetStaffRepository.findByUserId(userId)
                    .orElseThrow(() -> ex);
        }
    }

    private String resolveStaffRole(Jwt jwt) {
        Map<String, Object> userMetadata = jwt.getClaim("user_metadata");
        if (userMetadata != null) {
            Object staffRoleClaim = userMetadata.get("staff_role");
            if (staffRoleClaim instanceof String value && !value.isBlank()) {
                return value;
            }
        }
        return DEFAULT_STAFF_ROLE;
    }
}
