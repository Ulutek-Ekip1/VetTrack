package com.vettrack.api.storage;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.multipart.MultipartFile;
import static org.mockito.Mockito.lenient;
import java.io.IOException;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

/**
 * StorageService unit testleri — [BACKEND] Görev 3 checklist:
 * ☐ MIME-type kontrollerini (sadece JPEG, PNG, WebP) test et.
 * ☐ 15MB üzerindeki dosyalar için FileTooLargeException doğrula.
 * ☐ Supabase Storage timeout/erişim hatalarında temiz hata mesajı doğrula.
 */
@ExtendWith(MockitoExtension.class)
class StorageServiceTest {

    @Mock
    private RestClient restClient;

    @Mock
    private RestClient.RequestBodyUriSpec requestBodyUriSpec;

    @Mock
    private RestClient.RequestBodySpec requestBodySpec;

    @Mock
    private RestClient.ResponseSpec responseSpec;

    @Mock
    private RestClient.RequestHeadersUriSpec requestHeadersUriSpec;

    @Mock
    private MultipartFile file;

    private StorageService storageService;

    private static final String STORAGE_URL = "https://test.supabase.co/storage/v1";

    @BeforeEach
    void setUp() {
        storageService = new StorageService(restClient, STORAGE_URL);
    }

    // =========================================================================
    // Checklist 1: MIME-type kontrolleri (sadece JPEG, PNG, WebP)
    // =========================================================================
    @Nested
    @DisplayName("MIME-type kontrolleri")
    class MimeTypeTests {

        @Test
        @DisplayName("JPEG dosya kabul edilmeli")
        void shouldAcceptJpegFile() throws IOException {
            setupValidUpload("image/jpeg", "photo.jpg", 1024);
            String result = storageService.uploadPetPhoto(file, UUID.randomUUID());
            assertNotNull(result);
            assertTrue(result.startsWith(STORAGE_URL));
        }

        @Test
        @DisplayName("image/jpg content-type'ı (bazı cihazların JPEG için gönderdiği standart dışı tip) kabul edilmeli")
        void shouldAcceptJpgAliasContentType() throws IOException {
            setupValidUpload("image/jpg", "photo.jpg", 1024);
            String result = storageService.uploadPetPhoto(file, UUID.randomUUID());
            assertNotNull(result);
        }

        @Test
        @DisplayName("PNG dosya kabul edilmeli")
        void shouldAcceptPngFile() throws IOException {
            setupValidUpload("image/png", "photo.png", 1024);
            String result = storageService.uploadPetPhoto(file, UUID.randomUUID());
            assertNotNull(result);
        }

        @Test
        @DisplayName("WebP dosya kabul edilmeli")
        void shouldAcceptWebpFile() throws IOException {
            setupValidUpload("image/webp", "photo.webp", 1024);
            String result = storageService.uploadPetPhoto(file, UUID.randomUUID());
            assertNotNull(result);
        }

        @Test
        @DisplayName("GIF dosya reddedilmeli — UnsupportedFileTypeException")
        void shouldRejectGifFile() {
            setupInvalidFile("image/gif", "anim.gif", 1024);
            assertThrows(UnsupportedFileTypeException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
        }

        @Test
        @DisplayName("PDF dosya reddedilmeli — UnsupportedFileTypeException")
        void shouldRejectPdfFile() {
            setupInvalidFile("application/pdf", "doc.pdf", 1024);
            assertThrows(UnsupportedFileTypeException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
        }

        @Test
        @DisplayName("HEIC dosya reddedilmeli — UnsupportedFileTypeException")
        void shouldRejectHeicFile() {
            setupInvalidFile("image/heic", "photo.heic", 1024);
            assertThrows(UnsupportedFileTypeException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
        }

        @Test
        @DisplayName("null content-type reddedilmeli — UnsupportedFileTypeException")
        void shouldRejectNullContentType() {
            setupInvalidFile(null, "unknown", 1024);
            assertThrows(UnsupportedFileTypeException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
        }
    }

    // =========================================================================
    // Checklist 2: 15MB dosya boyutu kontrolü — FileTooLargeException + 413
    // =========================================================================
    @Nested
    @DisplayName("Dosya boyutu kontrolleri")
    class FileSizeTests {

        @Test
        @DisplayName("15MB altı dosya kabul edilmeli")
        void shouldAcceptFileUnder15Mb() throws IOException {
            long justUnder15Mb = 15 * 1024 * 1024 - 1;
            setupValidUpload("image/jpeg", "photo.jpg", justUnder15Mb);
            String result = storageService.uploadPetPhoto(file, UUID.randomUUID());
            assertNotNull(result);
        }

        @Test
        @DisplayName("Tam 15MB dosya kabul edilmeli")
        void shouldAcceptFileExactly15Mb() throws IOException {
            long exactly15Mb = 15 * 1024 * 1024;
            setupValidUpload("image/jpeg", "photo.jpg", exactly15Mb);
            String result = storageService.uploadPetPhoto(file, UUID.randomUUID());
            assertNotNull(result);
        }

        @Test
        @DisplayName("15MB üstü dosya reddedilmeli — FileTooLargeException")
        void shouldRejectFileOver15Mb() {
            long over15Mb = 15 * 1024 * 1024 + 1;
            setupInvalidFile("image/jpeg", "big.jpg", over15Mb);
            assertThrows(FileTooLargeException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
        }

        @Test
        @DisplayName("Boş dosya reddedilmeli — StorageException")
        void shouldRejectEmptyFile() {
            when(file.isEmpty()).thenReturn(true);
            assertThrows(StorageException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
        }
    }

    // =========================================================================
    // Checklist 3: Supabase Storage hata yönetimi — uygulama çökmemeli
    // =========================================================================
    @Nested
    @DisplayName("Supabase Storage hata yönetimi")
    class SupabaseErrorTests {

        @Test
        @DisplayName("Supabase timeout — StorageException fırlatılmalı, uygulama çökmemeli")
        void shouldThrowStorageExceptionOnTimeout() throws IOException {
            setupFileForUpload("image/jpeg", "photo.jpg", 1024);
            when(restClient.post()).thenReturn(requestBodyUriSpec);
            when(requestBodyUriSpec.uri(anyString(), anyString(), anyString())).thenReturn(requestBodySpec);
            when(requestBodySpec.contentType(any(MediaType.class))).thenReturn(requestBodySpec);
            when(requestBodySpec.header(anyString(), anyString())).thenReturn(requestBodySpec);
            when(requestBodySpec.body(any(byte[].class))).thenReturn(requestBodySpec);
            when(requestBodySpec.retrieve()).thenThrow(new RestClientException("Connection timed out"));

            StorageException ex = assertThrows(StorageException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
            assertTrue(ex.getMessage().contains("Supabase Storage isteği başarısız"));
        }

        @Test
        @DisplayName("Supabase erişim hatası (403) — StorageException fırlatılmalı")
        void shouldThrowStorageExceptionOnAccessDenied() throws IOException {
            setupFileForUpload("image/jpeg", "photo.jpg", 1024);
            when(restClient.post()).thenReturn(requestBodyUriSpec);
            when(requestBodyUriSpec.uri(anyString(), anyString(), anyString())).thenReturn(requestBodySpec);
            when(requestBodySpec.contentType(any(MediaType.class))).thenReturn(requestBodySpec);
            when(requestBodySpec.header(anyString(), anyString())).thenReturn(requestBodySpec);
            when(requestBodySpec.body(any(byte[].class))).thenReturn(requestBodySpec);
            when(requestBodySpec.retrieve()).thenThrow(new RestClientException("403 Forbidden"));

            StorageException ex = assertThrows(StorageException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
            assertTrue(ex.getMessage().contains("Supabase Storage isteği başarısız"));
        }

        @Test
        @DisplayName("IOException — StorageException fırlatılmalı")
        void shouldThrowStorageExceptionOnIOException() throws IOException {
            setupFileForUpload("image/jpeg", "photo.jpg", 1024);
            when(file.getBytes()).thenThrow(new IOException("Disk error"));

            // RestClient.post() çağrılmadan önce file.getBytes() patlar
            when(restClient.post()).thenReturn(requestBodyUriSpec);
            when(requestBodyUriSpec.uri(anyString(), anyString(), anyString())).thenReturn(requestBodySpec);
            when(requestBodySpec.contentType(any(MediaType.class))).thenReturn(requestBodySpec);
            when(requestBodySpec.header(anyString(), anyString())).thenReturn(requestBodySpec);

            StorageException ex = assertThrows(StorageException.class,
                    () -> storageService.uploadPetPhoto(file, UUID.randomUUID()));
            assertTrue(ex.getMessage().contains("Dosya yüklenirken hata"));
        }
    }

    // =========================================================================
    // Başarılı upload — URL formatı doğrulaması
    // =========================================================================
    @Nested
    @DisplayName("Başarılı upload")
    class SuccessTests {

        @Test
        @DisplayName("Dönen URL doğru formatta olmalı ve cache-busting versiyon parametresi taşımalı")
        void shouldReturnCorrectPublicUrl() throws IOException {
            UUID petId = UUID.randomUUID();
            setupValidUpload("image/jpeg", "photo.jpg", 1024);
            String result = storageService.uploadPetPhoto(file, petId);
            String expectedBase = STORAGE_URL + "/object/public/pet-photos/" + petId;
            assertTrue(result.startsWith(expectedBase + "?v="));
        }

        @Test
        @DisplayName("Object key uzantı taşımamalı — farklı formatla yeniden yüklemede aynı key kullanılmalı (P2 fix)")
        void shouldUseSameObjectKeyRegardlessOfOriginalFileExtension() throws IOException {
            UUID petId = UUID.randomUUID();

            setupValidUpload("image/png", "screenshot.png", 2048);
            String pngResult = storageService.uploadPetPhoto(file, petId);

            setupValidUpload("image/jpeg", "photo.jpg", 2048);
            String jpgResult = storageService.uploadPetPhoto(file, petId);

            String pngBase = pngResult.substring(0, pngResult.indexOf('?'));
            String jpgBase = jpgResult.substring(0, jpgResult.indexOf('?'));

            assertEquals(pngBase, jpgBase);
            assertEquals(STORAGE_URL + "/object/public/pet-photos/" + petId, pngBase);
            // İkisi de aynı obje yolunu (petId) hedeflediği için Supabase tarafında
            // x-upsert=true ile eskisi ezilir, öksüz dosya kalmaz.
            verify(requestBodyUriSpec, times(2)).uri("/object/{bucket}/{path}", "pet-photos", petId.toString());
        }
    }

    // =========================================================================
    // Fotoğraf silme (DELETE /pets/{id}/photo) — StorageService.deletePetPhoto
    // =========================================================================
    @Nested
    @DisplayName("Fotoğraf silme")
    class DeletePhotoTests {

        @Test
        @DisplayName("silme isteği her zaman petId'den üretilen path'i hedeflemeli — istemciden gelen bir URL güvenilmez (P1 fix)")
        void shouldDeleteUsingPetIdDerivedPath() {
            UUID petId = UUID.randomUUID();

            when(restClient.delete()).thenReturn(requestHeadersUriSpec);
            when(requestHeadersUriSpec.uri("/object/{bucket}/{path}", "pet-photos", petId.toString()))
                    .thenReturn(requestHeadersUriSpec);
            when(requestHeadersUriSpec.retrieve()).thenReturn(responseSpec);
            when(responseSpec.toBodilessEntity()).thenReturn(null);

            storageService.deletePetPhoto(petId);

            verify(requestHeadersUriSpec).uri("/object/{bucket}/{path}", "pet-photos", petId.toString());
        }

        @Test
        @DisplayName("Supabase silme isteği başarısız olursa StorageException fırlatılmalı")
        void shouldThrowStorageExceptionWhenDeleteFails() {
            UUID petId = UUID.randomUUID();

            when(restClient.delete()).thenReturn(requestHeadersUriSpec);
            when(requestHeadersUriSpec.uri(anyString(), anyString(), anyString())).thenReturn(requestHeadersUriSpec);
            when(requestHeadersUriSpec.retrieve()).thenThrow(new RestClientException("404 Not Found"));

            StorageException ex = assertThrows(StorageException.class,
                    () -> storageService.deletePetPhoto(petId));
            assertTrue(ex.getMessage().contains("Supabase Storage silme isteği başarısız"));
        }
    }

    // =========================================================================
    // Helper metodlar
    // =========================================================================

    private void setupValidUpload(String contentType, String filename, long size) throws IOException {
        setupFileForUpload(contentType, filename, size);
        when(restClient.post()).thenReturn(requestBodyUriSpec);
        when(requestBodyUriSpec.uri(anyString(), anyString(), anyString())).thenReturn(requestBodySpec);
        when(requestBodySpec.contentType(any(MediaType.class))).thenReturn(requestBodySpec);
        when(requestBodySpec.header(anyString(), anyString())).thenReturn(requestBodySpec);
        when(requestBodySpec.body(any(byte[].class))).thenReturn(requestBodySpec);
        when(requestBodySpec.retrieve()).thenReturn(responseSpec);
        when(responseSpec.toBodilessEntity()).thenReturn(null);
    }

    private void setupFileForUpload(String contentType, String filename, long size) throws IOException {
        when(file.isEmpty()).thenReturn(false);
        when(file.getContentType()).thenReturn(contentType);
        when(file.getSize()).thenReturn(size);
        when(file.getBytes()).thenReturn(new byte[(int) Math.min(size, 1024)]);
    }

    private void setupInvalidFile(String contentType, String filename, long size) {
        when(file.isEmpty()).thenReturn(false);
        when(file.getSize()).thenReturn(size);
        lenient().when(file.getContentType()).thenReturn(contentType);
    }
}
