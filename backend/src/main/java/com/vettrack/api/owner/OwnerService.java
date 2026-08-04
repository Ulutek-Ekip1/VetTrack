package com.vettrack.api.owner;

import com.vettrack.api.common.exception.ResourceNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class OwnerService {

    private final OwnerRepository ownerRepository;

    @Transactional(readOnly = true)
    public Owner getOwnerById(UUID id) {
        return ownerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Kullanıcı bulunamadı"));
    }

    /**
     * Owner profil bilgilerini kısmen günceller (partial update).
     * Sadece null olmayan alanlar güncellenir. Email güncellenemez.
     */
    @Transactional
    public Owner updateOwner(UUID id, OwnerUpdateRequest request) {
        Owner owner = getOwnerById(id);

        if (request.getName() != null) {
            owner.setName(request.getName());
        }
        if (request.getSurname() != null) {
            owner.setSurname(request.getSurname());
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