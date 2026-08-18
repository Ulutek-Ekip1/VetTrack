package com.vettrack.api.owner;

import com.vettrack.api.common.exception.RoleMismatchException;
import com.vettrack.api.storage.StorageException;
import com.vettrack.api.storage.StorageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class OwnerService {

    private final OwnerRepository ownerRepository;
    private final StorageService storageService;

    @Transactional
    public Owner getOwnerById(UUID id) {
        return ownerRepository.findById(id)
                .orElseGet(() -> createOwnerFromAuthenticationContext(id));
    }

    private Owner createOwnerFromAuthenticationContext(UUID id) {
        var auth = SecurityContextHolder.getContext().getAuthentication();

        String email = null;
        String fullName = null;
        String role = "owner";

        if (auth instanceof JwtAuthenticationToken jwtAuth) {
            Jwt jwt = jwtAuth.getToken();
            email = jwt.getClaimAsString("email");

            Map<String, Object> userMetadata = jwt.getClaim("user_metadata");
            if (userMetadata != null) {
                Object nameClaim = userMetadata.get("name");
                if (nameClaim instanceof String s && !s.isBlank()) {
                    fullName = s;
                } else {
                    Object fullNameClaim = userMetadata.get("full_name");
                    if (fullNameClaim instanceof String s2 && !s2.isBlank()) {
                        fullName = s2;
                    }
                }

                // Reject if the JWT explicitly identifies this user as vet_staff — they should
                // hit /auth/me (which routes to VetStaffService) not /owners/me.
                Object roleClaim = userMetadata.get("role");
                if (roleClaim instanceof String r && "vet_staff".equalsIgnoreCase(r)) {
                    throw new RoleMismatchException(
                            "This account is registered as vet_staff. Use the vet portal to sign in.");
                }
            }

            if (fullName == null || fullName.isBlank()) {
                fullName = jwt.getClaimAsString("name");
            }
        }

        if (fullName == null || fullName.isBlank()) {
            fullName = "OAuth User";
        }
        if (email == null || email.isBlank()) {
            email = "oauth-" + id.toString() + "@vettrack.com";
        }

        Owner owner = Owner.builder()
                .id(id)
                .email(email)
                .fullName(fullName)
                .role(role)
                .build();

        return ownerRepository.save(owner);
    }

    @Transactional
    public Owner updateOwner(UUID id, OwnerUpdateRequest request) {
        Owner owner = getOwnerById(id);

        if (request.getFullName() != null) {
            owner.setFullName(request.getFullName());
        }
        if (request.getPhone() != null) {
            owner.setPhone(request.getPhone());
        }

        return ownerRepository.save(owner);
    }

    /**
     * Kullanıcının profil fotoğrafını siler (FR: DELETE /owners/me/photo).
     * Idempotent: fotoğraf zaten yoksa hiçbir şey yapmadan döner. Fotoğraf varsa
     * önce storage'daki fiziksel dosya (best-effort) silinir, ardından DB'deki
     * profile_photo_url NULL yapılır. Storage silme hatası DB güncellemesini
     * ve idempotent sonucu engellemez — kullanıcının niyeti fotoğrafı kaldırmaktır.
     */
    @Transactional
    public void deleteProfilePhoto(UUID id) {
        Owner owner = getOwnerById(id);

        if (owner.getProfilePhotoUrl() == null || owner.getProfilePhotoUrl().isBlank()) {
            return; // idempotent: silinecek fotoğraf yok
        }

        try {
            storageService.deleteByPublicUrl(owner.getProfilePhotoUrl());
        } catch (StorageException e) {
            // Fiziksel dosya silinemese bile referansı DB'den kaldırıyoruz.
            log.warn("Profil fotoğrafı storage'dan silinemedi (userId={}), DB referansı yine de kaldırılıyor: {}",
                    id, e.getMessage());
        }

        owner.setProfilePhotoUrl(null);
        ownerRepository.save(owner);
    }
}