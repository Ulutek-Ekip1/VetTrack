package com.vettrack.api.notification;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.UUID;

/**
 * Published when a Notification row is saved, inside the same transaction
 * as the business operation that triggered it (e.g. closing a visit). The
 * actual FCM push only happens once that transaction commits — see
 * NotificationService's {@code @TransactionalEventListener}.
 */
@Getter
@AllArgsConstructor
public class NotificationCreatedEvent {

    private final UUID notificationId;
    private final UUID ownerId;
}
