import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationBadgeButton extends StatelessWidget {
  const NotificationBadgeButton({
    super.key,
    this.iconColor = const Color(0xFF434655),
    this.backgroundColor,
    this.iconSize = 24,
  });

  final Color iconColor;
  final Color? backgroundColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unread = state is NotificationLoaded
            ? state.notificationList.unreadCount
            : 0;
        final button = IconButton(
          icon: Icon(Icons.notifications_outlined, color: iconColor, size: iconSize),
          tooltip: 'Bildirimler',
          onPressed: () => context.push('/notifications'),
        );

        return Badge(
          isLabelVisible: unread > 0,
          label: Text('$unread'),
          child: backgroundColor == null
              ? button
              : Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: button,
                ),
        );
      },
    );
  }
}
