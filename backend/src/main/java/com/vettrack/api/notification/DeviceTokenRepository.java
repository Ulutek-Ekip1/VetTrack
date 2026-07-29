package com.vettrack.api.notification;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Long> {

    Optional<DeviceToken> findByFcmToken(String fcmToken);

    List<DeviceToken> findByOwnerId(UUID ownerId);

    void deleteByOwnerIdAndFcmToken(UUID ownerId, String fcmToken);

    void deleteByFcmToken(String fcmToken);

    @Modifying(clearAutomatically = true)
    @Query("DELETE FROM DeviceToken d WHERE d.updatedAt < :threshold")
    int deleteByUpdatedAtBefore(@Param("threshold") Instant threshold);
}