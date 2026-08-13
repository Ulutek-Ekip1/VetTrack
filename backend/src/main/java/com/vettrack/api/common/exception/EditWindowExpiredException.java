package com.vettrack.api.common.exception;

/**
 * 15 dakikalık düzenleme/silme penceresi dolduğunda fırlatılır (EC-08).
 * ErrorCode.EDIT_WINDOW_EXPIRED ile HTTP 403 döner.
 */
public class EditWindowExpiredException extends ApiException {
    public EditWindowExpiredException(String message) {
        super(ErrorCode.EDIT_WINDOW_EXPIRED, message);
    }
}
