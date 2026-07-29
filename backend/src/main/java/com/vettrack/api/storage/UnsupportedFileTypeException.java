package com.vettrack.api.storage;

public class UnsupportedFileTypeException extends StorageException {
    public UnsupportedFileTypeException(String message) {
        super(message);
    }
}
