package com.vettrack.api.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Ad soyad alanÄ± boÅŸ bÄ±rakÄ±lamaz")
    @Size(min = 2, max = 100, message = "Ad soyad 2 ile 100 karakter arasÄ±nda olmalÄ±dÄ±r")
    private String name;

    @NotBlank(message = "E-posta alanÄ± boÅŸ bÄ±rakÄ±lamaz")
    @Email(message = "LÃ¼tfen geÃ§erli bir e-posta adresi giriniz")
    private String email;

    @NotBlank(message = "Åifre alanÄ± boÅŸ bÄ±rakÄ±lamaz")
    @Size(min = 6, message = "Åifre en az 6 karakter olmalÄ±dÄ±r")
    private String password;

    private String phone;

    @Pattern(regexp = "owner", message = "GeÃ§ersiz kullanÄ±cÄ± rolÃ¼")
    private String role = "owner";
}


