package com.vettrack.api.clinic;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.stereotype.Repository;
import jakarta.persistence.LockModeType;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClinicMembershipRepository extends JpaRepository<ClinicMembership, UUID> {
    List<ClinicMembership> findByUserId(UUID userId);
    List<ClinicMembership> findByClinicId(UUID clinicId);
    Optional<ClinicMembership> findByUserIdAndClinicId(UUID userId, UUID clinicId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    List<ClinicMembership> findWithLockByClinicId(UUID clinicId);
}
