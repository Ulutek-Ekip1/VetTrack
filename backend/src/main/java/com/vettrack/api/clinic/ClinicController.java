package com.vettrack.api.clinic;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import com.vettrack.api.common.exception.UnauthorizedException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.OffsetDateTime;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping({"/clinics", "/api/clinics"})
@RequiredArgsConstructor
@Tag(name = "Klinik & Üyelik API", description = "Klinik davet ve üyelik işlemleri")
public class ClinicController {

    private final ClinicRepository clinicRepository;
    private final ClinicMembershipRepository membershipRepository;
    private final ClinicInviteRepository inviteRepository;
    private final ClinicMembershipService membershipService;
    private static final SecureRandom TOKEN_RANDOM = new SecureRandom();

    @PostMapping("/{clinicId}/invites")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Yeni Klinik Daveti Oluştur", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Map<String, String>> createInvite(
            @PathVariable UUID clinicId,
            @RequestBody Map<String, String> request,
            @AuthenticationPrincipal Jwt jwt
    ) {
        UUID adminId = UUID.fromString(jwt.getSubject());

        membershipService.requireActiveClinicAdmin(adminId, clinicId);
        if (!clinicRepository.existsById(clinicId)) {
            throw new ResourceNotFoundException("Klinik bulunamadı.");
        }

        String rawToken = newToken();
        String tokenHash = sha256(rawToken);

        ClinicInvite invite = ClinicInvite.builder()
                .clinicId(clinicId)
                .email(request.get("email"))
                .tokenHash(tokenHash)
                .expiresAt(OffsetDateTime.now().plusDays(7))
                .createdBy(adminId) // store the user id of the admin who created the invite
                .build();

        inviteRepository.save(invite);

        // MVP: Sadece token'ı dönüyoruz, admin linki WhatsApp'tan vs paylaşacak.
        return ResponseEntity.ok(Map.of(
                "message", "Davet oluşturuldu.",
                "invite_token", rawToken,
                "expires_at", invite.getExpiresAt().toString()
        ));
    }

    @PostMapping("/invites/accept")
    @PreAuthorize("isAuthenticated()") // any authenticated user (owner/vet/staff) may accept an invite for their account
    @Operation(summary = "Klinik Davetini Kabul Et (Query Param)", security = @SecurityRequirement(name = "bearerAuth"))
    @Transactional
    public ResponseEntity<Map<String, String>> acceptInvite(
            @RequestParam(required = false) String token,
            @AuthenticationPrincipal Jwt jwt
    ) {
        if (token == null || token.isBlank()) {
            throw new IllegalArgumentException("Davet token'ı boş olamaz.");
        }

        String tokenHash = sha256(token);
        ClinicInvite invite = inviteRepository.findWithLockByTokenHash(tokenHash)
                .orElseThrow(() -> new ResourceNotFoundException("Geçersiz davet token'ı."));

        if (invite.getAcceptedAt() != null) {
            throw new IllegalArgumentException("Bu davet daha önce kullanılmış.");
        }
        if (invite.getRevokedAt() != null) {
            throw new IllegalArgumentException("Bu davet iptal edilmiş.");
        }
        if (invite.getExpiresAt().isBefore(OffsetDateTime.now())) {
            throw new IllegalArgumentException("Bu davetin süresi dolmuş.");
        }

        UUID userId = UUID.fromString(jwt.getSubject());
        String inviteEmail = invite.getEmail();
        String userEmail = jwt.getClaimAsString("email");
        if (inviteEmail != null && !inviteEmail.isBlank()
                && (userEmail == null || !inviteEmail.trim().equalsIgnoreCase(userEmail.trim()))) {
            throw new UnauthorizedException("Bu davet farklı bir e-posta adresi için oluşturulmuştur.");
        }

        // Eğer zaten üyeyse
        if (membershipRepository.findByUserIdAndClinicId(userId, invite.getClinicId()).isPresent()) {
            throw new IllegalArgumentException("Zaten bu kliniğin üyesisiniz.");
        }

        ClinicMembership membership = ClinicMembership.builder()
                .userId(userId)
                .clinicId(invite.getClinicId())
                .role("doctor")
                .isClinicAdmin(false)
                .status("active")
                .joinedAt(OffsetDateTime.now())
                .build();

        membershipRepository.save(membership);

        invite.setAcceptedAt(OffsetDateTime.now());
        inviteRepository.save(invite);

        return ResponseEntity.ok(Map.of(
                "message", "Klinik daveti kabul edildi ve üyelik oluşturuldu.",
                "clinic_id", invite.getClinicId().toString()
        ));
    }

    @PostMapping(value = "/invites/accept", consumes = MediaType.APPLICATION_JSON_VALUE)
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Klinik Davetini Kabul Et (JSON Body)", security = @SecurityRequirement(name = "bearerAuth"))
    @Transactional
    public ResponseEntity<Map<String, String>> acceptInviteJson(
            @RequestBody Map<String, String> requestBody,
            @AuthenticationPrincipal Jwt jwt
    ) {
        String token = requestBody != null ? requestBody.get("token") : null;
        return acceptInvite(token, jwt);
    }

    @DeleteMapping("/{clinicId}/invites/{inviteId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Klinik Davetini İptal Et (DELETE / Revoke)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Void> deleteInvite(
            @PathVariable UUID clinicId,
            @PathVariable UUID inviteId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        return revokeInvite(clinicId, inviteId, jwt);
    }

    @PostMapping("/{clinicId}/invites/{inviteId}/revoke")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Klinik Davetini İptal Et (POST / Revoke)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Void> revokeInvite(
            @PathVariable UUID clinicId,
            @PathVariable UUID inviteId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        membershipService.requireActiveClinicAdmin(UUID.fromString(jwt.getSubject()), clinicId);
        ClinicInvite invite = inviteRepository.findById(inviteId)
                .filter(i -> i.getClinicId().equals(clinicId))
                .orElseThrow(() -> new ResourceNotFoundException("Davet bulunamadı."));
        if (invite.getAcceptedAt() == null) {
            invite.setRevokedAt(OffsetDateTime.now());
            inviteRepository.save(invite);
        }
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{clinicId}/members/{userId}/disable")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> disableMember(
            @PathVariable UUID clinicId,
            @PathVariable UUID userId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        membershipService.disableMembership(UUID.fromString(jwt.getSubject()), clinicId, userId);
        return ResponseEntity.noContent().build();
    }

    private static String newToken() {
        byte[] bytes = new byte[32];
        TOKEN_RANDOM.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 kullanılamıyor", e);
        }
    }
}
