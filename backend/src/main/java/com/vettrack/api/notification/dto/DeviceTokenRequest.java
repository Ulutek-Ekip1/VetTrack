package com.vettrack.api.notification.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class DeviceTokenRequest {

    @NotBlank(message = "FCM token boş olamaz")
    private String fcmToken;

    @NotBlank(message = "Platform boş olamaz")
    @Size(max = 10, message = "Platform değeri en fazla 10 karakter olmalıdır")
    private String platform;

    public DeviceTokenRequest() {}

    public DeviceTokenRequest(String fcmToken, String platform) {
        this.fcmToken = fcmToken;
        this.platform = platform;
    }

    public String getFcmToken() { 
        return fcmToken; 
    }

    public void setFcmToken(String fcmToken) { 
        this.fcmToken = fcmToken; 
    }

    public String getPlatform() { 
        return platform; 
    }

    public void setPlatform(String platform) { 
        this.platform = platform; 
    }
}