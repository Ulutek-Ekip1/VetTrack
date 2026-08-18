package com.vettrack.api.owner;

import com.vettrack.api.owner.dto.OwnerResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

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

    @PutMapping("/me")
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
            @RequestBody OwnerUpdateRequest request
    ) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        return ResponseEntity.ok(OwnerResponse.fromEntity(ownerService.updateOwner(ownerId, request)));
    }

    @DeleteMapping("/me/photo")
    @PreAuthorize("hasRole('OWNER')")
    @Operation(
        summary = "Profil Fotoğrafını Sil",
        description = "Oturum açmış kullanıcının profil fotoğrafını siler: DB'deki profile_photo_url "
                    + "alanını NULL yapar ve storage'daki fiziksel dosyayı kaldırır. Idempotenttir — "
                    + "silinecek fotoğraf zaten yoksa da 204 döner.",
        security = @SecurityRequirement(name = "bearerAuth")
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Fotoğraf silindi (fotoğraf zaten yoksa da 204 döner)"),
        @ApiResponse(responseCode = "401", description = "Yetkisiz erişim (JWT eksik veya geçersiz)"),
        @ApiResponse(responseCode = "403", description = "Yetki yok (ROLE_OWNER gerekli)")
    })
    public ResponseEntity<Void> deleteMyPhoto(@AuthenticationPrincipal Jwt jwt) {
        UUID ownerId = UUID.fromString(jwt.getSubject());
        ownerService.deleteProfilePhoto(ownerId);
        return ResponseEntity.noContent().build();
    }
}