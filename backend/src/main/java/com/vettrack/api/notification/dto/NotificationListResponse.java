package com.vettrack.api.notification.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NotificationListResponse {

    private List<NotificationResponse> notifications;
    private long unreadCount;

    public static NotificationListResponseBuilder builder() {
        return new NotificationListResponseBuilder();
    }

    public static class NotificationListResponseBuilder {
        private List<NotificationResponse> notifications;
        private long unreadCount;

        public NotificationListResponseBuilder notifications(List<NotificationResponse> notifications) {
            this.notifications = notifications;
            return this;
        }

        public NotificationListResponseBuilder unreadCount(long unreadCount) {
            this.unreadCount = unreadCount;
            return this;
        }

        public NotificationListResponse build() {
            NotificationListResponse r = new NotificationListResponse();
            r.notifications = this.notifications;
            r.unreadCount = this.unreadCount;
            return r;
        }
    }

    public List<NotificationResponse> getNotifications() {
        return notifications;
    }

    public void setNotifications(List<NotificationResponse> notifications) {
        this.notifications = notifications;
    }

    public long getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(long unreadCount) {
        this.unreadCount = unreadCount;
    }
}
