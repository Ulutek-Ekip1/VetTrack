package com.vettrack.api.owner;

import com.vettrack.api.storage.StorageException;
import com.vettrack.api.storage.StorageService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.jwt.Jwt;

import java.time.Instant;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class OwnerProfilePhotoDeleteTest {

    private OwnerRepository ownerRepository;
    private StorageService storageService;
    private OwnerService ownerService;

    private static final String PHOTO_URL =
            "https://proj.supabase.co/storage/v1/object/public/pet-photos/some-key?v=123";

    @BeforeEach
    void setUp() {
        ownerRepository = mock(OwnerRepository.class);
        storageService = mock(StorageService.class);
        ownerService = new OwnerService(ownerRepository, storageService);
    }

    private Owner ownerWithPhoto(UUID id, String photoUrl) {
        return Owner.builder().id(id).email("o@test.com").fullName("Test Owner")
                .role("owner").profilePhotoUrl(photoUrl).build();
    }

    @Test
    void whenNoPhoto_thenIdempotentNoOp() {
        UUID id = UUID.randomUUID();
        when(ownerRepository.findById(id)).thenReturn(Optional.of(ownerWithPhoto(id, null)));

        ownerService.deleteProfilePhoto(id);

        verifyNoInteractions(storageService);
        verify(ownerRepository, never()).save(any());
    }

    @Test
    void whenPhotoExists_thenDeletesStorageAndNullsColumn() {
        UUID id = UUID.randomUUID();
        Owner owner = ownerWithPhoto(id, PHOTO_URL);
        when(ownerRepository.findById(id)).thenReturn(Optional.of(owner));

        ownerService.deleteProfilePhoto(id);

        verify(storageService).deleteByPublicUrl(PHOTO_URL);
        assertNull(owner.getProfilePhotoUrl(), "profile_photo_url NULL yapılmalı");
        verify(ownerRepository).save(owner);
    }

    @Test
    void whenStorageDeleteFails_thenStillNullsColumn() {
        UUID id = UUID.randomUUID();
        Owner owner = ownerWithPhoto(id, PHOTO_URL);
        when(ownerRepository.findById(id)).thenReturn(Optional.of(owner));
        doThrow(new StorageException("boom")).when(storageService).deleteByPublicUrl(anyString());

        assertDoesNotThrow(() -> ownerService.deleteProfilePhoto(id));

        assertNull(owner.getProfilePhotoUrl());
        verify(ownerRepository).save(owner);
    }

    @Test
    void controller_returns204_andDelegates() {
        OwnerService svc = mock(OwnerService.class);
        OwnerController controller = new OwnerController(svc);
        UUID sub = UUID.randomUUID();
        Jwt jwt = new Jwt("t", Instant.now(), Instant.now().plusSeconds(3600),
                Map.of("alg", "ES256"), Map.of("sub", sub.toString()));

        ResponseEntity<Void> response = controller.deleteMyPhoto(jwt);

        assertEquals(HttpStatus.NO_CONTENT, response.getStatusCode());
        verify(svc).deleteProfilePhoto(eq(sub));
    }

    @Test
    void deleteByPublicUrl_ignoresNullBlankAndNonSupabaseUrls() {
        // RestClient'a hiç dokunmadan erken dönmeli (null RestClient ile bile NPE atmamalı)
        StorageService s = new StorageService(null, "https://proj.supabase.co/storage/v1");
        assertDoesNotThrow(() -> s.deleteByPublicUrl(null));
        assertDoesNotThrow(() -> s.deleteByPublicUrl("   "));
        assertDoesNotThrow(() -> s.deleteByPublicUrl("https://external.example.com/avatar.jpg"));
    }
}
