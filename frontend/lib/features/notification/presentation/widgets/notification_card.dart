import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/features/notification/domain/entities/notification_entity.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../cubit/notification_cubit.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF004AC6);

    final bool isRead = notification.isRead;

    final (iconData, iconColor, iconBgColor) = switch (notification.type) {
      "SYSTEM" => (
          Icons.info_outline_rounded,
          const Color(0xFF2689E8),
          const Color(0xFFF1F7FE),
        ),
      "VACCINE" => (
          Icons.vaccines_rounded,
          const Color(0xFF28B3B0),
          const Color(0xFFF0FAFB),
        ),
      "TREATMENT" => (
          Icons.healing_rounded,
          const Color(0xFF69B451),
          const Color(0xFFF6FAF3),
        ),
      "RECOMMENDATION" => (
          Icons.tips_and_updates_rounded,
          const Color(0xFFA06AEF),
          const Color(0xFFF6F0FE),
        ),
      "VISIT" => (
          Icons.calendar_month_rounded,
          const Color(0xFFF0A43C),
          const Color(0xFFFFF8EE),
        ),
      _ => (
          Icons.notifications_none_outlined,
          primaryBlue,
          const Color(0xFFEFF6FF),
        ),
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingSm,
      ),
      color: isRead ? theme.colorScheme.surface : const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        side: BorderSide(
          color: isRead
              ? Colors.grey.shade200
              : primaryBlue.withValues(alpha: 0.15),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        onTap: () {
          context.read<NotificationCubit>().markAsRead(notification.id);
          if (notification.petId != null) {
            context.push('/owner/pets/${notification.petId}/treatments');
          }
        },
        child: Semantics(
          button: true,
          label: '${notification.title}. ${notification.body}.${isRead ? ' Okundu.' : ' Okunmadı.'}',
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isRead ? FontWeight.bold : FontWeight.w900,
                              color: isRead
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF131B2E),
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isRead
                            ? Colors.grey.shade600
                            : const Color(0xFF1E293B),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    if (notification.sentAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${notification.sentAt!.hour.toString().padLeft(2, '0')}:'
                        '${notification.sentAt!.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
