package com.vettrack.api.common.exception;

/**
 * Sözleşmeye bağlı hata kodu ({@link ErrorCode}) taşıyan tüm uygulama exception'larının tabanı.
 * GlobalExceptionHandler tek bir handler ile bunları yakalayıp koda göre HTTP status + error kodu döner.
 */
public class ApiException extends RuntimeException {

    private final ErrorCode errorCode;

    public ApiException(ErrorCode errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public ApiException(ErrorCode errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    public ErrorCode getErrorCode() {
        return errorCode;
    }
}
