package com.vettrack.api.treatment;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AttachmentUrlResponse {
    private String url;

    public static AttachmentUrlResponseBuilder builder() {
        return new AttachmentUrlResponseBuilder();
    }

    public static class AttachmentUrlResponseBuilder {
        private String url;

        public AttachmentUrlResponseBuilder url(String url) { this.url = url; return this; }

        public AttachmentUrlResponse build() {
            AttachmentUrlResponse r = new AttachmentUrlResponse();
            r.url = this.url;
            return r;
        }
    }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
}
