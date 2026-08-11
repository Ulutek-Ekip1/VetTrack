package com.vettrack.api.config;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class RateLimitingFilterTest {

    private RateLimitingFilter rateLimitingFilter;
    private FilterChain filterChain;

    @BeforeEach
    void setUp() {
        rateLimitingFilter = new RateLimitingFilter();
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
        rateLimitingFilter.setTrustedProxyHeaderEnabled(false);

        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/login");
        request.setRemoteAddr("10.0.0.1");
        request.addHeader("X-Forwarded-For", "203.0.113.195");

        MockHttpServletResponse response = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(request, response, filterChain);

        assertTrue(rateLimitingFilter.getRequestTrackers().containsKey("10.0.0.1"));
        assertFalse(rateLimitingFilter.getRequestTrackers().containsKey("203.0.113.195"));
    }

    @Test
    void shouldHonorXForwardedForWhenTrusted() throws Exception {
        rateLimitingFilter.setTrustedProxyHeaderEnabled(true);

        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/login");
        request.setRemoteAddr("10.0.0.1");
        request.addHeader("X-Forwarded-For", "203.0.113.195, 10.0.0.1");

        MockHttpServletResponse response = new MockHttpServletResponse();
        rateLimitingFilter.doFilterInternal(request, response, filterChain);

        assertTrue(rateLimitingFilter.getRequestTrackers().containsKey("203.0.113.195"));
    }
}
