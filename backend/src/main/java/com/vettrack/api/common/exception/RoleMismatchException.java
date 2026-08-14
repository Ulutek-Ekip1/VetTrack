package com.vettrack.api.common.exception;

/**
 * Thrown when a Supabase-authenticated user's role in JWT metadata does not match the
 * profile endpoint being accessed (e.g. a vet_staff hits /owners/me, or vice versa).
 * <p>
 * ErrorCode.ROLE_MISMATCH ile HTTP 403 döner.
 */
public class RoleMismatchException extends ApiException {
    public RoleMismatchException(String message) {
        super(ErrorCode.ROLE_MISMATCH, message);
    }
}
