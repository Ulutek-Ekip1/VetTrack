import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'core/services/update_service.dart';

class VetTrackApp extends StatelessWidget {
  const VetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = sl<AuthCubit>()..checkAuthStatus();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navContext = AppRouter.navigatorKey.currentContext;
      if (navContext != null) {
        UpdateManager.checkVersion(navContext);
      }
    });
    
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp.router(
        title: 'VetTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.createRouter(authCubit),
      ),
    );
  }
}
