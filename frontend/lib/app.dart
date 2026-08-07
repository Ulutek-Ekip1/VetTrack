import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/pet/presentation/cubit/pet_cubit.dart';
import 'core/services/top_notification.dart';
import 'core/services/update_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<PetCubit>(create: (context) => sl<PetCubit>()),
      ],
      child: MaterialApp.router(
        title: 'VetTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.createRouter(authCubit),
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              ValueListenableBuilder<TopNotificationData?>(
                valueListenable: topNotificationNotifier,
                builder: (context, data, _) {
                  if (data == null) return const SizedBox.shrink();
                  return Positioned(
                    top: 50.0,
                    left: 16.0,
                    right: 16.0,
                    child: Material(
                      color: Colors.transparent,
                      child: TopNotification(
                        key: UniqueKey(),
                        title: data.title,
                        body: data.body,
                        type: data.type,
                        onTap: data.onTap,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
