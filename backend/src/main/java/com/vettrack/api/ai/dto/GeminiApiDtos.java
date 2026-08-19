package com.vettrack.api.ai.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

public class GeminiApiDtos {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class Request {
        private List<Content> contents;

        @JsonProperty("systemInstruction")
        private Content systemInstruction;

        public static RequestBuilder builder() {
            return new RequestBuilder();
        }

        public static class RequestBuilder {
            private List<Content> contents;
            private Content systemInstruction;

            public RequestBuilder contents(List<Content> contents) {
                this.contents = contents;
                return this;
            }

            public RequestBuilder systemInstruction(Content systemInstruction) {
                this.systemInstruction = systemInstruction;
                return this;
            }

            public Request build() {
                Request r = new Request();
                r.contents = this.contents;
                r.systemInstruction = this.systemInstruction;
                return r;
            }
        }

        public List<Content> getContents() {
            return contents;
        }

        public void setContents(List<Content> contents) {
            this.contents = contents;
        }

        public Content getSystemInstruction() {
            return systemInstruction;
        }

        public void setSystemInstruction(Content systemInstruction) {
            this.systemInstruction = systemInstruction;
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class Content {
        private String role;
        private List<Part> parts;

        public static ContentBuilder builder() {
            return new ContentBuilder();
        }

        public static class ContentBuilder {
            private String role;
            private List<Part> parts;

            public ContentBuilder role(String role) {
                this.role = role;
                return this;
            }

            public ContentBuilder parts(List<Part> parts) {
                this.parts = parts;
                return this;
            }

            public Content build() {
                Content c = new Content();
                c.role = this.role;
                c.parts = this.parts;
                return c;
            }
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }

        public List<Part> getParts() {
            return parts;
        }

        public void setParts(List<Part> parts) {
            this.parts = parts;
        }
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Part {
        private String text;

        public static PartBuilder builder() {
            return new PartBuilder();
        }

        public static class PartBuilder {
            private String text;

            public PartBuilder text(String text) {
                this.text = text;
                return this;
            }

            public Part build() {
                Part p = new Part();
                p.text = this.text;
                return p;
            }
        }

        public String getText() {
            return text;
        }

        public void setText(String text) {
            this.text = text;
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Response {
        private List<Candidate> candidates;

        public List<Candidate> getCandidates() {
            return candidates;
        }

        public void setCandidates(List<Candidate> candidates) {
            this.candidates = candidates;
        }
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Candidate {
        private Content content;

        public Content getContent() {
            return content;
        }

        public void setContent(Content content) {
            this.content = content;
        }
    }
}
