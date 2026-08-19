import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/firebase_messaging_service.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onDismissed;

  const NotificationPermissionDialog({
    super.key,
    this.onSettingsPressed,
    this.onDismissed,
  });

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const NotificationPermissionDialog(),
    );
  }

  Future<void> _handleGoToSettings(BuildContext context) async {
    Navigator.of(context).pop();
    if (onSettingsPressed != null) {
      onSettingsPressed!();
    } else {
      await sl<FirebaseMessagingService>().openNotificationSettings();
    }
  }

  void _handleDismiss(BuildContext context) {
    Navigator.of(context).pop();
    onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İkon Rozeti
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Başlık
                Text(
                  'Bildirimleri Açın',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Açıklama
                Text(
                  'Evcil hayvanınızın muayene durumları, tedavi ve aşı hatırlatmaları için bildirim iznini cihaz ayarlarından etkinleştirin.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Özellik Maddeleri
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        context,
                        icon: Icons.access_time_filled_rounded,
                        text: 'Zamanlanmış tedavi ve aşı hatırlatmaları',
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        context,
                        icon: Icons.assignment_turned_in_rounded,
                        text: 'Muayene sonucu ve hekim önerisi güncellemeleri',
                      ),
                      const SizedBox(height: 8),
                      _buildFeatureItem(
                        context,
                        icon: Icons.shield_rounded,
                        text: 'Acil durum ve klinik bilgilendirmeleri',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Aksiyon Butonları
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => _handleGoToSettings(context),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    label: const Text(
                      'Ayarlara Git',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _handleDismiss(context),
                    child: Text(
                      'Daha Sonra',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sağ Üst Kapatma (Çarpı) Butonu
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              tooltip: 'Kapat',
              onPressed: () => _handleDismiss(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
