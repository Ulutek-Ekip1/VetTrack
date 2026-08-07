// API URL'leri, Supabase/FCM anahtarları, sabitler
class AppConstants {
  static const String appName = "VetTrack";

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
}
