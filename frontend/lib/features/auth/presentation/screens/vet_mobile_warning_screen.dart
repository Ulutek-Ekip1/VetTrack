import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/constants/app_constants.dart';

class VetMobileWarningScreen extends StatelessWidget {
  const VetMobileWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLg,
                vertical: AppDimensions.spacingMd,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppDimensions.spacingMd * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerLowest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingLg,
                          vertical: AppDimensions.spacingXl,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                size: 36,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Veteriner Girişi Engellendi',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'VetTrack mobil uygulaması yalnızca Hayvan Sahipleri içindir.\n\nHekim yönetim paneline erişmek için lütfen bilgisayarınızdan web panelini kullanınız.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Web Yönlendirme Butonu
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton.icon(
                                onPressed: () async {
                                  final Uri url = Uri.parse(AppConstants.vetWebPanelUrl);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.language_rounded, size: 20),
                                label: const Text(
                                  'Web Paneline Git',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Çıkış Yap Butonu
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await context.read<AuthCubit>().signOut();
                                  if (context.mounted) { 
                                    context.go('/welcome');
                                  }
                                },
                                icon: const Icon(Icons.logout_rounded, size: 18),
                                label: const Text('Çıkış Yap'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.spacingMd,
                                    vertical: AppDimensions.spacingSm,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
