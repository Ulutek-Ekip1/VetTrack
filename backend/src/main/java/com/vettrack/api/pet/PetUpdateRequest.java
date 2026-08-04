package com.vettrack.api.pet;

import lombok.Data;

/**
 * Pet güncelleme isteği. Tüm alanlar opsiyoneldir — sadece gönderilen (null olmayan)
 * alanlar güncellenir (partial update). API sözleşmesi: docs/api-contract.md satır 227.
 *
 * Not: photoUrl bu endpoint üzerinden güncellenmez; POST /pets/{id}/photo kullanılır.
 * uniqueCode ise hiçbir şekilde değiştirilemez.
 */
@Data
public class PetUpdateRequest {

    private String name;
    private Integer age;
    private Gender gender;
    private String breed;
}