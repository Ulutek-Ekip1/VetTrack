package com.vettrack.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestTemplate;

@Configuration
public class StorageConfig {

    @Value("${supabase.storage.url}")
    private String storageUrl;

    @Value("${supabase.storage.service-key}")
    private String serviceKey;

    @Bean
    public RestClient supabaseStorageClient() {
        return RestClient.builder()
                .baseUrl(storageUrl)
                .defaultHeader("Authorization", "Bearer " + serviceKey)
                .defaultHeader("apikey", serviceKey)
                .build();
    }

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
}