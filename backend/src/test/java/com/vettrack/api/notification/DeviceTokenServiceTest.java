package com.vettrack.api.notification;

import com.vettrack.api.common.exception.ApiException;
import com.vettrack.api.common.exception.ErrorCode;
import com.vettrack.api.notification.dto.DeviceTokenRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DeviceTokenServiceTest {

    @Mock
    private DeviceTokenRepository repository;

    @InjectMocks
    private DeviceTokenService service;

    @Test
    @DisplayName("web platformu başarıyla parse edilir ve kaydedilir")
    void registerDevice_withWebPlatform_savesWeb() {
        UUID userId = UUID.randomUUID();
        DeviceTokenRequest request = new DeviceTokenRequest("fcm-web-123", "web");

        when(repository.findByFcmToken("fcm-web-123")).thenReturn(Optional.empty());

        service.registerDevice(userId, request);

        ArgumentCaptor<DeviceToken> captor = ArgumentCaptor.forClass(DeviceToken.class);
        verify(repository).save(captor.capture());

        DeviceToken saved = captor.getValue();
        assertEquals(Platform.web, saved.getPlatform());
        assertEquals("fcm-web-123", saved.getFcmToken());
        assertEquals(userId, saved.getUserId());
    }

    @Test
    @DisplayName("ios ve android platformları başarıyla kaydedilir")
    void registerDevice_withIosAndAndroid_success() {
        UUID userId = UUID.randomUUID();
        when(repository.findByFcmToken(any())).thenReturn(Optional.empty());

        service.registerDevice(userId, new DeviceTokenRequest("fcm-ios", "iOS"));
        service.registerDevice(userId, new DeviceTokenRequest("fcm-android", "ANDROID"));

        ArgumentCaptor<DeviceToken> captor = ArgumentCaptor.forClass(DeviceToken.class);
        verify(repository, times(2)).save(captor.capture());

        assertEquals(Platform.ios, captor.getAllValues().get(0).getPlatform());
        assertEquals(Platform.android, captor.getAllValues().get(1).getPlatform());
    }

    @Test
    @DisplayName("Bilinmeyen platform değeri 400 VALIDATION_ERROR ile reddedilir")
    void registerDevice_withInvalidPlatform_throwsValidationError() {
        UUID userId = UUID.randomUUID();
        DeviceTokenRequest request = new DeviceTokenRequest("fcm-typo", "androyd");

        ApiException ex = assertThrows(ApiException.class, () -> service.registerDevice(userId, request));

        assertEquals(ErrorCode.VALIDATION_ERROR, ex.getErrorCode());
        assertTrue(ex.getMessage().contains("Geçersiz platform"));
        verify(repository, never()).save(any());
    }

    @Test
    @DisplayName("Boş veya null platform değeri 400 VALIDATION_ERROR ile reddedilir")
    void registerDevice_withBlankPlatform_throwsValidationError() {
        UUID userId = UUID.randomUUID();

        ApiException exNull = assertThrows(ApiException.class,
                () -> service.registerDevice(userId, new DeviceTokenRequest("fcm-1", null)));
        assertEquals(ErrorCode.VALIDATION_ERROR, exNull.getErrorCode());

        ApiException exBlank = assertThrows(ApiException.class,
                () -> service.registerDevice(userId, new DeviceTokenRequest("fcm-2", "   ")));
        assertEquals(ErrorCode.VALIDATION_ERROR, exBlank.getErrorCode());

        verify(repository, never()).save(any());
    }
}
