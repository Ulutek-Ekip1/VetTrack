import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

/// Sunucudan/API'den dönecek model yapısı
class AppVersionConfig {
  final String latestVersion; // Örn: "2.4.0"
  final String minRequiredVersion; // Örn: "2.0.0"
  final String updateTitle;
  final String updateMessage;
  final String packageSize; // Örn: "12 MB"

  AppVersionConfig({
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.updateTitle,
    required this.updateMessage,
    this.packageSize = "12 MB",
  });
}

class UpdateManager {
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.vettrack.app';
  static const String _appStoreUrl = 'https://apps.apple.com/app/id1234567890';

  static bool _hasChecked = false;

  /// Ana Kontrol Metodu
  static Future<void> checkVersion(BuildContext context) async {
    if (_hasChecked) return;
    _hasChecked = true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version; // Örn: "1.0.0"

      debugPrint("[UpdateManager] Cihazdaki Sürüm: '$currentVersion'");

      // Mock/Simüle Edilmiş API Yanıtı
      final serverConfig = AppVersionConfig(
        latestVersion: "2.4.0",
        minRequiredVersion: "2.0.0",
        updateTitle: "Yeni Sürüm Mevcut",
        updateMessage:
            "VetTrack'i kullanmaya devam etmek için en son özellikler ve güvenlik iyileştirmelerini içeren yeni sürümü yüklemeniz gerekmektedir.",
        packageSize: "12 MB",
      );

      debugPrint(
          "[UpdateManager] Sunucu En Düşük Sürüm Sınırı: '${serverConfig.minRequiredVersion}'");
      debugPrint(
          "[UpdateManager] Sunucu En Son Sürüm: '${serverConfig.latestVersion}'");

      // 1. ZORUNLU GÜNCELLEME KONTROLÜ
      if (_isVersionLower(currentVersion, serverConfig.minRequiredVersion)) {
        debugPrint("[UpdateManager] Durum: Zorunlu güncelleme gerekiyor!");
        if (context.mounted) {
          _showUpdateDialog(
            context: context,
            config: serverConfig,
            isForceUpdate: true,
            currentVersion: currentVersion,
          );
        }
        return;
      }

      // 2. İSTEĞE BAĞLI GÜNCELLEME KONTROLÜ
      if (_isVersionLower(currentVersion, serverConfig.latestVersion)) {
        debugPrint("[UpdateManager] Durum: İsteğe bağlı güncelleme var.");
        if (context.mounted) {
          _showUpdateDialog(
            context: context,
            config: serverConfig,
            isForceUpdate: false,
            currentVersion: currentVersion,
          );
        }
        return;
      }

      debugPrint("[UpdateManager] Durum: Uygulama güncel.");
    } catch (e) {
      debugPrint("Sürüm kontrol hatası: $e");
    }
  }

  /// Sürüm Karşılaştırma Mantığı (Semantic Versioning: "1.0.0" < "1.1.0")
  static bool _isVersionLower(String current, String target) {
    try {
      final currentClean = current.isEmpty
          ? "0.0.0"
          : current.split('+').first.split('-').first.trim();
      final targetClean = target.isEmpty
          ? "0.0.0"
          : target.split('+').first.split('-').first.trim();

      List<int> currentParts = currentClean
          .split('.')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();
      List<int> targetParts = targetClean
          .split('.')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();

      for (int i = 0; i < targetParts.length; i++) {
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        if (currentPart < targetParts[i]) return true;
        if (currentPart > targetParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Güncelleme Ekrani (Dialog)
  static void _showUpdateDialog({
    required BuildContext context,
    required AppVersionConfig config,
    required bool isForceUpdate,
    required String currentVersion,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
          !isForceUpdate, // Zorunluysa dışarı tıklayarak kapanamaz
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return PopScope(
          canPop: !isForceUpdate, // Zorunluysa geri tuşuyla kapatılamaz
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(28.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Telefon ve Güncelleme İkonu (Light Blue Yuvarlak Container içinde)
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      size: 38,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Başlık
                  Text(
                    config.updateTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mesaj
                  Text(
                    config.updateMessage,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Güncelle Butonu (Mavi ve İkonlu)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _openStore,
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: Text(
                        "Güncelle",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Eğer isteğe bağlı güncelleme ise "Daha Sonra" butonu
                  if (!isForceUpdate) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.pop(),
                      child: Text(
                        "Daha Sonra",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Sürüm ve Boyut Bilgisi
                  Text(
                    "Mevcut Sürüm: $currentVersion  •  Yeni Sürüm: ${config.latestVersion}  •  ${config.packageSize}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.outlineVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Mağazaya Yönlendirme Metodu
  static Future<void> _openStore() async {
    final Uri url = Uri.parse(
      (!kIsWeb && Platform.isIOS) ? _appStoreUrl : _playStoreUrl,
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Mağaza bağlantısı açılamadı.");
      }
    } catch (e) {
      debugPrint("Mağazaya yönlendirme hatası: $e");
    }
  }
}
