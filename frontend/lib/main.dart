import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vettrack_frontend/features/main_screen/neo_screen.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_with_email_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/pet/presentation/cubit/pet_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Kendi gerçek Supabase URL ve Anon Key'inizi buraya girin.
  // Şimdilik çökmemesi için mock (sahte) verilerle başlatıyoruz.
  await Supabase.initialize(
    url: 'https://mock-supabase-url.supabase.co',
    publishableKey: 'mock-anon-key-1234567890',
  );

  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            loginWithEmail: sl<LoginWithEmailUseCase>(),
            registerUseCase: sl<RegisterUseCase>(),
            logoutUseCase: sl<LogoutUseCase>(),
            authRepository: sl<AuthRepository>(),
          ),
        ),
        BlocProvider<PetCubit>(
          create: (context) => sl<PetCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const NeoScreen(),
      ),
    ),
  );
}
