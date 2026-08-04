import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_with_email_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/pet/presentation/cubit/pet_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
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
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.createRouter(sl<AuthCubit>()),
      ),
    ),
  );
}
