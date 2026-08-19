package com.vettrack.api.clinic;

import com.vettrack.api.common.exception.ConflictException;
import com.vettrack.api.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ClinicMembershipService {

    private final ClinicMembershipRepository membershipRepository;
    private final ClinicRepository clinicRepository;
    private final ClinicInviteRepository inviteRepository;

    public boolean hasActiveMembership(UUID userId) {
        return !getMembershipsByUser(userId).stream().filter(m -> "active".equals(m.getStatus())).toList().isEmpty();
    }

    public List<ClinicMembership> getMembershipsByUser(UUID userId) {
        return membershipRepository.findByUserId(userId);
    }

    public ClinicMembership getActiveMembership(UUID userId, UUID clinicId) {
        ClinicMembership membership = membershipRepository.findByUserIdAndClinicId(userId, clinicId)
                .orElseThrow(() -> new AccessDeniedException("Bu klinikte üyeliğiniz yok."));
        if (!"active".equalsIgnoreCase(membership.getStatus())) {
            throw new AccessDeniedException("Aktif bir klinik üyeliğiniz bulunmamaktadır.");
        }
        return membership;
    }

    public void requireActiveClinicAdmin(UUID userId, UUID clinicId) {
        ClinicMembership membership = getActiveMembership(userId, clinicId);
        if (!Boolean.TRUE.equals(membership.getIsClinicAdmin())) {
            throw new AccessDeniedException("Bu işlem için bu klinikte clinic_admin olmalısınız.");
        }
    }

    /**
     * Yeni davet oluşturulurken kota kontrolü yapar.
     */
    public void validateClinicVetQuota(UUID clinicId) {
        Clinic clinic = clinicRepository.findById(clinicId)
                .orElseThrow(() -> new ResourceNotFoundException("Klinik bulunamadı."));

        long activeMembersCount = membershipRepository.findByClinicId(clinicId).stream()
                .filter(m -> "active".equalsIgnoreCase(m.getStatus()))
                .count();

        long pendingInvitesCount = inviteRepository
                .countByClinicIdAndAcceptedAtIsNullAndRevokedAtIsNullAndExpiresAtAfter(clinicId, OffsetDateTime.now());

        int limit = clinic.getTier() != null ? clinic.getTier().getDefaultMaxVets() : ClinicTier.FREE.getDefaultMaxVets();

        if ((activeMembersCount + pendingInvitesCount) >= limit) {
            throw new AccessDeniedException("Klinik hekim kotası doldu. Yeni üye eklemek veya davet göndermek için paketinizi yükseltin.");
        }
    }

    /**
     * Mevcut bir davet kabul edilirken sadece aktif üyeleri kontrol eder (davet zaten oluşturulurken kotadan ayrılmıştı).
     */
    public void validateClinicVetQuotaForAccept(UUID clinicId) {
        Clinic clinic = clinicRepository.findById(clinicId)
                .orElseThrow(() -> new ResourceNotFoundException("Klinik bulunamadı."));

        long activeMembersCount = membershipRepository.findByClinicId(clinicId).stream()
                .filter(m -> "active".equalsIgnoreCase(m.getStatus()))
                .count();

        int limit = clinic.getTier() != null ? clinic.getTier().getDefaultMaxVets() : ClinicTier.FREE.getDefaultMaxVets();

        if (activeMembersCount >= limit) {
            throw new AccessDeniedException("Klinik hekim kotası doldu. Yeni üye eklemek için paketinizi yükseltin.");
        }
    }

    @Transactional
    public void disableMembership(UUID actorId, UUID clinicId, UUID memberUserId) {
        requireActiveClinicAdmin(actorId, clinicId);
        List<ClinicMembership> memberships = membershipRepository.findWithLockByClinicId(clinicId);
        ClinicMembership target = memberships.stream()
                .filter(m -> m.getUserId().equals(memberUserId))
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Klinik üyeliği bulunamadı."));

        if ("disabled".equalsIgnoreCase(target.getStatus())) return;
        boolean targetIsActiveAdmin = "active".equalsIgnoreCase(target.getStatus())
                && Boolean.TRUE.equals(target.getIsClinicAdmin());
        long activeAdmins = memberships.stream()
                .filter(m -> "active".equalsIgnoreCase(m.getStatus()))
                .filter(m -> Boolean.TRUE.equals(m.getIsClinicAdmin()))
                .count();
        if (targetIsActiveAdmin && activeAdmins <= 1) {
            throw new ConflictException("Klinikte en az bir aktif clinic_admin kalmalıdır.");
        }
        target.setStatus("disabled");
        membershipRepository.save(target);
    }

    @Transactional
    public void disableAllMemberships(UUID userId) {
        List<ClinicMembership> memberships = membershipRepository.findByUserId(userId);
        for (ClinicMembership membership : memberships) {
            List<ClinicMembership> clinicMemberships = membershipRepository.findWithLockByClinicId(membership.getClinicId());
            long activeAdmins = clinicMemberships.stream()
                    .filter(m -> "active".equalsIgnoreCase(m.getStatus()))
                    .filter(m -> Boolean.TRUE.equals(m.getIsClinicAdmin()))
                    .count();
            if ("active".equalsIgnoreCase(membership.getStatus())
                    && Boolean.TRUE.equals(membership.getIsClinicAdmin()) && activeAdmins <= 1) {
                throw new ConflictException("Son aktif clinic_admin hesabını silemezsiniz.");
            }
            membership.setStatus("disabled");
            membershipRepository.save(membership);
        }
    }
}