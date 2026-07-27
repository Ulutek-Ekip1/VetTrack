package com.vettrack.api.treatment;

import org.springframework.data.jpa.repository.JpaRepository;


import java.util.List;
import java.util.UUID;

public interface TreatmentEntryRepository extends JpaRepository<TreatmentEntry, UUID> {
    List<TreatmentEntry> findByVisitIdOrderByCreatedAtDesc(UUID visitId);
}
