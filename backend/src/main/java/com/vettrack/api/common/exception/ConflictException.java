package com.vettrack.api.common.exception;

public class ConflictException extends ApiException {

    public ConflictException(String message) {
        super(ErrorCode.CONFLICT, message);
    }

    public ConflictException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }

    public ConflictException(String message, Throwable cause) {
        super(ErrorCode.CONFLICT, message, cause);
    }
}
