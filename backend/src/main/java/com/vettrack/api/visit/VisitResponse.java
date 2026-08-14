package com.vettrack.api.visit;

import java.time.OffsetDateTime;
import java.util.UUID;

/** Public visit representation shared by every visit API response. */
public record VisitResponse(
        UUID id,
        UUID petId,
        UUID vetStaffId,
        String status,
        String chiefComplaint,
        OffsetDateTime startedAt,
        OffsetDateTime endedAt
) {
    public static VisitResponse from(Visit visit) {
        return new VisitResponse(
                visit.getId(),
                visit.getPetId(),
                visit.getVetStaffId(),
                visit.getStatus(),
                visit.getChiefComplaint(),
                visit.getStartedAt(),
                visit.getEndedAt()
        );
    }
}
