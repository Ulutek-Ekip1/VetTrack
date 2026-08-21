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
    final primaryBlue = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final bool isRead = notification.isRead;

    final treatmentColor = isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48);

    final (iconData, iconColor, iconBgColor) = switch (notification.type) {
      "SYSTEM" => (
          Icons.info_outline_rounded,
          theme.colorScheme.primary,
          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        ),
      "VACCINE" => (
          Icons.vaccines_rounded,
          theme.colorScheme.secondary,
          theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
        ),
      "TREATMENT" => (
          Icons.healing_rounded,
          treatmentColor,
          treatmentColor.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
      "RECOMMENDATION" => (
          Icons.tips_and_updates_rounded,
          theme.colorScheme.tertiary,
          theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        ),
      "VISIT" => (
          Icons.calendar_month_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withValues(alpha: 0.15),
        ),
      _ => (
          Icons.notifications_none_outlined,
          primaryBlue,
          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        ),
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingSm,
      ),
      color: isRead
          ? theme.colorScheme.surfaceContainerLowest
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        side: BorderSide(
          color: isRead
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
              : primaryBlue.withValues(alpha: 0.3),
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
                              color: theme.colorScheme.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
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
                        color: theme.colorScheme.onSurfaceVariant,
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
                          color: theme.colorScheme.outline,
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
    );
  }
}
