import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../di/injection_container.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    redirect: (context, state) {
      final authState = sl<AuthCubit>().state;
      
      final bool isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState is AuthInitial || authState is AuthLoading) {
        // Durum kontrol ediliyorken veya yükleniyorken müdahale etme
        return null;
      }

      if (authState is Unauthenticated || authState is AuthError) {
        // Eğer giriş yapmamışsa ve kayıt sayfasına gitmiyorsa Login'e at
        if (!isLoggingIn) return '/login';
      }

      if (authState is Authenticated) {
        // Eğer giriş yapmışsa ve Login/Register sayfalarındaysa Home'a at
        if (isLoggingIn) return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
