package com.vettrack.api.clinic;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ClinicSubscriptionQuotaTest {

    @Mock
    private ClinicRepository clinicRepository;

    @Mock
    private ClinicMembershipRepository membershipRepository;

    @Mock
    private ClinicInviteRepository inviteRepository;

    @InjectMocks
    private ClinicMembershipService membershipService;

    private UUID clinicId;
    private Clinic freeClinic;
    private Clinic standardClinic;

    @BeforeEach
    void setUp() {
        clinicId = UUID.randomUUID();

        freeClinic = Clinic.builder()
                .id(clinicId)
                .name("Free Vet Clinic")
                .tier(ClinicTier.FREE)
                .build();

        standardClinic = Clinic.builder()
                .id(clinicId)
                .name("Standard Vet Clinic")
                .tier(ClinicTier.STANDARD)
                .build();
    }

    @Test
    @DisplayName("Free tier klinikte 1 aktif üye varken kota aşım hatası fırlatılmalı")
    void validateClinicVetQuota_FreeTier_LimitExceeded_ThrowsException() {
        when(clinicRepository.findById(clinicId)).thenReturn(Optional.of(freeClinic));

        ClinicMembership activeMember = ClinicMembership.builder()
                .id(UUID.randomUUID())
                .clinicId(clinicId)
                .status("active")
                .build();

        when(membershipRepository.findByClinicId(clinicId)).thenReturn(List.of(activeMember));
        when(inviteRepository.countByClinicIdAndAcceptedAtIsNullAndRevokedAtIsNullAndExpiresAtAfter(eq(clinicId), any(OffsetDateTime.class)))
                .thenReturn(0L);

        AccessDeniedException exception = assertThrows(
                AccessDeniedException.class,
                () -> membershipService.validateClinicVetQuota(clinicId)
        );

        assertTrue(exception.getMessage().contains("Klinik hekim kotası doldu"));
    }

    @Test
    @DisplayName("Free tier klinikte aktif üye olmasa bile 1 bekleyen davet varsa kota aşılmalı")
    void validateClinicVetQuota_FreeTier_PendingInvite_ThrowsException() {
        when(clinicRepository.findById(clinicId)).thenReturn(Optional.of(freeClinic));
        when(membershipRepository.findByClinicId(clinicId)).thenReturn(List.of());
        when(inviteRepository.countByClinicIdAndAcceptedAtIsNullAndRevokedAtIsNullAndExpiresAtAfter(eq(clinicId), any(OffsetDateTime.class)))
                .thenReturn(1L);

        AccessDeniedException exception = assertThrows(
                AccessDeniedException.class,
                () -> membershipService.validateClinicVetQuota(clinicId)
        );

        assertTrue(exception.getMessage().contains("Klinik hekim kotası doldu"));
    }

    @Test
    @DisplayName("Standard tier klinikte kota (5 hekim) aşılmadığı sürece başarıyla geçmeli")
    void validateClinicVetQuota_StandardTier_WithinLimit_Success() {
        when(clinicRepository.findById(clinicId)).thenReturn(Optional.of(standardClinic));

        ClinicMembership member1 = ClinicMembership.builder().clinicId(clinicId).status("active").build();
        ClinicMembership member2 = ClinicMembership.builder().clinicId(clinicId).status("active").build();

        when(membershipRepository.findByClinicId(clinicId)).thenReturn(List.of(member1, member2));
        when(inviteRepository.countByClinicIdAndAcceptedAtIsNullAndRevokedAtIsNullAndExpiresAtAfter(eq(clinicId), any(OffsetDateTime.class)))
                .thenReturn(1L); // Toplam 3 < 5 limit

        assertDoesNotThrow(() -> membershipService.validateClinicVetQuota(clinicId));
    }

    @Test
    @DisplayName("Geçersiz klinik ID verildiğinde ResourceNotFoundException fırlatılmalı")
    void validateClinicVetQuota_ClinicNotFound_ThrowsException() {
        when(clinicRepository.findById(clinicId)).thenReturn(Optional.empty());

        assertThrows(
                ResourceNotFoundException.class,
                () -> membershipService.validateClinicVetQuota(clinicId)
        );
    }
}