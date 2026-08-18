package com.vettrack.api.owner;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Owner profil güncelleme istek modeli. Sadece izin verilen güvenli alanlar güncellenebilir.")
public class OwnerUpdateRequest {

    @Size(min = 2, max = 100, message = "Ad Soyad 2 ile 100 karakter arasında olmalıdır")
    @Pattern(
        regexp = "^[a-zA-ZçÇğĞıİöÖşŞüÜ\\s'-]+$",
        message = "Ad Soyad sadece harf, boşluk, tire ve kesme işareti içerebilir"
    )
    @Schema(description = "Kullanıcının tam adı", example = "Ahmet Yılmaz")
    private String fullName;

    @Pattern(
        regexp = "^(\\+?[0-9]{10,15})?$",
        message = "Telefon numarası uluslararası formatta (E.164, örn: +905551234567) veya boş olmalıdır"
    )
    @Size(max = 20, message = "Telefon numarası en fazla 20 karakter olabilir")
    @Schema(description = "Kullanıcı telefon numarası (E.164 formatında)", example = "+905551234567")
    private String phone;
}