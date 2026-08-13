package com.vettrack.api.auth;

import com.vettrack.api.owner.Owner;
import com.vettrack.api.owner.OwnerService;
import com.vettrack.api.vetstaff.VetStaff;
import com.vettrack.api.vetstaff.VetStaffService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
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
@Tag(name = "Kimlik Doğrulama API", description = "Kullanıcı kayıt, giriş, profil, şifre sıfırlama ve hesap silme uç noktaları")
public class AuthController {

    private final AuthService authService;
    private final OwnerService ownerService;
    private final VetStaffService vetStaffService;

    @GetMapping("/me")
    @Operation(summary = "Mevcut Kullanıcı Profilini Getir", security = @SecurityRequirement(name = "bearerAuth"))
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
            if (Boolean.FALSE.equals(vetStaff.getIsActive())) {
                throw new com.vettrack.api.common.exception.UnauthorizedException("Kullanıcı hesabı pasife alınmıştır.");
            }
            response.put("profile", vetStaff);
        } else {
            Owner owner = ownerService.getOwnerById(userId);
            if (Boolean.FALSE.equals(owner.getIsActive())) {
                throw new com.vettrack.api.common.exception.UnauthorizedException("Kullanıcı hesabı pasife alınmıştır.");
            }
            response.put("profile", owner);
        }

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/me")
    @Operation(summary = "Kullanıcı Hesabını Sil (Soft Delete)", description = "Oturum açmış kullanıcının hesabını pasife alır (soft-delete), ilişkisel verileri korur ve aktif oturumunu geçersiz kılar.", security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Hesap başarıyla pasife alındı ve oturum kapatıldı"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim")
    })
    public ResponseEntity<Map<String, String>> deleteMyAccount(@AuthenticationPrincipal Jwt jwt) {
        if (jwt == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        UUID userId = UUID.fromString(jwt.getSubject());
        authService.softDeleteUserAccount(userId);

        Map<String, String> response = new HashMap<>();
        response.put("message", "Hesabınız başarıyla kapatılmıştır.");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @Operation(summary = "Yeni Kullanıcı Kaydı")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse resp = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(resp);
    }

    @PostMapping("/login")
    @Operation(summary = "Kullanıcı Girişi")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse resp = authService.login(request);
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/resend-verification")
    @Operation(summary = "Doğrulama E-postasını Tekrar Gönder")
    public ResponseEntity<Map<String, String>> resendVerification(@Valid @RequestBody ResendVerificationRequest request) {
        authService.resendVerification(request.getEmail());
        Map<String, String> response = new HashMap<>();
        response.put("message", "Doğrulama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/forgot-password")
    @Operation(summary = "Şifre Sıfırlama Bağlantısı Gönder", description = "Kullanıcının e-posta adresine şifre sıfırlama bağlantısı gönderir. User Enumeration koruması uygulanır.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "İstek alındı, e-posta gönderildi (veya e-posta kayıtlı değilse bile başarılı dönüldü)")
    })
    public ResponseEntity<Map<String, String>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request.getEmail());
        Map<String, String> response = new HashMap<>();
        response.put("message", "Eğer e-posta adresi sistemimizde kayıtlıysa, şifre sıfırlama bağlantısı gönderilmiştir.");
        return ResponseEntity.ok(response);
    }

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
}
