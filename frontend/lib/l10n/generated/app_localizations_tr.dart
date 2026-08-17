// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'VetTrack';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get offline => 'Çevrimdışısınız';

  @override
  String get offlineMode => 'Çevrimdışı moddasınız';

  @override
  String get connectionErrorTitle => 'Bağlantı Hatası';

  @override
  String get retryConnection => 'Bağlantıyı tekrar dene';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsLoading => 'Bildirimler yükleniyor';

  @override
  String get noNotifications => 'Henüz bildiriminiz yok';

  @override
  String get markAllNotificationsRead => 'Tümünü Okundu Yap';
}
