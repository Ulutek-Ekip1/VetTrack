package com.vettrack.api.config;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class RateLimitingFilterTest {

    private RateLimitingFilter rateLimitingFilter;
    private RateLimitProperties properties;
    private FilterChain filterChain;

    @BeforeEach
    void setUp() {
        properties = new RateLimitProperties();
        properties.setTrustedProxyHeaderEnabled(false);

        RateLimitProperties.EndpointRule loginRule = new RateLimitProperties.EndpointRule();
        loginRule.setPaths(List.of("/auth/login", "/api/auth/login"));
        loginRule.setMaxRequests(10);
        loginRule.setWindowSeconds(60);

        RateLimitProperties.EndpointRule registerRule = new RateLimitProperties.EndpointRule();
        registerRule.setPaths(List.of("/auth/register", "/api/auth/register"));
        registerRule.setMaxRequests(10);
        registerRule.setWindowSeconds(60);

        RateLimitProperties.EndpointRule resendRule = new RateLimitProperties.EndpointRule();
        resendRule.setPaths(List.of("/auth/resend-verification", "/api/auth/resend-verification"));
        resendRule.setMaxRequests(3);
        resendRule.setWindowSeconds(3600);

        properties.setEndpoints(List.of(loginRule, registerRule, resendRule));

        rateLimitingFilter = new RateLimitingFilter(properties);
        rateLimitingFilter.initFilterBean();
        filterChain = mock(FilterChain.class);
    }

    @Test
    void shouldAllowRequestsUnderThreshold() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/login");
        request.setRemoteAddr("192.168.1.100");

        for (int i = 0; i < 10; i++) {
            MockHttpServletResponse response = new MockHttpServletResponse();
            rateLimitingFilter.doFilterInternal(request, response, filterChain);
            assertEquals(200, response.getStatus());
        }
        verify(filterChain, times(10)).doFilter(eq(request), any());
    }

    @Test
    void shouldBlockRequestsExceedingThreshold() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/login");
        request.setRemoteAddr("192.168.1.101");

        for (int i = 0; i < 10; i++) {
            MockHttpServletResponse response = new MockHttpServletResponse();
            rateLimitingFilter.doFilterInternal(request, response, filterChain);
        }

        MockHttpServletResponse blockedResponse = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(request, blockedResponse, filterChain);

        assertEquals(429, blockedResponse.getStatus());
        assertTrue(blockedResponse.getContentAsString().contains("TOO_MANY_REQUESTS"));
    }

    @Test
    void shouldIgnoreXForwardedForByDefaultWhenNotTrusted() throws Exception {
        properties.setTrustedProxyHeaderEnabled(false);

        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/login");
        request.setRemoteAddr("10.0.0.1");
        request.addHeader("X-Forwarded-For", "203.0.113.195");

        MockHttpServletResponse response = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(request, response, filterChain);

        assertTrue(rateLimitingFilter.getRequestTrackers().containsKey("10.0.0.1:/auth/login"));
        assertFalse(rateLimitingFilter.getRequestTrackers().containsKey("203.0.113.195:/auth/login"));
    }

    @Test
    void shouldHonorXForwardedForWhenTrusted() throws Exception {
        properties.setTrustedProxyHeaderEnabled(true);

        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/login");
        request.setRemoteAddr("10.0.0.1");
        request.addHeader("X-Forwarded-For", "203.0.113.195, 10.0.0.1");

        MockHttpServletResponse response = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(request, response, filterChain);

        assertTrue(rateLimitingFilter.getRequestTrackers().containsKey("203.0.113.195:/auth/login"));
    }

    @Test
    void shouldTrackDifferentEndpointsIndependently() throws Exception {
        // Same IP hits both /auth/login and /auth/register — should be tracked separately.
        String ip = "192.168.1.200";

        MockHttpServletRequest loginRequest = new MockHttpServletRequest("POST", "/auth/login");
        loginRequest.setRemoteAddr(ip);
        MockHttpServletRequest registerRequest = new MockHttpServletRequest("POST", "/auth/register");
        registerRequest.setRemoteAddr(ip);

        // 10 login requests — should max out login but not register
        for (int i = 0; i < 10; i++) {
            rateLimitingFilter.doFilterInternal(loginRequest, new MockHttpServletResponse(), filterChain);
        }

        // 11th login request must be blocked
        MockHttpServletResponse blockedLogin = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(loginRequest, blockedLogin, filterChain);
        assertEquals(429, blockedLogin.getStatus());

        // But register from same IP still allowed
        MockHttpServletResponse allowedRegister = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(registerRequest, allowedRegister, filterChain);
        assertEquals(200, allowedRegister.getStatus());
    }

    @Test
    void shouldEnforceStricterLimitOnResendVerification() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/resend-verification");
        request.setRemoteAddr("192.168.1.201");

        // First 3 should pass
        for (int i = 0; i < 3; i++) {
            MockHttpServletResponse response = new MockHttpServletResponse();
            rateLimitingFilter.doFilterInternal(request, response, filterChain);
            assertEquals(200, response.getStatus(), "Request " + (i + 1) + " should pass");
        }

        // 4th must be blocked (limit = 3/hour)
        MockHttpServletResponse blocked = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(request, blocked, filterChain);
        assertEquals(429, blocked.getStatus());
        assertTrue(blocked.getContentAsString().contains("TOO_MANY_REQUESTS"));
    }

    @Test
    void shouldSkipUnknownPaths() throws Exception {
        // /pets is not in the rule list — should always pass through
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/pets");
        request.setRemoteAddr("192.168.1.202");

        for (int i = 0; i < 50; i++) {
            MockHttpServletResponse response = new MockHttpServletResponse();
            rateLimitingFilter.doFilterInternal(request, response, filterChain);
            assertEquals(200, response.getStatus());
        }
        verify(filterChain, times(50)).doFilter(eq(request), any());
    }
}
