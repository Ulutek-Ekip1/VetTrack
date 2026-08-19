import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_state.dart';

import '../../../../core/constants/app_dimensions.dart';
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        title: Text(
          'Bildirimler',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.mark_chat_read_outlined,
                color: theme.colorScheme.onSurface),
            tooltip: 'Tümünü Okundu Yap',
            onPressed: context.read<NotificationCubit>().markAllAsRead,
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: context.read<NotificationCubit>().loadNotifications,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Yeniden Dene'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is NotificationLoaded) {
            final notifications = List.of(state.notificationList.notifications);

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined,
                        size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz bildiriminiz yok',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
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
                            color: theme.colorScheme.onSurface,
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
