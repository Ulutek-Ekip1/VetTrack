package com.vettrack.api.notification;

import com.vettrack.api.common.exception.UnauthorizedException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<Notification>> getNotifications(Authentication authentication) {
        UUID ownerId = extractOwnerId(authentication);
        List<Notification> notifications = notificationService.getOwnerNotifications(ownerId);
        return ResponseEntity.ok(notifications);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            Authentication authentication,
            @PathVariable UUID id) {
        UUID ownerId = extractOwnerId(authentication);
        notificationService.markAsRead(id, ownerId);
        return ResponseEntity.noContent().build();
    }

    private UUID extractOwnerId(Authentication authentication) {
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
