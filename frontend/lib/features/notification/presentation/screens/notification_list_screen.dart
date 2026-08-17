import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import 'package:vettrack_frontend/core/widgets/app_async_state_views.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_state.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/notification_card.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const primaryBlue = Color(0xFF004AC6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined,
                color: Color(0xFF434655)),
            tooltip: l10n.markAllNotificationsRead,
            onPressed: context.read<NotificationCubit>().markAllAsRead,
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return AppLoadingView(label: l10n.notificationsLoading);
          } else if (state is NotificationError) {
            return AppErrorStateView(
              message: state.message,
              onRetry: context.read<NotificationCubit>().loadNotifications,
            );
          } else if (state is NotificationLoaded) {
            final notifications = List.of(state.notificationList.notifications);

            if (notifications.isEmpty) {
              return AppEmptyStateView(
                icon: Icons.notifications_off_outlined,
                title: l10n.noNotifications,
              );
            }

            // En yeniden en eskiye sıralama (Descending)
            notifications.sort((a, b) {
              final aDate = a.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bDate = b.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bDate.compareTo(aDate);
            });

            // Tarihe göre gruplama işlemi
            final groups = <String, List<dynamic>>{};
            for (var item in notifications) {
              String groupName = "Bilinmiyor";
              if (item.sentAt != null) {
                groupName = Formatters.formatDate(item.sentAt!);
              }
              groups.putIfAbsent(groupName, () => []).add(item);
            }

            return RefreshIndicator(
              onRefresh: () => context.read<NotificationCubit>().refresh(),
              child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              children: groups.entries.map((entry) {
                final groupName = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 4.0, bottom: 8.0, top: 12.0),
                      child: Text(
                        groupName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF131B2E),
                        ),
                      ),
                    ),
                    ...items.map((currentNotification) {
                      return NotificationCard(
                        notification: currentNotification,
                      );
                    }),
                  ],
                );
              }).toList(),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
