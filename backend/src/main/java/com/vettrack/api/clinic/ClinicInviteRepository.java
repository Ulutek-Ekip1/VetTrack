package com.vettrack.api.clinic;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.stereotype.Repository;
import jakarta.persistence.LockModeType;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClinicInviteRepository extends JpaRepository<ClinicInvite, UUID> {
    Optional<ClinicInvite> findByTokenHash(String tokenHash);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<ClinicInvite> findWithLockByTokenHash(String tokenHash);

    List<ClinicInvite> findByClinicId(UUID clinicId);

    long countByClinicIdAndAcceptedAtIsNullAndRevokedAtIsNullAndExpiresAtAfter(
            UUID clinicId,
            OffsetDateTime now
    );
}
