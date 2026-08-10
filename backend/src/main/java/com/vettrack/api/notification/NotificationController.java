package com.vettrack.api.notification;

import com.vettrack.api.common.exception.UnauthorizedException;
import com.vettrack.api.notification.dto.NotificationListResponse;
import com.vettrack.api.notification.dto.UnreadCountResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public ResponseEntity<NotificationListResponse> getNotifications(Authentication authentication) {
        UUID ownerId = extractOwnerId(authentication);
        return ResponseEntity.ok(notificationService.getOwnerNotifications(ownerId));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<UnreadCountResponse> getUnreadCount(Authentication authentication) {
        UUID ownerId = extractOwnerId(authentication);
        long count = notificationService.getUnreadCount(ownerId);
        return ResponseEntity.ok(UnreadCountResponse.builder().unreadCount(count).build());
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<Void> markAsRead(
            Authentication authentication,
            @PathVariable UUID id) {
        UUID ownerId = extractOwnerId(authentication);
        notificationService.markAsRead(id, ownerId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/read-all")
    public ResponseEntity<UnreadCountResponse> markAllAsRead(Authentication authentication) {
        UUID ownerId = extractOwnerId(authentication);
        notificationService.markAllAsRead(ownerId);
        return ResponseEntity.ok(UnreadCountResponse.builder().unreadCount(0).build());
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
