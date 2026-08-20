import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vettrack_frontend/core/services/firebase_messaging_service.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/constants/app_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final messagingService = FirebaseMessagingService();
    await messagingService.initNotifications();
  } catch (e) {
    debugPrint('Firebase başlatılamadı: $e');
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
  );

  await di.init();

  runApp(const VetTrackApp());
}
