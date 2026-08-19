package com.vettrack.api.pet;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "pets")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Pet {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Version
    @Column(name = "version")
    private Long version;

    @Column(name = "owner_id", nullable = false)
    private UUID ownerId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String species;

    @Column
    private String breed;

    @Column(nullable = false, length = 10)
    @Enumerated(EnumType.STRING)
    private Gender gender;

    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Column(name = "estimated_birth_year")
    private Short estimatedBirthYear;

    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;

    @Column
    private Double weight;

    @Column(name = "microchip_no", length = 50)
    private String microchipNo;

    @Column(name = "is_spayed_or_neutered")
    private Boolean isSpayedOrNeutered;

    @Column(name = "blood_type", length = 20)
    private String bloodType;

    @Column(length = 50)
    private String color;

    @Column(columnDefinition = "TEXT")
    private String allergies;

    @Column(name = "chronic_illnesses", columnDefinition = "TEXT")
    private String chronicIllnesses;

    @Column(name = "unique_code", nullable = false, unique = true, length = 6)
    private String uniqueCode;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @Column(name = "deleted_at")
    private OffsetDateTime deletedAt;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) this.createdAt = OffsetDateTime.now();
        this.updatedAt = OffsetDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }
}