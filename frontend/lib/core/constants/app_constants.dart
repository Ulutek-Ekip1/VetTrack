import 'package:flutter/foundation.dart';

// API URL'leri, Supabase/FCM anahtarları, sabitler
class AppConstants {
  static const String appName = "VetTrack";

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static String get apiBaseUrl {
    const url = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://vettrack-staging-a0fb.up.railway.app',
    );
    return kIsWeb ? url.replaceAll('10.0.2.2', 'localhost') : url;
  }

  static const String googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static const String vetWebPanelUrl = String.fromEnvironment(
    'VET_WEB_PANEL_URL',
    defaultValue: 'https://vettrack-ce0ad.web.app/welcome',
  );
}
