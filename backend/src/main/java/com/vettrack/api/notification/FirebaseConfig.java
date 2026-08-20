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

import java.io.InputStream;

@Slf4j
@Configuration
@RequiredArgsConstructor
public class FirebaseConfig {

    @Value("${firebase.credentials-path:}")
    private String credentialsPath;

    private final ResourceLoader resourceLoader;

    @PostConstruct
    public void initializeFirebase() {
        if (credentialsPath == null || credentialsPath.isBlank()) {
            log.warn("Firebase credentials path tanımlanmamış. Firebase entegrasyonu pasif bırakılıyor.");
            return;
        }

        try {
            Resource resource = resourceLoader.getResource(credentialsPath);
            if (!resource.exists()) {
                log.warn("Firebase JSON dosyası bulunamadı ({}). Bildirim servisi pasif kalacak.", credentialsPath);
                return;
            }

            if (!FirebaseApp.getApps().isEmpty()) {
                return;
            }

            // try-with-resources ile InputStream otomatik olarak kapatılır
            try (InputStream serviceAccount = resource.getInputStream()) {
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
                log.info("Firebase Application başarıyla başlatıldı.");
            }
        } catch (Exception e) {
            log.error("Firebase başlatılırken hata oluştu: {}", e.getMessage(), e);
        }
    }
}