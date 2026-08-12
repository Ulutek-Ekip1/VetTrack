package com.vettrack.api.notification;

import java.util.UUID;

/** Published with the transaction that persists a notification. */
public record NotificationPushRequestedEvent(UUID notificationId) {}
