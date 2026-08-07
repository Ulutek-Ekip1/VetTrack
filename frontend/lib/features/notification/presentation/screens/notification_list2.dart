import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vettrack_frontend/core/utils/formatters.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_state.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../widgets/notification_card.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF004AC6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined,
                color: Color(0xFF434655)),
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
            return Center(child: Text(state.message));
          } else if (state is NotificationLoaded) {
            final notifications = state.notificationList.notifications;

            if (notifications.isEmpty) {
              return const Center(child: Text('Henüz bildiriminiz yok'));
            }

            return ListView.builder(
              itemCount: notifications.length,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              itemBuilder: (context, index) {
                final currentNotification = notifications[index];
                String date = "Bilinmiyor";
                if (currentNotification.sentAt != null) {
                  date = Formatters.formatDate(currentNotification.sentAt!);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 4.0, bottom: 8.0, top: 12.0),
                      child: Text(
                        date,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF131B2E),
                        ),
                      ),
                    ),
                    NotificationCard(
                      notification: currentNotification,
                    ),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
