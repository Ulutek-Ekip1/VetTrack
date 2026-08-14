import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// Ortak asenkron ekran durumları. Mevcut pet listesi ve bildirim ekranının
/// renk, ikon ve buton dilini korur.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label ?? 'Yükleniyor',
        liveRegion: true,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class AppEmptyStateView extends StatelessWidget {
  const AppEmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Text(description!, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorStateView extends StatelessWidget {
  const AppErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.isOffline = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isOffline)
          Container(
            color: AppColors.warning,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Çevrimdışı moddasınız',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: AppColors.outline,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  const Text(
                    'Bağlantı Hatası',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
