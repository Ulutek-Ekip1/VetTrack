package com.vettrack.api.clinic.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * INT-FINDING-02 (P0, QA Test Raporu 19.08.2026) — public register + authenticated accept
 * iki adımlı akışının aksine, davetli veterinerin hesabını ve klinik üyeliğini tek istekte
 * atomik olarak oluşturur. Proje genelindeki Supabase e-posta doğrulama ayarına bağımlı değildir.
 */
@Data
public class RegisterAndAcceptInviteRequest {

    @NotBlank(message = "Ad soyad alanı boş bırakılamaz")
    @Size(min = 2, max = 100, message = "Ad soyad 2 ile 100 karakter arasında olmalıdır")
    private String name;

    @NotBlank(message = "E-posta alanı boş bırakılamaz")
    @Email(message = "Lütfen geçerli bir e-posta adresi giriniz")
    private String email;

    @NotBlank(message = "Şifre alanı boş bırakılamaz")
    @Size(min = 6, message = "Şifre en az 6 karakter olmalıdır")
    private String password;

    private String phone;

    @NotBlank(message = "Davet token'ı boş olamaz")
    private String token;
}
