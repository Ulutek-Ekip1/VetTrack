package com.vettrack.api.notification;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, UUID> {

    Optional<DeviceToken> findByFcmToken(String fcmToken);

    List<DeviceToken> findByUserId(UUID userId);

    void deleteByUserIdAndFcmToken(UUID userId, String fcmToken);

    void deleteByFcmToken(String fcmToken);

    @Modifying(clearAutomatically = true)
    @Query("DELETE FROM DeviceToken d WHERE d.lastSeen < :threshold")
    int deleteByLastSeenBefore(@Param("threshold") OffsetDateTime threshold);
}