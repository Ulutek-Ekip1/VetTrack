package com.vettrack.api.owner;

import lombok.Data;

/**
 * Owner profil güncelleme isteği. Tüm alanlar opsiyoneldir (partial update).
 * Email bu endpoint üzerinden güncellenemez.
 */
@Data
public class OwnerUpdateRequest {

    private String name;
    private String surname;
    private String phone;
    private String address;
}