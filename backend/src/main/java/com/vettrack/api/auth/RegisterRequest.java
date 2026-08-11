package com.vettrack.api.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

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

    @Pattern(regexp = "owner|vet_staff", message = "Geçersiz kullanıcı rolü")
    private String role = "owner";
}
