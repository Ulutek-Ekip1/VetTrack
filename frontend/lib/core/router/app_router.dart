import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/owner_profile_screen.dart';
import '../../features/auth/presentation/screens/edit_profile_screen.dart';
import '../../features/auth/presentation/screens/vet_profile_screen.dart';
import '../../features/auth/presentation/cubit/profile_cubit.dart';
import '../di/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/pet/presentation/screens/pet_detail_screen2.dart';
import '../../features/pet/presentation/screens/pet_list_screen.dart';
import '../../features/pet/presentation/screens/add_pet_screen.dart';
import '../../features/pet/presentation/screens/edit_pet_screen.dart';
import '../../features/visit/presentation/screens/doctor_search_screen.dart';
import '../../features/visit/presentation/screens/active_visit_screen.dart';
import '../../features/visit/presentation/screens/pet_visit_history_screen.dart';
import '../../features/visit/presentation/screens/vet_visit_history_screen.dart';
import '../../features/treatment/presentation/screens/add_treatment_screen.dart';
import '../../features/treatment/presentation/screens/pet_treatment_history_screen.dart';
import '../../features/recommendation/presentation/screens/pet_recommendation_screen.dart';
import '../../features/recommendation/presentation/screens/add_recommendation_screen.dart';
import '../../features/notification/presentation/screens/notification_list_screen.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/ai_chatbot_screen.dart';
import '../../features/visit/presentation/screens/owner_visit_history_list_screen.dart';
import 'main_shell_screen.dart';
import 'not_found_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

abstract class AppRoutes {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String ownerEmailVerification = '/owner/email-verification';
  static const String resetPassword = '/reset-password';

  //Pet Modülü Rotaları
  static const String ownerHome = '/owner/home';
  static const String ownerPets = '/owner/pets';
  static const String addPet = '/owner/pets/add';
  static const String petDetail = '/owner/pets/:petId';
  static const String editPet = '/owner/pets/:petId/edit';
  static const String ownerProfile = '/owner/profile';
  static const String editProfile = '/owner/profile/edit';
  static const String ownerVisitHistoryList = '/owner/visits';

  //Visit (Ziyaret / Muayene) Modülü Rotaları
  static const String vetSearch = '/vet/search';
  static const String activeVisit = '/vet/visit/active/:visitId';
  static const String petVisitHistory = '/owner/pets/:petId/visits';
  static const String vetProfile = '/vet/profile';
  static const String vetVisitHistory = '/vet/history';

  //Treatment & Recommendation Rotaları
  static const String addTreatment = '/vet/visit/:visitId/treatment/add';
  static const String addRecommendation =
      '/vet/visit/:visitId/recommendation/add';
  static const String petTreatments = '/owner/pets/:petId/treatments';

  //Recommendation Modülü Rotaları
  static const String petRecommendations = '/owner/pets/:petId/recommendations';

  //Notification Modülü Rotaları
  static const String notifications = '/notifications';

  // AI Chatbot Rotası
  static const String chatbot = '/chatbot';
}

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static GoRouter? _router;

  static GoRouter get router {
    _router ??= createRouter();
    return _router!;
  }

  static GoRouter createRouter([AuthCubit? authCubit]) {
    final routerInstance = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.welcome,
      refreshListenable:
          authCubit != null ? GoRouterRefreshStream(authCubit.stream) : null,

      //404 / Sayfa Bulunamadı Katmanı
      errorBuilder: (context, state) => const NotFoundScreen(),

      //Auth & Rol Bazlı Redirect
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit?.state;
        final isLoggedIn = authState is Authenticated;
        final location = state.matchedLocation;

        final isLoggingIn = location == AppRoutes.welcome ||
            location == AppRoutes.login ||
            location == AppRoutes.register ||
            location == AppRoutes.forgotPassword ||
            location == AppRoutes.ownerEmailVerification ||
            location == AppRoutes.resetPassword;

        if (!isLoggedIn) {
          return isLoggingIn ? null : AppRoutes.welcome;
        }

        final user = authState.user;

        if (isLoggingIn) {
          return user.role == UserRole.owner
              ? AppRoutes.ownerHome
              : AppRoutes.vetSearch;
        }

        if (user.role == UserRole.owner && location.startsWith('/vet')) {
          return AppRoutes.ownerHome;
        }

        if (user.role == UserRole.vet && location.startsWith('/owner')) {
          return AppRoutes.vetSearch;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: 'forgotPassword',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.ownerEmailVerification,
          name: 'ownerEmailVerification',
          builder: (context, state) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          name: 'resetPassword',
          builder: (context, state) => const ResetPasswordScreen(),
        ),

        //Hayvan Sahibi StatefulShellRoute
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return OwnerShellScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.ownerHome,
                  name: 'ownerHome',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.ownerPets,
                  name: 'ownerPets',
                  builder: (context, state) => const PetListScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      name: 'addPet',
                      builder: (context, state) => const AddPetScreen(),
                    ),
                    GoRoute(
                      path: ':petId',
                      name: 'petDetail',
                      builder: (context, state) {
                        final petId = state.pathParameters['petId'] ?? '';
                        return PetDetailScreen2(petId: petId);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          name: 'editPet',
                          builder: (context, state) {
                            final petId = state.pathParameters['petId'] ?? '';
                            return EditPetScreen(petId: petId);
                          },
                        ),
                        GoRoute(
                          path: 'visits',
                          name: 'petVisitHistory',
                          builder: (context, state) {
                            final petId = state.pathParameters['petId'] ?? '';
                            return PetVisitHistoryScreen(petId: petId);
                          },
                        ),
                        GoRoute(
                          path: 'treatments',
                          name: 'petTreatments',
                          builder: (context, state) {
                            final petId = state.pathParameters['petId'] ?? '';
                            return PetTreatmentHistoryScreen(petId: petId);
                          },
                        ),
                        GoRoute(
                          path: 'recommendations',
                          name: 'petRecommendations',
                          builder: (context, state) {
                            final petId = state.pathParameters['petId'] ?? '';
                            return PetRecommendationScreen(petId: petId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.ownerProfile,
                  name: 'ownerProfile',
                  builder: (context, state) => const OwnerProfileScreen(),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      name: 'editProfile',
                      builder: (context, state) => BlocProvider<ProfileCubit>(
                        create: (context) => sl<ProfileCubit>(),
                        child: const EditProfileScreen(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        //Veteriner Personeli StatefulShellRoute
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return VetShellScreen(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.vetSearch,
                  name: 'vetSearch',
                  builder: (context, state) => const DoctorSearchScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.vetVisitHistory,
                  name: 'vetVisitHistory',
                  builder: (context, state) => const VetVisitHistoryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.vetProfile,
                  name: 'vetProfile',
                  builder: (context, state) => const VetProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        //Ziyaret Detayı & Tedavi/Öneri Ekleme Rotaları
        GoRoute(
          path: AppRoutes.activeVisit,
          name: 'activeVisit',
          builder: (context, state) {
            final visitId = state.pathParameters['visitId'] ?? '';
            return ActiveVisitScreen(visitId: visitId);
          },
        ),
        //Tedavi Girişi Rotası: /vet/visit/:visitId/treatment/add
        GoRoute(
          path: AppRoutes.addTreatment,
          name: 'addTreatment',
          builder: (context, state) {
            final visitId = state.pathParameters['visitId'] ?? '';
            return AddTreatmentScreen(visitId: visitId);
          },
        ),
        //Öneri Girişi Rotası: /vet/visit/:visitId/recommendation/add
        GoRoute(
          path: AppRoutes.addRecommendation,
          name: 'addRecommendation',
          builder: (context, state) {
            final visitId = state.pathParameters['visitId'] ?? '';
            return AddRecommendationScreen(visitId: visitId);
          },
        ),
        GoRoute(
          path: AppRoutes.notifications,
          name: 'notifications',
          builder: (context, state) => const NotificationListScreen(),
        ),
        GoRoute(
          path: AppRoutes.ownerVisitHistoryList,
          name: 'ownerVisits',
          builder: (context, state) => const OwnerVisitHistoryListScreen(),
        ),
        GoRoute(
          path: AppRoutes.chatbot,
          name: 'chatbot',
          builder: (context, state) => const AIChatbotScreen(),
        ),
      ],
    );

    _router = routerInstance;
    _setupSupabaseAuthListener();
    return routerInstance;
  }

  static void _setupSupabaseAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        _router?.go(AppRoutes.resetPassword);
      }
    });
  }
}
