package com.vettrack.api.config;

import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.crypto.ECDSASigner;
import com.nimbusds.jose.jwk.Curve;
import com.nimbusds.jose.jwk.ECKey;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.gen.ECKeyGenerator;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Date;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Supabase signs JWTs with ES256, not RS256. Spring's jwk-set-uri
 * autoconfiguration only accepts RS256 unless jws-algorithms is set
 * explicitly (see application.yml). This test signs a token the same
 * way Supabase does and decodes it through the real JwtDecoder bean,
 * so it fails if that config line is ever removed or broken.
 */
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:es256testdb;DB_CLOSE_DELAY=-1",
    "spring.datasource.driver-class-name=org.h2.Driver",
    "spring.flyway.enabled=false",
    "spring.jpa.hibernate.ddl-auto=create-drop",
    "SUPABASE_URL=https://localhost",
    "SUPABASE_JWT_ISSUER=https://localhost/auth/v1",
    "SUPABASE_STORAGE_URL=https://localhost/storage/v1",
    "SUPABASE_SERVICE_KEY=mock-key",
    "supabase.storage.url=https://localhost/storage/v1",
    "supabase.storage.service-key=mock-key",
    "FIREBASE_CREDENTIALS_PATH=mock-path"
})
class Es256JwtDecoderTest {

    private static HttpServer jwksServer;
    private static ECKey signingKey;

    @DynamicPropertySource
    static void registerFakeJwks(DynamicPropertyRegistry registry) throws Exception {
        signingKey = new ECKeyGenerator(Curve.P_256).keyID("test-kid").generate();
        String jwksBody = new JWKSet(signingKey.toPublicJWK()).toString();

        jwksServer = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        jwksServer.createContext("/jwks", exchange -> {
            byte[] body = jwksBody.getBytes(StandardCharsets.UTF_8);
            exchange.getResponseHeaders().set("Content-Type", "application/json");
            exchange.sendResponseHeaders(200, body.length);
            exchange.getResponseBody().write(body);
            exchange.close();
        });
        jwksServer.start();

        int port = jwksServer.getAddress().getPort();
        registry.add("SUPABASE_JWKS_URL", () -> "http://127.0.0.1:" + port + "/jwks");
    }

    @AfterAll
    static void stopJwksServer() {
        if (jwksServer != null) {
            jwksServer.stop(0);
        }
    }

    @Autowired
    private JwtDecoder jwtDecoder;

    @Test
    @DisplayName("decodes an ES256-signed token via the real jwk-set-uri decoder")
    void decodesEs256SignedToken() throws JOSEException {
        Jwt decoded = jwtDecoder.decode(signEs256Token());

        assertEquals("test-subject", decoded.getSubject());
    }

    private String signEs256Token() throws JOSEException {
        JWTClaimsSet claims = new JWTClaimsSet.Builder()
            .subject("test-subject")
            .issueTime(Date.from(Instant.now()))
            .expirationTime(Date.from(Instant.now().plusSeconds(3600)))
            .build();

        SignedJWT jwt = new SignedJWT(
            new JWSHeader.Builder(JWSAlgorithm.ES256).keyID(signingKey.getKeyID()).build(),
            claims
        );
        jwt.sign(new ECDSASigner(signingKey));
        return jwt.serialize();
    }
}
