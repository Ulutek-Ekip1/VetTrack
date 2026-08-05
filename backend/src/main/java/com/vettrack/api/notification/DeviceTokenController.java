package com.vettrack.api.notification;

import com.vettrack.api.common.exception.UnauthorizedException;
import com.vettrack.api.notification.dto.DeviceTokenRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/devices")
public class DeviceTokenController {

    private final DeviceTokenService service;

    public DeviceTokenController(DeviceTokenService service) {
        this.service = service;
    }

    @PostMapping("/register")
    public ResponseEntity<Void> registerDevice(
            Authentication authentication,
            @Valid @RequestBody DeviceTokenRequest request) {
        UUID userId = extractUserId(authentication);
        service.registerDevice(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @PostMapping("/unregister")
    public ResponseEntity<Void> unregisterDevice(
            Authentication authentication,
            @Valid @RequestBody DeviceTokenRequest request) {
        UUID userId = extractUserId(authentication);
        service.unregisterDevice(userId, request.getFcmToken());
        return ResponseEntity.noContent().build();
    }

    private UUID extractUserId(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new UnauthorizedException("Kullanıcı kimliği doğrulanamadı.");
        }
        try {
            return UUID.fromString(authentication.getName());
        } catch (IllegalArgumentException ex) {
            throw new UnauthorizedException("Geçersiz kullanıcı ID formatı.");
        }
    }
}