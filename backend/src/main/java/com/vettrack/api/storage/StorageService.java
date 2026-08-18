package com.vettrack.api.storage;

import org.apache.tika.Tika;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class StorageService {

    private final RestClient storageClient;
    private final String storageUrl;
    private final Tika tika = new Tika();

    private static final String BUCKET = "pet-photos";
    private static final String OWNER_BUCKET = "owner-photos";
    private static final long MAX_FILE_SIZE = 15 * 1024 * 1024;
    private static final Set<String> ALLOWED_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp"
    );

    public StorageService(RestClient supabaseStorageClient,
                          @Value("${supabase.storage.url}") String storageUrl) {
        this.storageClient = supabaseStorageClient;
        this.storageUrl = storageUrl;
    }

    public String uploadPetPhoto(MultipartFile file, UUID petId) {
        String canonicalMimeType = validateFile(file);

        // Object key kasıtlı olarak uzantısız ve tek: petId. Doğru Content-Type upload'da
        // ayarlandığı için sunum bundan etkilenmez; bu sayede (a) silme işlemi hiçbir zaman
        // istemciden gelen bir URL string'ine güvenmeden doğrudan petId'den path üretebilir,
        // (b) farklı formatla yeniden yüklemede eski dosya bucket'ta öksüz kalmaz — aynı key
        // x-upsert ile ezilir.
        String filePath = petId.toString();

        try {
            storageClient.post()
                    .uri("/object/{bucket}/{path}", BUCKET, filePath)
                    .contentType(MediaType.parseMediaType(canonicalMimeType))
                    .header("x-upsert", "true")
                    .body(file.getBytes())
                    .retrieve()
                    .toBodilessEntity();
        } catch (IOException e) {
            throw new StorageException("Dosya yüklenirken hata oluştu", e);
        } catch (org.springframework.web.client.RestClientException e) {
            throw new StorageException("Supabase Storage isteği başarısız: " + e.getMessage(), e);
        }

        // CDN/istemci önbelleğinin fotoğraf güncellendiğinde eskisini göstermemesi için
        // URL her yüklemede değişen bir versiyon parametresi taşır.
        return storageUrl + "/object/public/" + BUCKET + "/" + filePath + "?v=" + System.currentTimeMillis();
    }

    public void deletePetPhoto(UUID petId) {
        try {
            storageClient.delete()
                    .uri("/object/{bucket}/{path}", BUCKET, petId.toString())
                    .retrieve()
                    .toBodilessEntity();
        } catch (org.springframework.web.client.RestClientException e) {
            throw new StorageException("Supabase Storage silme isteği başarısız: " + e.getMessage(), e);
        }
    }

    public String uploadOwnerPhoto(MultipartFile file, UUID ownerId) {
        String canonicalMimeType = validateFile(file);
        String filePath = ownerId.toString();

        try {
            storageClient.post()
                    .uri("/object/{bucket}/{path}", OWNER_BUCKET, filePath)
                    .contentType(MediaType.parseMediaType(canonicalMimeType))
                    .header("x-upsert", "true")
                    .body(file.getBytes())
                    .retrieve()
                    .toBodilessEntity();
        } catch (IOException e) {
            throw new StorageException("Dosya yüklenirken hata oluştu", e);
        } catch (org.springframework.web.client.RestClientException e) {
            throw new StorageException("Supabase Storage isteği başarısız: " + e.getMessage(), e);
        }

        return storageUrl + "/object/public/" + OWNER_BUCKET + "/" + filePath + "?v=" + System.currentTimeMillis();
    }

    public void deleteOwnerPhoto(UUID ownerId) {
        try {
            storageClient.delete()
                    .uri("/object/{bucket}/{path}", OWNER_BUCKET, ownerId.toString())
                    .retrieve()
                    .toBodilessEntity();
        } catch (org.springframework.web.client.RestClientException e) {
            throw new StorageException("Supabase Storage silme isteği başarısız: " + e.getMessage(), e);
        }
    }

    private String validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new StorageException("Dosya boş olamaz");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new FileTooLargeException("Dosya boyutu 15MB'ı aşamaz");
        }

        // 1. İstemcinin beyan ettiği Content-Type kontrolü
        String declaredType = normalizeMimeType(file.getContentType());
        if (declaredType == null || !ALLOWED_TYPES.contains(declaredType)) {
            throw new UnsupportedFileTypeException(
                    "Sadece JPEG, PNG ve WebP formatları kabul edilir"
            );
        }

        // 2. Magic bytes (gerçek içerik) kontrolü
        String detectedType;
        try (InputStream is = new BufferedInputStream(file.getInputStream())) {
            detectedType = normalizeMimeType(tika.detect(is));
        } catch (IOException e) {
            throw new StorageException("Dosya içeriği doğrulanamadı", e);
        }

        if (detectedType == null || !ALLOWED_TYPES.contains(detectedType)) {
            throw new UnsupportedFileTypeException(
                    "Dosya içeriği geçersiz veya desteklenmeyen formatta (sadece JPEG, PNG ve WebP kabul edilir)"
            );
        }

        // 3. Beyan edilen tür ile gerçek içerik eşleşme kontrolü (header spoofing koruması)
        if (!declaredType.equals(detectedType)) {
            throw new UnsupportedFileTypeException(
                    "Beyan edilen dosya türü (" + file.getContentType() + ") ile gerçek dosya içeriği (" + detectedType + ") uyuşmuyor"
            );
        }

        return detectedType;
    }

    private String normalizeMimeType(String mimeType) {
        if (mimeType == null || mimeType.isBlank()) {
            return null;
        }
        String normalized = mimeType.trim().toLowerCase(Locale.ROOT);
        if ("image/jpg".equals(normalized)) {
            return "image/jpeg";
        }
        return normalized;
    }
}
