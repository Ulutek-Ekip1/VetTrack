package com.vettrack.api.storage;

public class FileTooLargeException extends StorageException {
    public FileTooLargeException(String message) {
        super(message);
    }
}
