package com.vettrack.api.auth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private Integer expiresIn;
    private Object user; // Supabase raw user payload

    public static AuthResponseBuilder builder() {
        return new AuthResponseBuilder();
    }

    public static class AuthResponseBuilder {
        private String accessToken;
        private String refreshToken;
        private String tokenType;
        private Integer expiresIn;
        private Object user;

        public AuthResponseBuilder accessToken(String accessToken) { this.accessToken = accessToken; return this; }
        public AuthResponseBuilder refreshToken(String refreshToken) { this.refreshToken = refreshToken; return this; }
        public AuthResponseBuilder tokenType(String tokenType) { this.tokenType = tokenType; return this; }
        public AuthResponseBuilder expiresIn(Integer expiresIn) { this.expiresIn = expiresIn; return this; }
        public AuthResponseBuilder user(Object user) { this.user = user; return this; }

        public AuthResponse build() {
            AuthResponse a = new AuthResponse();
            a.accessToken = this.accessToken;
            a.refreshToken = this.refreshToken;
            a.tokenType = this.tokenType;
            a.expiresIn = this.expiresIn;
            a.user = this.user;
            return a;
        }
    }

    public String getAccessToken() { return accessToken; }
    public void setAccessToken(String accessToken) { this.accessToken = accessToken; }
    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
    public String getTokenType() { return tokenType; }
    public void setTokenType(String tokenType) { this.tokenType = tokenType; }
    public Integer getExpiresIn() { return expiresIn; }
    public void setExpiresIn(Integer expiresIn) { this.expiresIn = expiresIn; }
    public Object getUser() { return user; }
    public void setUser(Object user) { this.user = user; }
}