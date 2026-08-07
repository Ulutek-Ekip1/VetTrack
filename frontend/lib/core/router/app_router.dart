import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/owner_profile_screen.dart';
import '../../features/auth/presentation/screens/vet_profile_screen.dart';
import '../../features/pet/presentation/screens/pet_list_screen.dart';
import '../../features/pet/presentation/screens/pet_detail_screen.dart';
import '../../features/pet/presentation/screens/add_pet_screen.dart';
import '../../features/pet/presentation/screens/edit_pet_screen.dart';
import '../../features/visit/presentation/screens/doctor_search_screen.dart';
import '../../features/visit/presentation/screens/active_visit_screen.dart';
import '../../features/visit/presentation/screens/pet_visit_history_screen.dart';
import '../../features/visit/presentation/screens/owner_visit_history_list_screen.dart';
import '../../features/visit/presentation/screens/vet_visit_history_screen.dart';
import '../../features/treatment/presentation/screens/add_treatment_screen.dart';
import '../../features/treatment/presentation/screens/pet_treatment_history_screen.dart';
import '../../features/recommendation/presentation/screens/pet_recommendation_screen.dart';
import '../../features/recommendation/presentation/screens/add_recommendation_screen.dart';
import '../../features/notification/presentation/screens/notification_list_screen.dart';
import 'main_shell_screen.dart';
import 'not_found_screen.dart';

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
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  //Pet Modülü Rotaları
  static const String ownerPets = '/owner/pets';
  static const String addPet = '/owner/pets/add';
  static const String petDetail = '/owner/pets/:petId';
  static const String editPet = '/owner/pets/:petId/edit';
  static const String ownerProfile = '/owner/profile';
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
}

class AppRouter {
  static GoRouter createRouter([AuthCubit? authCubit]) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.login,
      refreshListenable:
          authCubit != null ? GoRouterRefreshStream(authCubit.stream) : null,

      //404 / Sayfa Bulunamadı Katmanı
      errorBuilder: (context, state) => const NotFoundScreen(),

      //Auth & Rol Bazlı Redirect
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit?.state;
        final isLoggedIn = authState is Authenticated;
        final location = state.matchedLocation;

        final isLoggingIn = location == AppRoutes.login ||
            location == AppRoutes.register ||
            location == AppRoutes.forgotPassword;

        if (!isLoggedIn) {
          return isLoggingIn ? null : AppRoutes.login;
        }

        final user = authState.user;

        if (isLoggingIn) {
          return user.role == UserRole.owner
              ? AppRoutes.ownerPets
              : AppRoutes.vetSearch;
        }

        if (user.role == UserRole.owner && location.startsWith('/vet')) {
          return AppRoutes.ownerPets;
        }

        if (user.role == UserRole.vet && location.startsWith('/owner')) {
          return AppRoutes.vetSearch;
        }

        return null;
      },
      routes: [
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

        //Hayvan Sahibi StatefulShellRoute
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return OwnerShellScreen(navigationShell: navigationShell);
          },
          branches: [
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
                        return PetDetailScreen(petId: petId);
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
                  path: AppRoutes.ownerVisitHistoryList,
                  name: 'ownerVisitHistoryList',
                  builder: (context, state) =>
                      const OwnerVisitHistoryListScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.ownerProfile,
                  name: 'ownerProfile',
                  builder: (context, state) => const OwnerProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        //Veteriner Hekim StatefulShellRoute
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
                  path: '/vet/notifications',
                  name: 'vetNotifications',
                  builder: (context, state) => const NotificationListScreen(),
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

        //Muayene Yaşam Döngüsü & Hiyerarşik Muayene Akışı (Nested Visit Routes)
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
      ],
    );
  }
}
