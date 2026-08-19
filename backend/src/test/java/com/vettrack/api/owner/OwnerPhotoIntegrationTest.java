package com.vettrack.api.owner;

import com.vettrack.api.storage.StorageService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:ownerphototestdb;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "SUPABASE_URL=https://localhost",
    "SUPABASE_JWKS_URL=https://localhost/auth/v1/.well-known/jwks.json",
    "SUPABASE_JWT_ISSUER=https://localhost/auth/v1",
    "SUPABASE_STORAGE_URL=https://localhost/storage/v1",
    "SUPABASE_SERVICE_KEY=mock-key",
    "supabase.storage.url=https://localhost/storage/v1",
    "supabase.storage.service-key=mock-key",
    "FIREBASE_CREDENTIALS_PATH=mock-path"
})
@AutoConfigureMockMvc
class OwnerPhotoIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private OwnerRepository ownerRepository;

    @MockitoBean
    private StorageService storageService;

    private UUID ownerId;

    private static final String NEW_URL =
            "https://localhost/storage/v1/object/public/owner-photos/key?v=999";
    private static final String OLD_URL =
            "https://localhost/storage/v1/object/public/owner-photos/key?v=1";

    @BeforeEach
    void setUp() {
        ownerRepository.deleteAll();
        ownerId = UUID.randomUUID();
        ownerRepository.save(Owner.builder()
                .id(ownerId)
                .email("owner@test.com")
                .fullName("Test Owner")
                .role("owner")
                .build());
    }

    private RequestPostProcessor owner() {
        return jwt().jwt(b -> b.subject(ownerId.toString()))
                .authorities(new SimpleGrantedAuthority("ROLE_OWNER"));
    }

    private MockMultipartFile photoPart() {
        return new MockMultipartFile("file", "photo.jpg", "image/jpeg", "fake-image-bytes".getBytes());
    }

    @Test
    @DisplayName("Yükleme: 200 döner ve profilePhotoUrl set edilir")
    void upload_returns200_andSetsPhotoUrl() throws Exception {
        when(storageService.uploadOwnerPhoto(any(), eq(ownerId))).thenReturn(NEW_URL);

        mockMvc.perform(multipart("/owners/me/photo").file(photoPart()).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.profilePhotoUrl").value(NEW_URL));

        verify(storageService).uploadOwnerPhoto(any(), eq(ownerId));
        verify(storageService, never()).deleteOwnerPhoto(any()); // foto yokken eski dosya silinmez
    }

    @Test
    @DisplayName("Güncelleme: mevcut fotoğraf varsa yükleme öncesi eski dosya silinir")
    void upload_whenPhotoExists_deletesOldFileFirst() throws Exception {
        Owner owner = ownerRepository.findById(ownerId).orElseThrow();
        owner.setProfilePhotoUrl(OLD_URL);
        ownerRepository.save(owner);
        when(storageService.uploadOwnerPhoto(any(), eq(ownerId))).thenReturn(NEW_URL);

        mockMvc.perform(multipart("/owners/me/photo").file(photoPart()).with(owner()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.profilePhotoUrl").value(NEW_URL));

        verify(storageService).deleteOwnerPhoto(ownerId); // eski dosya silme doğrulaması
        verify(storageService).uploadOwnerPhoto(any(), eq(ownerId));
    }

    @Test
    @DisplayName("Silme: 200/204 -> 204 döner, storage silinir ve kolon NULL yapılır")
    void delete_returns204_andNullsColumn() throws Exception {
        Owner owner = ownerRepository.findById(ownerId).orElseThrow();
        owner.setProfilePhotoUrl(OLD_URL);
        ownerRepository.save(owner);

        mockMvc.perform(delete("/owners/me/photo").with(owner()))
                .andExpect(status().isNoContent());

        verify(storageService).deleteOwnerPhoto(ownerId);
        assertNull(ownerRepository.findById(ownerId).orElseThrow().getProfilePhotoUrl());
    }

    @Test
    @DisplayName("Silme idempotent: fotoğraf yoksa da 204, storage'a gidilmez")
    void delete_idempotent_whenNoPhoto() throws Exception {
        mockMvc.perform(delete("/owners/me/photo").with(owner()))
                .andExpect(status().isNoContent());

        verify(storageService, never()).deleteOwnerPhoto(any());
    }

    @Test
    @DisplayName("Yetkisiz: JWT olmadan yükleme 401 döner")
    void upload_withoutJwt_returns401() throws Exception {
        mockMvc.perform(multipart("/owners/me/photo").file(photoPart()))
                .andExpect(status().isUnauthorized());

        verifyNoInteractions(storageService);
    }

    @Test
    @DisplayName("Yetkisiz: JWT olmadan silme 401 döner")
    void delete_withoutJwt_returns401() throws Exception {
        mockMvc.perform(delete("/owners/me/photo"))
                .andExpect(status().isUnauthorized());

        verifyNoInteractions(storageService);
    }
}
