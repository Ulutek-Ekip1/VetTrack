package com.vettrack.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.vettrack.api.auth.JwtAuthenticationFilter;
import com.vettrack.api.auth.CustomJwtAuthenticationConverter;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import com.nimbusds.jwt.JWTParser;

import java.text.ParseException;
import java.time.Instant;
import java.util.Map;
import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
public class SecurityConfig {

    @Value("${app.cors.allowed-origins:http://localhost:3000,http://localhost:8080,http://127.0.0.1:3000,http://127.0.0.1:8080}")
    private List<String> allowedOrigins;

    @Value("${app.cors.allowed-origin-patterns:}")
    private List<String> allowedOriginPatterns;

    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            JwtAuthenticationFilter jwtAuthenticationFilter,
            RateLimitingFilter rateLimitingFilter,
            CustomJwtAuthenticationConverter customJwtAuthenticationConverter
    ) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers(
                    "/auth/**",
                    "/clinics/invites/validate",
                    "/api/clinics/invites/validate",
                    "/v3/api-docs/**",
                    "/swagger-ui/**",
                    "/swagger-ui.html",
                    "/actuator/health",
                    "/actuator/info",
                    "/api/public/**",
                    "/error"
                ).permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(jwt ->
                jwt.jwtAuthenticationConverter(customJwtAuthenticationConverter)
            ))
            .addFilterBefore(rateLimitingFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterAfter(jwtAuthenticationFilter, BearerTokenAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(allowedOrigins);

        List<String> patterns = new java.util.ArrayList<>(Arrays.asList("http://localhost:*", "http://127.0.0.1:*"));
        if (allowedOriginPatterns != null) {
            patterns.addAll(allowedOriginPatterns.stream().filter(p -> !p.isBlank()).toList());
        }
        configuration.setAllowedOriginPatterns(patterns);
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "X-Auth-Token", "Accept", "X-Requested-With"));
        configuration.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    @Profile("local")
    public JwtDecoder jwtDecoder() {
        return token -> {
            try {
                com.nimbusds.jwt.JWT parsedJwt = JWTParser.parse(token);
                com.nimbusds.jwt.JWTClaimsSet claimsSet = parsedJwt.getJWTClaimsSet();

                Map<String, Object> claims = claimsSet.getClaims();
                Map<String, Object> headers = parsedJwt.getHeader().toJSONObject();

                Instant issuedAt = claimsSet.getIssueTime() != null ? claimsSet.getIssueTime().toInstant() : Instant.now();
                Instant expiresAt = claimsSet.getExpirationTime() != null ? claimsSet.getExpirationTime().toInstant() : Instant.now().plusSeconds(3600);

                return new Jwt(token, issuedAt, expiresAt, headers, claims);
            } catch (ParseException e) {
                throw new JwtException("Invalid JWT format", e);
            }
        };
    }
}
