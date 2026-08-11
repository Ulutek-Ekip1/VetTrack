package com.vettrack.api.config.logging;

import ch.qos.logback.classic.spi.ILoggingEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class KvkkMaskingConverterTest {

    private KvkkMaskingConverter converter;

    @BeforeEach
    void setUp() {
        converter = new KvkkMaskingConverter();
    }

    @Test
    void shouldMaskPasswordInLogMessage() {
        ILoggingEvent event = mock(ILoggingEvent.class);
        when(event.getFormattedMessage()).thenReturn("User payload: {\"password\": \"secretPass123\"}");

        String result = converter.convert(event);
        assertFalse(result.contains("secretPass123"));
        assertTrue(result.contains("***MASKED***"));
    }

    @Test
    void shouldMaskEmailInLogMessage() {
        ILoggingEvent event = mock(ILoggingEvent.class);
        when(event.getFormattedMessage()).thenReturn("Login attempt for john.doe@example.com");

        String result = converter.convert(event);
        assertFalse(result.contains("john.doe@example.com"));
        assertTrue(result.contains("jo***@example.com"));
    }

    @Test
    void shouldMaskTCKNInLogMessage() {
        ILoggingEvent event = mock(ILoggingEvent.class);
        when(event.getFormattedMessage()).thenReturn("TCKN: 12345678901 requested data");

        String result = converter.convert(event);
        assertFalse(result.contains("12345678901"));
        assertTrue(result.contains("123*****01"));
    }

    @Test
    void shouldMaskPhoneNumberInLogMessage() {
        ILoggingEvent event = mock(ILoggingEvent.class);
        when(event.getFormattedMessage()).thenReturn("SMS sent to 05321234567");

        String result = converter.convert(event);
        assertFalse(result.contains("05321234567"));
        assertTrue(result.contains("0532*****67"));
    }
}
