package com.vettrack.api.owner;

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
        
        String email = "oauth-user@vettrack.com";
        String fullName = "OAuth User";
        
        if (auth instanceof JwtAuthenticationToken jwtAuth) {
            Jwt jwt = jwtAuth.getToken();
            email = jwt.getClaimAsString("email");
            
            Map<String, Object> userMetadata = jwt.getClaim("user_metadata");
            if (userMetadata != null) {
                fullName = (String) userMetadata.get("name");
                if (fullName == null) {
                    fullName = (String) userMetadata.get("full_name");
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
                .role("owner")
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
}