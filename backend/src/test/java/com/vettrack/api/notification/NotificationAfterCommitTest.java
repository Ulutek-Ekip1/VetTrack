package com.vettrack.api.notification;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MessagingErrorCode;
import com.google.firebase.messaging.Message;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Kart #18: FCM gönderimi artık VisitService.closeVisit() gibi çağıranların
 * @Transactional sınırının içinde değil, NotificationCreatedEvent üzerinden
 * @TransactionalEventListener(AFTER_COMMIT) ile tetikleniyor. Bu testler
 * gerçek bir Spring transaction'ı commit/rollback ederek bunu doğruluyor —
 * doğrudan metod çağrısıyla değil.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:notificationaftercommitdb;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "SUPABASE_URL=https://localhost",
    "SUPABASE_JWKS_URL=https://localhost/auth/v1/.well-known/jwks.json",
    "SUPABASE_JWT_ISSUER=https://localhost/auth/v1",
    "SUPABASE_STORAGE_URL=https://localhost/storage/v1",
    "SUPABASE_SERVICE_KEY=mock-key",
    "supabase.storage.url=https://localhost/storage/v1",
    "supabase.storage.service-key=mock-key",
    "FIREBASE_CREDENTIALS_PATH=mock-path"
})
class NotificationAfterCommitTest {

    @Autowired
    private NotificationService notificationService;
    @Autowired
    private DeviceTokenRepository deviceTokenRepository;
    @Autowired
    private NotificationRepository notificationRepository;
    @Autowired
    private PlatformTransactionManager transactionManager;

    private MockedStatic<FirebaseApp> firebaseAppMock;
    private MockedStatic<FirebaseMessaging> firebaseMessagingMock;
    private FirebaseMessaging firebaseMessaging;

    @BeforeEach
    void mockFirebaseAsConfigured() throws Exception {
        firebaseAppMock = mockStatic(FirebaseApp.class);
        firebaseAppMock.when(FirebaseApp::getApps).thenReturn(List.of(mock(FirebaseApp.class)));

        firebaseMessaging = mock(FirebaseMessaging.class);
        firebaseMessagingMock = mockStatic(FirebaseMessaging.class);
        firebaseMessagingMock.when(FirebaseMessaging::getInstance).thenReturn(firebaseMessaging);
        when(firebaseMessaging.send(any(Message.class))).thenReturn("projects/mock/messages/1");
    }

    @AfterEach
    void closeFirebaseMocks() {
        firebaseAppMock.close();
        firebaseMessagingMock.close();
    }

    @Test
    @DisplayName("Transaction commit olunca FCM push gönderilir")
    void sendsFcmPushOnlyAfterTransactionCommits() throws Exception {
        UUID ownerId = UUID.randomUUID();
        deviceTokenRepository.save(DeviceToken.builder()
                .userId(ownerId).fcmToken("token-" + UUID.randomUUID()).platform(Platform.android).build());

        notificationService.sendVisitClosedNotification(ownerId, UUID.randomUUID(), UUID.randomUUID());

        verify(firebaseMessaging, times(1)).send(any(Message.class));
    }

    @Test
    @DisplayName("Transaction rollback olunca FCM push hiç gönderilmez")
    void doesNotSendFcmPushWhenTransactionRollsBack() throws Exception {
        UUID ownerId = UUID.randomUUID();
        deviceTokenRepository.save(DeviceToken.builder()
                .userId(ownerId).fcmToken("token-" + UUID.randomUUID()).platform(Platform.android).build());

        TransactionTemplate transactionTemplate = new TransactionTemplate(transactionManager);
        transactionTemplate.execute(status -> {
            notificationService.sendVisitClosedNotification(ownerId, UUID.randomUUID(), UUID.randomUUID());
            status.setRollbackOnly();
            return null;
        });

        verify(firebaseMessaging, never()).send(any(Message.class));
        assertTrue(notificationRepository.findByOwnerIdOrderBySentAtDesc(ownerId).isEmpty());
    }

    @Test
    @DisplayName("FCM UNREGISTERED derse gecersiz token silinir")
    void deletesTokenWhenFcmReportsUnregistered() throws Exception {
        UUID ownerId = UUID.randomUUID();
        DeviceToken saved = deviceTokenRepository.save(DeviceToken.builder()
                .userId(ownerId).fcmToken("stale-token-" + UUID.randomUUID()).platform(Platform.android).build());

        FirebaseMessagingException unregisteredError = mock(FirebaseMessagingException.class);
        when(unregisteredError.getMessagingErrorCode()).thenReturn(MessagingErrorCode.UNREGISTERED);
        when(firebaseMessaging.send(any(Message.class))).thenThrow(unregisteredError);

        notificationService.sendVisitClosedNotification(ownerId, UUID.randomUUID(), UUID.randomUUID());

        verify(firebaseMessaging, times(1)).send(any(Message.class));
        assertTrue(deviceTokenRepository.findById(saved.getId()).isEmpty());
    }

    @Test
    @DisplayName("FCM INVALID_ARGUMENT derse token silinmez (token'a ozel olmayabilir)")
    void doesNotDeleteTokenWhenFcmReportsInvalidArgument() throws Exception {
        UUID ownerId = UUID.randomUUID();
        DeviceToken saved = deviceTokenRepository.save(DeviceToken.builder()
                .userId(ownerId).fcmToken("token-" + UUID.randomUUID()).platform(Platform.android).build());

        FirebaseMessagingException invalidArgumentError = mock(FirebaseMessagingException.class);
        when(invalidArgumentError.getMessagingErrorCode()).thenReturn(MessagingErrorCode.INVALID_ARGUMENT);
        when(invalidArgumentError.getMessage()).thenReturn("Bad payload");
        when(firebaseMessaging.send(any(Message.class))).thenThrow(invalidArgumentError);

        notificationService.sendVisitClosedNotification(ownerId, UUID.randomUUID(), UUID.randomUUID());

        verify(firebaseMessaging, times(1)).send(any(Message.class));
        assertTrue(deviceTokenRepository.findById(saved.getId()).isPresent());
    }
}
