package com.vettrack.api.vetstaff;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface VetStaffRepository extends JpaRepository<VetStaff, UUID> {
    Optional<VetStaff> findByEmail(String email);
}
