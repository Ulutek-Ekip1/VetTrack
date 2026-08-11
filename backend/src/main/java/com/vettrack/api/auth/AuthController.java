package com.vettrack.api.auth;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerService;
import com.vettrack.api.vetstaff.VetStaff;
import com.vettrack.api.vetstaff.VetStaffService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final OwnerService ownerService;
    private final VetStaffService vetStaffService;

    /**
     * Returns the current user's identity plus their JIT-synced profile.
     * <p>
     * Frontend calls this on every app open / login. The role is resolved from the
     * Supabase JWT claim {@code user_metadata.role}, which is set by the frontend at
     * signup / OAuth time based on the platform (mobile → owner, web → vet_staff).
     * <p>
     * If the profile row does not exist yet (first login after Google OAuth), it is
     * created automatically from JWT claims (JIT provisioning).
     * <p>
     * Response keeps the legacy top-level {@code id}, {@code email}, {@code role} fields
     * for backward compatibility with existing frontend code, and adds a {@code profile}
     * object carrying the full owner/vet_staff row.
     */
    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> me(@AuthenticationPrincipal Jwt jwt) {
        if (jwt == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        UUID userId = UUID.fromString(jwt.getSubject());
        String role = resolveRole(jwt);

        Map<String, Object> response = new HashMap<>();
        response.put("id", jwt.getSubject());
        response.put("email", jwt.getClaimAsString("email"));
        response.put("role", role);

        if ("vet_staff".equalsIgnoreCase(role)) {
            VetStaff vetStaff = vetStaffService.getOrCreateByUserId(userId, jwt);
            response.put("profile", vetStaff);
        } else {
            // Default to owner for any role that is not explicitly vet_staff, including
            // legacy tokens without a role claim.
            Owner owner = ownerService.getOwnerById(userId);
            response.put("profile", owner);
        }

        return ResponseEntity.ok(response);
    }

    /**
     * Reads the role from user_metadata.role first (set by frontend at signup / OAuth),
     * falling back to the top-level 'role' claim for backward compatibility.
     */
    @SuppressWarnings("unchecked")
    private String resolveRole(Jwt jwt) {
        Object userMetadata = jwt.getClaim("user_metadata");
        if (userMetadata instanceof Map) {
            Object roleClaim = ((Map<String, Object>) userMetadata).get("role");
            if (roleClaim instanceof String s && !s.isBlank()) {
                return s;
            }
        }
        String topLevel = jwt.getClaimAsString("role");
        return (topLevel == null || topLevel.isBlank()) ? "owner" : topLevel;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse resp = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse resp = authService.login(request);
        return ResponseEntity.ok(resp);
    }

    /**
     * Resends the Supabase signup confirmation email.
     * <p>
     * Always returns 200 OK regardless of whether the email exists or is already confirmed —
     * this prevents user enumeration. Real infrastructure errors (Supabase down, network) still
     * surface as 5xx via the global exception handler.
     * <p>
     * Rate limited to 3 requests / hour / IP by RateLimitingFilter.
     */
    @PostMapping("/resend-verification")
    public ResponseEntity<Map<String, String>> resendVerification(@Valid @RequestBody ResendVerificationRequest request) {
        authService.resendVerification(request.getEmail());
        Map<String, String> response = new HashMap<>();
        response.put("message", "Doğrulama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.");
        return ResponseEntity.ok(response);
    }
}
