import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Kendi gerçek Supabase URL ve Anon Key'inizi buraya girin.
  // Şimdilik çökmemesi için mock (sahte) verilerle başlatıyoruz.
  await Supabase.initialize(
    url: 'https://mock-supabase-url.supabase.co',
    publishableKey: 'mock-anon-key-1234567890',
  );

  await di.init();
  runApp(const VetTrackApp());
}
