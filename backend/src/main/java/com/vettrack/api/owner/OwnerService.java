package com.vettrack.api.owner;

import com.vettrack.api.common.exception.RoleMismatchException;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OwnerService {

    private final OwnerRepository ownerRepository;

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

        if (request.getName() != null || request.getSurname() != null) {
            String nameVal = request.getName() != null ? request.getName().trim() : "";
            String surnameVal = request.getSurname() != null ? request.getSurname().trim() : "";

            String targetName = request.getName() != null ? nameVal : "";
            String targetSurname = request.getSurname() != null ? surnameVal : "";

            if (request.getName() == null) {
                String currentFullName = owner.getFullName() != null ? owner.getFullName().trim() : "";
                String currentSurname = owner.getSurname() != null ? owner.getSurname().trim() : "";
                if (!currentSurname.isEmpty() && currentFullName.endsWith(currentSurname)) {
                    targetName = currentFullName.substring(0, currentFullName.length() - currentSurname.length()).trim();
                } else {
                    targetName = currentFullName;
                }
            }
            if (request.getSurname() == null) {
                targetSurname = owner.getSurname() != null ? owner.getSurname().trim() : "";
            }

            owner.setFullName((targetName + " " + targetSurname).trim());
            owner.setSurname(targetSurname.isEmpty() ? null : targetSurname);
        } else if (request.getFullName() != null) {
            String fullNameVal = request.getFullName().trim();
            owner.setFullName(fullNameVal);

            String extractedSurname = null;
            if (!fullNameVal.isEmpty()) {
                int lastSpaceIndex = fullNameVal.lastIndexOf(' ');
                if (lastSpaceIndex != -1) {
                    extractedSurname = fullNameVal.substring(lastSpaceIndex + 1).trim();
                }
            }
            owner.setSurname(extractedSurname);
        }

        if (request.getPhone() != null) {
            owner.setPhone(request.getPhone());
        }

        if (request.getAddress() != null) {
            owner.setAddress(request.getAddress());
        }

        return ownerRepository.save(owner);
    }
}