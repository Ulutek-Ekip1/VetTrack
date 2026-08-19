package com.vettrack.api.clinic;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "clinic_memberships")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClinicMembership {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private UUID clinicId;

    @Column(nullable = false)
    private String role; // 'doctor', 'staff'

    @Builder.Default
    @Column(nullable = false)
    private Boolean isClinicAdmin = false;

    @Builder.Default
    @Column(nullable = false)
    private String status = "active"; // 'invited', 'active', 'disabled'

    private OffsetDateTime joinedAt;

    @CreationTimestamp
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    private OffsetDateTime updatedAt;
}
