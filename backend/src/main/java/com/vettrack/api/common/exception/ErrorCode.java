package com.vettrack.api.common.exception;

import org.springframework.http.HttpStatus;

/**
 * API sözleşmesindeki (docs/api-contract.md) makine-okunur hata kodlarının tek kaynağı.
 * Her kod, dönmesi gereken HTTP status'u da taşır. Yeni bir hata kodu eklenirken
 * hem burası hem de api-contract.md hata tablosu güncellenmelidir.
 */
public enum ErrorCode {
    // 400 Bad Request
    VALIDATION_ERROR(HttpStatus.BAD_REQUEST),
    MALFORMED_JSON(HttpStatus.BAD_REQUEST),

    // 401 Unauthorized
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED),
    EMAIL_NOT_VERIFIED(HttpStatus.UNAUTHORIZED),
    REAUTHENTICATION_REQUIRED(HttpStatus.UNAUTHORIZED),

    // 403 Forbidden
    FORBIDDEN(HttpStatus.FORBIDDEN),
    ROLE_MISMATCH(HttpStatus.FORBIDDEN),
    EDIT_WINDOW_EXPIRED(HttpStatus.FORBIDDEN),
    AI_CONSENT_REQUIRED(HttpStatus.FORBIDDEN),

    // 404 Not Found
    NOT_FOUND(HttpStatus.NOT_FOUND),
    PET_NOT_FOUND(HttpStatus.NOT_FOUND),

    // 409 Conflict
    CONFLICT(HttpStatus.CONFLICT),
    EMAIL_ALREADY_EXISTS(HttpStatus.CONFLICT),
    VISIT_ALREADY_OPEN(HttpStatus.CONFLICT),
    VISIT_ALREADY_CLOSED(HttpStatus.CONFLICT),
    VISIT_CLOSED(HttpStatus.CONFLICT),

    // 413 / 415
    FILE_TOO_LARGE(HttpStatus.CONTENT_TOO_LARGE),
    UNSUPPORTED_FILE_TYPE(HttpStatus.UNSUPPORTED_MEDIA_TYPE),

    // 429 Too Many Requests
    TOO_MANY_REQUESTS(HttpStatus.TOO_MANY_REQUESTS);

    private final HttpStatus status;

    ErrorCode(HttpStatus status) {
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }
}