package com.vettrack.api.ai.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.SERVICE_UNAVAILABLE)
public class GeminiApiException extends RuntimeException {

    private final int statusCode;

    public GeminiApiException(String message) {
        super(message);
        this.statusCode = 503;
    }

    public GeminiApiException(String message, int statusCode) {
        super(message);
        this.statusCode = statusCode;
    }

    public int getStatusCode() {
        return statusCode;
    }
}
