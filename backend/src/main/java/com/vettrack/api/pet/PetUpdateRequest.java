package com.vettrack.api.pet;

import jakarta.validation.constraints.Size;
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

    @Size(min = 1, message = "Pet adı boş olamaz")
    private String name;
    private Integer age;
    private Gender gender;
    private String breed;
}