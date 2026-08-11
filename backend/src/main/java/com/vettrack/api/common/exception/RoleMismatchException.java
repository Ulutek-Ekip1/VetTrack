package com.vettrack.api.common.exception;

/**
 * Thrown when a Supabase-authenticated user's role in JWT metadata does not match the
 * profile endpoint being accessed (e.g. a vet_staff hits /owners/me, or vice versa).
 * <p>
 * Handled by GlobalExceptionHandler as HTTP 403.
 */
public class RoleMismatchException extends RuntimeException {
    public RoleMismatchException(String message) {
        super(message);
    }
}
