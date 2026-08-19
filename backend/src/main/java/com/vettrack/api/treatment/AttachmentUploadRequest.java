package com.vettrack.api.treatment;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AttachmentUploadRequest {
    @NotBlank(message = "Content type boş olamaz")
    private String contentType;

    @Min(value = 1, message = "Dosya boyutu geçersiz")
    private long fileSize;

    public String getContentType() { return contentType; }
    public void setContentType(String contentType) { this.contentType = contentType; }
    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }
}
