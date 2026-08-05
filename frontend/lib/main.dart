import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wcgbpxtshkyphcdgyxgy.supabase.co/',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndjZ2JweHRzaGt5cGhjZGd5eGd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUxMTQxNzIsImV4cCI6MjEwMDY5MDE3Mn0.fmC-ro_kWURXioPYSZyZk6bwBfgrrbr3346lveuV-jw',
  );

  await di.init();
  runApp(const VetTrackApp());
}
