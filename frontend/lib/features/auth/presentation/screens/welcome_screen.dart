import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfaceContainerLow,
              AppColors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (Yuvarlatılmış Mavi Kutu İle İkon)
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SvgPicture.asset(
                      "assets/icons/paw.svg",
                      width: 56,
                      height: 56,
                      colorFilter: const ColorFilter.mode(
                        AppColors.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // VetTrack Başlık
                  Text(
                    "VetTrack",
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Alt Açıklama
                  Text(
                    "Evcil hayvanınızın sağlık, bakım ve muayene süreçlerini tek bir yerden kolayca takip edin.",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Giriş Yap Butonu (Turkuaz - #14B8A6)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Giriş Yap',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.login_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Kayıt Ol Butonu (Şeftali - #FFB89C)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.register);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB89C),
                        foregroundColor: const Color(0xFF131B2E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kayıt Ol',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF131B2E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.person_add_rounded,
                            size: 20,
                            color: Color(0xFF131B2E),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Footer
                  Text(
                    "© 2026 VetTrack Health Systems. All rights reserved.",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.outline,
                    ),
                    textAlign: TextAlign.center,
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
