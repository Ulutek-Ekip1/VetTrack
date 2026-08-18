package com.vettrack.api.owner;

import com.vettrack.api.owner.dto.OwnerResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.multipart.MultipartFile;
import jakarta.validation.Valid;

import java.util.UUID;

@RestController
@RequestMapping("/owners")
@RequiredArgsConstructor
@Tag(name = "Owner Profil Yönetimi", description = "Kullanıcı profil bilgilerini görüntüleme ve güncelleme API'leri")
public class OwnerController {

    private final OwnerService ownerService;

    @GetMapping("/me")
    @Operation(
        summary = "Mevcut Kullanıcı Bilgisi",
        description = "JWT'den alınan ID ile oturum açmış kullanıcının profil bilgilerini getirir.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Profil bilgileri başarıyla getirildi"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "404", description = "Kullanıcı bulunamadı")
    })
    public ResponseEntity<OwnerResponse> getMe(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(OwnerResponse.fromEntity(ownerService.getOwnerById(ownerId)));
    }

    @PatchMapping("/me")
    @Operation(
        summary = "Profil Bilgilerini Güncelle",
        description = "Kullanıcı profil bilgilerini (ad, soyad, telefon, adres) günceller. "
                    + "Tüm alanlar opsiyoneldir, sadece gönderilen alanlar güncellenir. "
                    + "Email bu endpoint üzerinden güncellenemez.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Profil başarıyla güncellendi"),
        @ApiResponse(responseCode = "400", description = "Geçersiz istek parametreleri"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "404", description = "Kullanıcı bulunamadı")
    })
    public ResponseEntity<OwnerResponse> updateMe(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody OwnerUpdateRequest request
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(OwnerResponse.fromEntity(ownerService.updateOwner(ownerId, request)));
    }

    @PostMapping(value = "/me/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyAuthority('OWNER', 'ROLE_OWNER')")
    @Operation(
        summary = "Profil Fotoğrafı Yükle/Güncelle",
        description = "Kullanıcının profil fotoğrafını yükler veya günceller. Max 15MB, JPG/PNG/WEBP desteklenir.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Profil fotoğrafı başarıyla yüklendi"),
        @ApiResponse(responseCode = "400", description = "Geçersiz dosya formatı"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim"),
        @ApiResponse(responseCode = "413", description = "Dosya boyutu çok büyük (Max 15MB)"),
        @ApiResponse(responseCode = "404", description = "Kullanıcı bulunamadı")
    })
    public ResponseEntity<OwnerResponse> uploadPhoto(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("file") MultipartFile file
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(OwnerResponse.fromEntity(ownerService.uploadPhoto(ownerId, file)));
    }
}