package com.vettrack.api.notification;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@Slf4j
@Configuration
@RequiredArgsConstructor
public class FirebaseConfig {

    @Value("${firebase.credentials-json:}")
    private String credentialsJson;

    @Value("${firebase.credentials-path:}")
    private String credentialsPath;

    private final ResourceLoader resourceLoader;

    @PostConstruct
    public void initializeFirebase() {
        if (!FirebaseApp.getApps().isEmpty()) {
            return;
        }

        try (InputStream serviceAccount = resolveCredentialsStream()) {
            if (serviceAccount == null) {
                return;
            }

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            FirebaseApp.initializeApp(options);
            log.info("Firebase Application başarıyla başlatıldı.");
        } catch (Exception e) {
            log.error("Firebase başlatılırken hata oluştu: {}", e.getMessage(), e);
        }
    }

    /**
     * FIREBASE_CREDENTIALS_JSON (Railway'de secret olarak tutulan ham service-account JSON'ı)
     * varsa öncelikli kullanılır; boşsa dosya yolu tabanlı FIREBASE_CREDENTIALS_PATH fallback
     * olarak devreye girer. İkisi de tanımlı değilse Firebase pasif bırakılır, uygulama açılışını
     * engellemez.
     */
    private InputStream resolveCredentialsStream() throws IOException {
        if (credentialsJson != null && !credentialsJson.isBlank()) {
            return new ByteArrayInputStream(credentialsJson.getBytes(StandardCharsets.UTF_8));
        }

        if (credentialsPath == null || credentialsPath.isBlank()) {
            log.warn("Firebase credentials tanımlanmamış (ne FIREBASE_CREDENTIALS_JSON ne FIREBASE_CREDENTIALS_PATH). Firebase entegrasyonu pasif bırakılıyor.");
            return null;
        }

        Resource resource = resourceLoader.getResource(credentialsPath);
        if (!resource.exists()) {
            log.warn("Firebase JSON dosyası bulunamadı ({}). Bildirim servisi pasif kalacak.", credentialsPath);
            return null;
        }

        return resource.getInputStream();
    }
}
