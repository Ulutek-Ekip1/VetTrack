import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vettrack_frontend/core/router/app_router.dart';
import 'package:vettrack_frontend/core/constants/app_dimensions.dart';

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabı Sil'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingLg,
            AppDimensions.spacingMd,
            AppDimensions.spacingLg,
            AppDimensions.spacingLg,
          ),
          child: Column(
            children: [
              // DELETE ICON
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.errorContainer,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.error.withValues(alpha: 0.12),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 78,
                      color: colorScheme.error,
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: colorScheme.onError,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // TITLE
              Text(
                'Hesabınızı silmek istediğinize',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              Text(
                'emin misiniz?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // DESCRIPTION
              Text(
                'Bu işlem geri alınamaz. Hesabınız ve ilişkili '
                'tüm verileriniz kalıcı olarak silinecektir.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // DATA CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.error,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Silinecek veriler',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildDataItem(
                      context,
                      icon: Icons.pets_rounded,
                      title: 'Tüm evcil hayvanlarınız',
                      subtitle: 'Kayıtlı tüm evcil hayvanlarınız silinecek.',
                    ),
                    _buildDivider(context),
                    _buildDataItem(
                      context,
                      icon: Icons.vaccines_rounded,
                      title: 'Aşı ve ziyaret kayıtlarınız',
                      subtitle:
                          'Tüm aşı ve veteriner ziyaret kayıtlarınız silinecek.',
                    ),
                    _buildDivider(context),
                    _buildDataItem(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Bildirimleriniz',
                      subtitle: 'Tüm bildirim geçmişiniz silinecek.',
                    ),
                    _buildDivider(context),
                    _buildDataItem(
                      context,
                      icon: Icons.storage_rounded,
                      title: 'Diğer tüm verileriniz',
                      subtitle:
                          'Hesabınıza ait diğer tüm veriler kalıcı olarak silinecek.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // SECURITY INFO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Verileriniz güvenli bir şekilde silinecek '
                        've hiçbir şekilde geri getirilemeyecektir.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              // DELETE BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.deleteAccountVerify);
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 25,
                  ),
                  label: const Text(
                    'Hesabımı Sil',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              // CANCEL BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(
                      color: colorScheme.outline,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'İptal',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: colorScheme.error,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
      ),
    );
  }
}
