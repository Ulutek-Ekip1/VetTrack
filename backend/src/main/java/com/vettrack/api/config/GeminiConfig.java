package com.vettrack.api.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

import java.time.Duration;

@Slf4j
@Configuration
public class GeminiConfig {

    @Value("${gemini.api-key:}")
    private String apiKey;

    @Value("${gemini.connect-timeout-seconds:15}")
    private int connectTimeoutSeconds;

    @Value("${gemini.read-timeout-seconds:60}")
    private int readTimeoutSeconds;

    @Bean
    public RestClient geminiRestClient() {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            log.warn("Gemini API key is not configured! Please set GEMINI_API_KEY in environment or .env.");
        } else {
            log.info("Gemini API client initialized with key length: {}", apiKey.length());
        }

        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout((int) Duration.ofSeconds(connectTimeoutSeconds).toMillis());
        requestFactory.setReadTimeout((int) Duration.ofSeconds(readTimeoutSeconds).toMillis());

        return RestClient.builder()
                .baseUrl("https://generativelanguage.googleapis.com")
                .requestFactory(requestFactory)
                .defaultHeader("Content-Type", "application/json")
                .defaultHeader("x-goog-api-key", apiKey != null ? apiKey.trim() : "")
                .build();
    }
}
