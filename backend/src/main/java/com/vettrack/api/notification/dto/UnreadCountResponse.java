package com.vettrack.api.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UnreadCountResponse {

    private long unreadCount;

    public static UnreadCountResponseBuilder builder() {
        return new UnreadCountResponseBuilder();
    }

    public static class UnreadCountResponseBuilder {
        private long unreadCount;

        public UnreadCountResponseBuilder unreadCount(long unreadCount) {
            this.unreadCount = unreadCount;
            return this;
        }

        public UnreadCountResponse build() {
            UnreadCountResponse r = new UnreadCountResponse();
            r.unreadCount = this.unreadCount;
            return r;
        }
    }

    public long getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(long unreadCount) {
        this.unreadCount = unreadCount;
    }
}
