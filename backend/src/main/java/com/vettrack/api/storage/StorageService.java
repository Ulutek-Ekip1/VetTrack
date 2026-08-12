package com.vettrack.api.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

@Service
public class StorageService {

    private final RestClient storageClient;
    private final String storageUrl;

    private static final String BUCKET = "pet-photos";
    private static final long MAX_FILE_SIZE = 15 * 1024 * 1024;
    private static final Set<String> ALLOWED_TYPES = Set.of(
            "image/jpeg", "image/jpg", "image/png", "image/webp"
    );

    public StorageService(RestClient supabaseStorageClient,
                          @Value("${supabase.storage.url}") String storageUrl) {
        this.storageClient = supabaseStorageClient;
        this.storageUrl = storageUrl;
    }

    public String uploadPetPhoto(MultipartFile file, UUID petId) {
        validateFile(file);

        // Object key kasıtlı olarak uzantısız ve tek: petId. Doğru Content-Type upload'da
        // ayarlandığı için sunum bundan etkilenmez; bu sayede (a) silme işlemi hiçbir zaman
        // istemciden gelen bir URL string'ine güvenmeden doğrudan petId'den path üretebilir,
        // (b) farklı formatla yeniden yüklemede eski dosya bucket'ta öksüz kalmaz — aynı key
        // x-upsert ile ezilir.
        String filePath = petId.toString();

        try {
            storageClient.post()
                    .uri("/object/{bucket}/{path}", BUCKET, filePath)
                    .contentType(MediaType.parseMediaType(file.getContentType()))
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

    private void validateFile(MultipartFile file) {
        if (file.isEmpty()) {
            throw new StorageException("Dosya boş olamaz");
        }
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new FileTooLargeException("Dosya boyutu 15MB'ı aşamaz");
        }
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_TYPES.contains(contentType)) {
            throw new UnsupportedFileTypeException(
                    "Sadece JPEG, PNG ve WebP formatları kabul edilir"
            );
        }
    }
}
