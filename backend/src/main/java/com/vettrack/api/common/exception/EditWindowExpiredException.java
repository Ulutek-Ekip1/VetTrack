package com.vettrack.api.common.exception;

/**
 * 15 dakikalık düzenleme/silme penceresi dolduğunda fırlatılır (EC-08).
 */
public class EditWindowExpiredException extends RuntimeException {
    public EditWindowExpiredException(String message) {
        super(message);
    }
}