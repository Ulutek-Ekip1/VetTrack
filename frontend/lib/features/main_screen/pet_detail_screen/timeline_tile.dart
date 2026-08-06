import 'package:flutter/material.dart';

class TimelineTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Widget icon;
  final String title;
  final Widget? titleTrailing;
  final String date;
  final Widget? dateWidget;
  final String description;

  const TimelineTile({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    required this.icon,
    required this.title,
    this.titleTrailing,
    this.date = '',
    this.dateWidget,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line and Icon
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: isFirst ? 16 : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? 16 : null,
                  width: 2,
                  child: Container(color: colorScheme.outlineVariant),
                ),
                Positioned(
                  top: 0,
                  child: icon,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (titleTrailing != null) ...[
                          const SizedBox(width: 8),
                          titleTrailing!,
                        ],
                        const Spacer(),
                        dateWidget ??
                            Text(
                              date,
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.outline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
