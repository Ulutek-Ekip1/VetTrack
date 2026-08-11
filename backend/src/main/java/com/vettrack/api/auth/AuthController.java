package com.vettrack.api.auth;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @GetMapping("/me")
    public ResponseEntity<Map<String, Object>> me(@AuthenticationPrincipal Jwt jwt) {
        if (jwt == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        Map<String, Object> response = new HashMap<>();
        response.put("id", jwt.getSubject());
        response.put("email", jwt.getClaimAsString("email"));
        response.put("role", jwt.getClaimAsString("role"));

        return ResponseEntity.ok(response);
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
