package com.vettrack.api.notification;

import org.junit.jupiter.api.Test;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.test.util.ReflectionTestUtils;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

/**
 * FIREBASE_CREDENTIALS_JSON (Railway secret'ı) FIREBASE_CREDENTIALS_PATH'e göre öncelikli olmalı;
 * ikisi de yoksa Firebase pasif bırakılmalı (uygulama açılışını engellememeli).
 */
class FirebaseConfigTest {

    private final FirebaseConfig firebaseConfig = new FirebaseConfig(new DefaultResourceLoader());

    @Test
    void whenCredentialsJsonProvided_thenUsesItRegardlessOfPath() throws IOException {
        String fakeJson = "{\"type\":\"service_account\"}";
        ReflectionTestUtils.setField(firebaseConfig, "credentialsJson", fakeJson);
        ReflectionTestUtils.setField(firebaseConfig, "credentialsPath", "classpath:does-not-matter.json");

        try (InputStream result = (InputStream) ReflectionTestUtils.invokeMethod(firebaseConfig, "resolveCredentialsStream")) {
            assertArrayEquals(fakeJson.getBytes(StandardCharsets.UTF_8), result.readAllBytes());
        }
    }

    @Test
    void whenNeitherJsonNorPathProvided_thenReturnsNull() {
        ReflectionTestUtils.setField(firebaseConfig, "credentialsJson", "");
        ReflectionTestUtils.setField(firebaseConfig, "credentialsPath", "");

        InputStream result = (InputStream) ReflectionTestUtils.invokeMethod(firebaseConfig, "resolveCredentialsStream");
        assertNull(result);
    }

    @Test
    void whenJsonBlankAndPathPointsToMissingResource_thenReturnsNull() {
        ReflectionTestUtils.setField(firebaseConfig, "credentialsJson", "   ");
        ReflectionTestUtils.setField(firebaseConfig, "credentialsPath", "classpath:this-file-does-not-exist.json");

        InputStream result = (InputStream) ReflectionTestUtils.invokeMethod(firebaseConfig, "resolveCredentialsStream");
        assertNull(result);
    }
}
