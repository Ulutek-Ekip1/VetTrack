package com.vettrack.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.ClientHttpRequestFactory;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;

@Configuration
public class StorageConfig {

    @Value("${supabase.storage.url}")
    private String storageUrl;

    @Value("${supabase.storage.service-key}")
    private String serviceKey;

    private ClientHttpRequestFactory createRequestFactory() {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout((int) Duration.ofSeconds(5).toMillis());
        requestFactory.setReadTimeout((int) Duration.ofSeconds(10).toMillis());
        return requestFactory;
    }

    @Bean
    public RestClient supabaseStorageClient() {
        return RestClient.builder()
                .baseUrl(storageUrl)
                .requestFactory(createRequestFactory())
                .defaultHeader("Authorization", "Bearer " + serviceKey)
                .defaultHeader("apikey", serviceKey)
                .build();
    }

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate(createRequestFactory());
    }
}