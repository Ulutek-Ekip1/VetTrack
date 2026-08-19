package com.vettrack.api.ai.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDto {
    private String role;
    private String content;

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getContent() {
        return content;
    }

    public static ChatMessageDtoBuilder builder() {
        return new ChatMessageDtoBuilder();
    }

    public static class ChatMessageDtoBuilder {
        private String role;
        private String content;

        public ChatMessageDtoBuilder role(String role) { this.role = role; return this; }
        public ChatMessageDtoBuilder content(String content) { this.content = content; return this; }

        public ChatMessageDto build() {
            ChatMessageDto c = new ChatMessageDto();
            c.role = this.role;
            c.content = this.content;
            return c;
        }
    }
}
