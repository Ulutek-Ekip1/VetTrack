package com.vettrack.api.notification;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "device_tokens")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeviceToken {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "fcm_token", nullable = false, unique = true, length = 512)
    private String fcmToken;

    @Enumerated(EnumType.STRING)
    @Column(name = "platform", length = 10, nullable = false)
    private Platform platform;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "last_seen")
    private OffsetDateTime lastSeen;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) this.createdAt = OffsetDateTime.now();
        if (this.lastSeen == null) this.lastSeen = OffsetDateTime.now();
    }

    public static DeviceTokenBuilder builder() {
        return new DeviceTokenBuilder();
    }

    public static class DeviceTokenBuilder {
        private UUID id;
        private UUID userId;
        private String fcmToken;
        private Platform platform;
        private Boolean isActive = true;
        private OffsetDateTime lastSeen;
        private OffsetDateTime createdAt;

        public DeviceTokenBuilder id(UUID id) { this.id = id; return this; }
        public DeviceTokenBuilder userId(UUID userId) { this.userId = userId; return this; }
        public DeviceTokenBuilder fcmToken(String fcmToken) { this.fcmToken = fcmToken; return this; }
        public DeviceTokenBuilder platform(Platform platform) { this.platform = platform; return this; }
        public DeviceTokenBuilder isActive(Boolean isActive) { this.isActive = isActive; return this; }
        public DeviceTokenBuilder lastSeen(OffsetDateTime lastSeen) { this.lastSeen = lastSeen; return this; }
        public DeviceTokenBuilder createdAt(OffsetDateTime createdAt) { this.createdAt = createdAt; return this; }

        public DeviceToken build() {
            DeviceToken d = new DeviceToken();
            d.id = this.id;
            d.userId = this.userId;
            d.fcmToken = this.fcmToken;
            d.platform = this.platform;
            d.isActive = this.isActive;
            d.lastSeen = this.lastSeen;
            d.createdAt = this.createdAt;
            return d;
        }
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    public String getFcmToken() { return fcmToken; }
    public void setFcmToken(String fcmToken) { this.fcmToken = fcmToken; }
    public Platform getPlatform() { return platform; }
    public void setPlatform(Platform platform) { this.platform = platform; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public OffsetDateTime getLastSeen() { return lastSeen; }
    public void setLastSeen(OffsetDateTime lastSeen) { this.lastSeen = lastSeen; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
}