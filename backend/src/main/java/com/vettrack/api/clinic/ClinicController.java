package com.vettrack.api.clinic;

import com.vettrack.api.auth.AuthResponse;
import com.vettrack.api.auth.AuthService;
import com.vettrack.api.clinic.dto.ClinicInviteResponse;
import com.vettrack.api.clinic.dto.RegisterAndAcceptInviteRequest;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
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
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
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
    private final AuthService authService;
    private static final SecureRandom TOKEN_RANDOM = new SecureRandom();

    @PostMapping("/{clinicId}/invites")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Yeni Klinik Daveti Oluştur", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<ClinicInviteResponse> createInvite(
            @PathVariable UUID clinicId,
            @RequestBody(required = false) Map<String, String> request,
            @AuthenticationPrincipal Jwt jwt
    ) {
        UUID adminId = UUID.fromString(jwt.getSubject());

        membershipService.requireActiveClinicAdmin(adminId, clinicId);
        if (!clinicRepository.existsById(clinicId)) {
            throw new ResourceNotFoundException("Klinik bulunamadı.");
        }

        // Hekim davet kotası kontrolü
        membershipService.validateClinicVetQuota(clinicId);

        String rawToken = newToken();
        String tokenHash = sha256(rawToken);

        ClinicInvite invite = ClinicInvite.builder()
                .clinicId(clinicId)
                .email(request != null ? request.get("email") : null)
                .tokenHash(tokenHash)
                .expiresAt(OffsetDateTime.now().plusDays(7))
                .createdBy(adminId)
                .build();

        inviteRepository.save(invite);

        return ResponseEntity.ok(ClinicInviteResponse.builder()
                .message("Davet oluşturuldu.")
                .inviteToken(rawToken)
                .expiresAt(invite.getExpiresAt())
                .clinicId(clinicId)
                .build());
    }

    @PostMapping("/invites/accept")
    @PreAuthorize("isAuthenticated()")
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

        UUID userId = UUID.fromString(jwt.getSubject());

        // Idempotency (ağ kesintisi / retry): kullanıcı zaten bu kliniğin AKTİF üyesiyse
        // hata değil 200 döner. Bu kontrol acceptedAt kontrolünden ÖNCE olmalı — başarılı ilk
        // kabulde invite zaten "accepted" işaretlendiği için retry'da o kontrol tetiklenirdi.
        Optional<ClinicMembership> existingMembership =
                membershipRepository.findByUserIdAndClinicId(userId, invite.getClinicId());
        if (existingMembership.isPresent() && "active".equalsIgnoreCase(existingMembership.get().getStatus())) {
            return ResponseEntity.ok(Map.of("message", "Klinik üyeliği zaten aktif."));
        }

        if (invite.getAcceptedAt() != null) {
            throw new IllegalArgumentException("Bu davet daha önce kullanılmış.");
        }
        if (invite.getRevokedAt() != null) {
            throw new IllegalArgumentException("Bu davet iptal edilmiş.");
        }
        if (invite.getExpiresAt().isBefore(OffsetDateTime.now())) {
            throw new IllegalArgumentException("Bu davetin süresi dolmuş.");
        }

        String inviteEmail = invite.getEmail();
        String userEmail = jwt.getClaimAsString("email");
        if (inviteEmail != null && !inviteEmail.isBlank()
                && (userEmail == null || !inviteEmail.trim().equalsIgnoreCase(userEmail.trim()))) {
            throw new AccessDeniedException("Bu davet farklı bir e-posta adresi için oluşturulmuştur.");
        }

        if (existingMembership.isPresent()) {
            // Aktif değil ama kayıt var (ör. disabled) — mevcut davranış korunur.
            throw new IllegalArgumentException("Zaten bu kliniğin üyesisiniz.");
        }

        // Davet kabul edilirken hekim kotası kontrolü
        membershipService.validateClinicVetQuotaForAccept(invite.getClinicId());

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
            @RequestBody(required = false) Map<String, String> requestBody,
            @AuthenticationPrincipal Jwt jwt
    ) {
        String token = requestBody != null ? requestBody.get("token") : null;
        return acceptInvite(token, jwt);
    }

    @PostMapping("/invites/register-and-accept")
    @Operation(summary = "Davetle Kayıt Ol ve Kliniğe Katıl (Atomik)",
            description = "INT-FINDING-02 fix: public register + authenticated accept iki adımlı akışının "
                    + "aksine, yeni bir veteriner hesabı oluşturur ve klinik üyeliğini TEK istekte atomik "
                    + "olarak bağlar; başarılı oturum tokenları döner. Supabase e-posta doğrulama ayarına "
                    + "bağımlı değildir — geçerli davet token'ı kimliği zaten doğrulamış sayılır. Idempotent: "
                    + "kısmi bir önceki denemeden sonra aynı istekle güvenle retry edilebilir.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Hesap oluşturuldu/bulundu, klinik üyeliği bağlandı, oturum tokenları döner"),
        @ApiResponse(responseCode = "400", description = "Geçersiz/süresi dolmuş/iptal edilmiş davet veya kota aşımı"),
        @ApiResponse(responseCode = "401", description = "Davet farklı bir e-posta adresi için oluşturulmuş"),
        @ApiResponse(responseCode = "404", description = "Geçersiz davet token'ı"),
        @ApiResponse(responseCode = "409", description = "Bu e-posta ile FARKLI bir şifreyle zaten kayıtlı bir hesap var")
    })
    @Transactional
    public ResponseEntity<AuthResponse> registerAndAcceptInvite(@Valid @RequestBody RegisterAndAcceptInviteRequest request) {
        String tokenHash = sha256(request.getToken());
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

        String inviteEmail = invite.getEmail();
        if (inviteEmail != null && !inviteEmail.isBlank()
                && !inviteEmail.trim().equalsIgnoreCase(request.getEmail().trim())) {
            throw new UnauthorizedException("Bu davet farklı bir e-posta adresi için oluşturulmuştur.");
        }

        // Kullanıcı zaten mevcutsa (ör. önceki bir denemede oluşturuldu ama üyelik yazımı
        // başarısız oldu) AuthService aynı şifreyle login'e düşer — retry güvenle çalışır.
        // Şifre gerçekten farklıysa (bu davetle ilgisiz bağımsız bir hesap) UnauthorizedException
        // olduğu gibi 401 olarak dışarı yansır, hatalı biçimde 409'a çevrilmez.
        AuthResponse authResponse = authService.createConfirmedUserAndLogin(
                request.getEmail(), request.getPassword(), request.getName(), request.getPhone());

        UUID userId = extractUserId(authResponse);

        // Kota kontrolü userId bilinmeden yapılamaz (davet zaten oluşturulurken kotadan
        // ayrılmıştı — burası ikincil bir güvenlik ağı). Sadece GERÇEKTEN yeni bir üyelik
        // ekleniyorsa uygulanır; idempotent retry'da mevcut üyenin kendi koltuğu tekrar
        // sayılıp yanlışlıkla reddedilmesin diye.
        Optional<ClinicMembership> existingMembership =
                membershipRepository.findByUserIdAndClinicId(userId, invite.getClinicId());
        if (existingMembership.isEmpty()) {
            membershipService.validateClinicVetQuotaForAccept(invite.getClinicId());
            membershipRepository.save(ClinicMembership.builder()
                    .userId(userId)
                    .clinicId(invite.getClinicId())
                    .role("doctor")
                    .isClinicAdmin(false)
                    .status("active")
                    .joinedAt(OffsetDateTime.now())
                    .build());
        }

        invite.setAcceptedAt(OffsetDateTime.now());
        inviteRepository.save(invite);

        return ResponseEntity.status(HttpStatus.CREATED).body(authResponse);
    }

    private static UUID extractUserId(AuthResponse authResponse) {
        if (authResponse.getUser() instanceof Map<?, ?> userMap) {
            Object id = userMap.get("id");
            if (id != null) {
                return UUID.fromString(id.toString());
            }
        }
        throw new IllegalStateException("Supabase yanıtında kullanıcı id'si bulunamadı.");
    }

    @GetMapping("/invites/validate")
    @Operation(summary = "Davet Kodunu Doğrula (Public)",
            description = "Davet kodunu oturum açmadan doğrular. E-posta ifşa edilmez. "
                    + "Geçerli: 200 {valid, clinicId, clinicName}. Geçersiz: 404, kullanılmış: 409, "
                    + "iptal: 400, süresi dolmuş: 410.")
    public ResponseEntity<Map<String, Object>> validateInvite(@RequestParam(required = false) String token) {
        if (token == null || token.isBlank()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Geçersiz davet kodu."));
        }

        String tokenHash = sha256(token.trim());
        Optional<ClinicInvite> inviteOpt = inviteRepository.findByTokenHash(tokenHash);
        if (inviteOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("message", "Geçersiz davet kodu."));
        }

        ClinicInvite invite = inviteOpt.get();
        if (invite.getAcceptedAt() != null) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("message", "Bu davet kodu daha önce kullanılmış."));
        }
        if (invite.getRevokedAt() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Bu davet iptal edilmiş."));
        }
        if (invite.getExpiresAt().isBefore(OffsetDateTime.now())) {
            return ResponseEntity.status(HttpStatus.GONE).body(Map.of("message", "Bu davet kodunun süresi dolmuş."));
        }

        String clinicName = clinicRepository.findById(invite.getClinicId())
                .map(Clinic::getName)
                .orElse(null);

        // E-posta bilinçli olarak DÖNÜLMEZ (gizlilik/ifşa koruması).
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("valid", true);
        body.put("clinicId", invite.getClinicId().toString());
        body.put("clinicName", clinicName);
        return ResponseEntity.ok(body);
    }

    @DeleteMapping({"/invites/{inviteId}", "/{clinicId}/invites/{inviteId}"})
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Klinik Davetini İptal Et (DELETE / Revoke)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Void> deleteInvite(
            @PathVariable(required = false) UUID clinicId,
            @PathVariable UUID inviteId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        return revokeInvite(clinicId, inviteId, jwt);
    }

    @PostMapping({"/invites/{inviteId}/revoke", "/{clinicId}/invites/{inviteId}/revoke"})
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Klinik Davetini İptal Et (POST / Revoke)", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<Void> revokeInvite(
            @PathVariable(required = false) UUID clinicId,
            @PathVariable UUID inviteId,
            @AuthenticationPrincipal Jwt jwt
    ) {
        UUID adminId = UUID.fromString(jwt.getSubject());
        ClinicInvite invite = inviteRepository.findById(inviteId)
                .orElseThrow(() -> new ResourceNotFoundException("Davet bulunamadı."));

        UUID targetClinicId = clinicId != null ? clinicId : invite.getClinicId();
        membershipService.requireActiveClinicAdmin(adminId, targetClinicId);

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