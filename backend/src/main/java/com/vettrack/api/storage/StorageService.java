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
import java.util.Map;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;
import org.springframework.core.ParameterizedTypeReference;

@Service
public class StorageService {

    private final RestClient storageClient;
    private final String storageUrl;
    private final Tika tika = new Tika();

    private static final String BUCKET = "pet-photos";
    private static final String TREATMENT_BUCKET = "treatment-attachments";
    private static final long MAX_FILE_SIZE = 15 * 1024 * 1024;
    private static final Set<String> ALLOWED_TYPES = Set.of(
            "image/jpeg", "image/png", "image/webp", "application/pdf"
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

    public String generateSignedUploadUrl(String path, String contentType, long fileSize) {
        if (fileSize > MAX_FILE_SIZE) {
            throw new FileTooLargeException("Dosya boyutu 15MB'ı aşamaz");
        }
        
        String declaredType = normalizeMimeType(contentType);
        if (declaredType == null || !ALLOWED_TYPES.contains(declaredType)) {
            throw new UnsupportedFileTypeException(
                    "Geçersiz dosya formatı. (Desteklenenler: JPEG, PNG, WebP, PDF)"
            );
        }

        try {
            Map<String, Object> response = storageClient.post()
                    .uri("/object/upload/sign/{bucket}/{path}", TREATMENT_BUCKET, path)
                    .body(Map.of("expiresIn", 900)) // 15 dakika geçerli
                    .retrieve()
                    .body(new ParameterizedTypeReference<Map<String, Object>>() {});
                    
            if (response != null && response.containsKey("url")) {
                return storageUrl + response.get("url").toString();
            } else if (response != null && response.containsKey("signedURL")) {
                return storageUrl + response.get("signedURL").toString();
            } else if (response != null && response.containsKey("signedUrl")) {
                return storageUrl + response.get("signedUrl").toString(); // Bazı SDK sürümleri farklı dönebilir
            }
            throw new StorageException("Upload URL yanıtı çözümlenemedi.");
        } catch (org.springframework.web.client.RestClientException e) {
            throw new StorageException("Supabase Storage Signed Upload URL alınamadı: " + e.getMessage(), e);
        }
    }

    public String generateSignedReadUrl(String path) {
        try {
            Map<String, Object> response = storageClient.post()
                    .uri("/object/sign/{bucket}/{path}", TREATMENT_BUCKET, path)
                    .body(Map.of("expiresIn", 3600)) // 1 saat geçerli
                    .retrieve()
                    .body(new ParameterizedTypeReference<Map<String, Object>>() {});
                    
            if (response != null && response.containsKey("signedURL")) {
                // Read için signedURL genellikle tam URL olarak (dizin/token vb.) döner. Bazen sadece token veya path dönebilir.
                String urlOrPath = response.get("signedURL").toString();
                if (urlOrPath.startsWith("http")) {
                    return urlOrPath;
                }
                return storageUrl + urlOrPath;
            } else if (response != null && response.containsKey("signedUrl")) {
                String urlOrPath = response.get("signedUrl").toString();
                if (urlOrPath.startsWith("http")) return urlOrPath;
                return storageUrl + urlOrPath;
            }
            throw new StorageException("Read URL yanıtı çözümlenemedi.");
        } catch (org.springframework.web.client.RestClientException e) {
            throw new StorageException("Supabase Storage Signed Read URL alınamadı: " + e.getMessage(), e);
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
