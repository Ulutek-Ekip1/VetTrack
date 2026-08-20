import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vettrack_frontend/core/constants/app_constants.dart';
import 'package:vettrack_frontend/core/theme/cubit/theme_cubit.dart';
import '../network/auth_interceptor.dart';
import '../../features/auth/data/datasources/token_local_data_source.dart';

// AI Imports
import 'package:vettrack_frontend/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:vettrack_frontend/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:vettrack_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:vettrack_frontend/features/ai/presentation/cubit/ai_chat_cubit.dart';

// Pet Imports
import 'package:vettrack_frontend/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:vettrack_frontend/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pets_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_photo_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/delete_pet_photo_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_cubit.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_weight_history_usecase.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/weight_history_cubit.dart';

// Visit Imports
import 'package:vettrack_frontend/features/visit/data/datasources/visit_remote_datasource.dart';
import 'package:vettrack_frontend/features/visit/data/repositories/visit_repository_impl.dart';
import 'package:vettrack_frontend/features/visit/domain/repositories/visit_repository.dart';
import 'package:vettrack_frontend/features/visit/domain/usecases/close_visit_usecase.dart';
import 'package:vettrack_frontend/features/visit/domain/usecases/search_by_code_usecase.dart';
import 'package:vettrack_frontend/features/visit/domain/usecases/start_visit_usecase.dart';
import 'package:vettrack_frontend/features/visit/presentation/cubit/visit_cubit.dart';

// Auth Imports
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_with_email_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/signin_with_google_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/domain/usecases/get_owner_profile_usecase.dart';
import '../../features/auth/domain/usecases/update_owner_profile_usecase.dart';
import '../../features/auth/presentation/cubit/profile_cubit.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:vettrack_frontend/features/auth/presentation/cubit/delete_account_cubit.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/update_profile_photo_usecase.dart';
import 'package:vettrack_frontend/features/auth/domain/usecases/delete_profile_photo_usecase.dart';

// Treatment Imports
import 'package:vettrack_frontend/features/treatment/domain/usecases/add_treatment_usecase.dart';
import 'package:vettrack_frontend/features/treatment/domain/usecases/delete_treatment_usecase.dart';
import 'package:vettrack_frontend/features/treatment/domain/usecases/get_treatment_usecase.dart';
import 'package:vettrack_frontend/features/treatment/presentation/cubit/treatment_cubit.dart';
import 'package:vettrack_frontend/features/treatment/data/repositories/treatment_repository_impl.dart';
import 'package:vettrack_frontend/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:vettrack_frontend/features/treatment/domain/repositories/treatment_repository.dart';

// Recommendation Imports
import 'package:vettrack_frontend/features/recommendation/domain/usecases/add_recommendation_usecase.dart';
import 'package:vettrack_frontend/features/recommendation/domain/usecases/get_recommendations_usecase.dart';
import 'package:vettrack_frontend/features/recommendation/presentation/cubit/recommendation_cubit.dart';
import 'package:vettrack_frontend/features/recommendation/data/repositories/recommendation_repository_impl.dart';
import 'package:vettrack_frontend/features/recommendation/data/datasources/recommendation_remote_datasource.dart';
import 'package:vettrack_frontend/features/recommendation/domain/repositories/recommendation_repository.dart';

// Notification Imports
import 'package:vettrack_frontend/core/services/firebase_messaging_service.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/register_device_token_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/unregister_device_token_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/mark_as_read_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/mark_all_as_read_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/get_unread_count_usecase.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:vettrack_frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:vettrack_frontend/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:vettrack_frontend/features/notification/domain/repositories/notification_repository.dart';

// Clinic Imports
import 'package:vettrack_frontend/features/clinic/data/datasources/clinic_remote_datasource.dart';
import 'package:vettrack_frontend/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:vettrack_frontend/features/clinic/domain/repositories/clinic_repository.dart';
import 'package:vettrack_frontend/features/clinic/domain/usecases/validate_invite_usecase.dart';
import 'package:vettrack_frontend/features/clinic/domain/usecases/accept_invite_usecase.dart';
import 'package:vettrack_frontend/features/clinic/domain/usecases/register_and_accept_invite_usecase.dart';
import 'package:vettrack_frontend/features/clinic/presentation/cubit/clinic_invite_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // EXTERNAL (Dış Kütüphaneler)
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(AuthInterceptor(sl(), () => sl<AuthCubit>()));
    return dio;
  });

  // ---------------------------------------------------------------------------
  // AUTH FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<TokenLocalDataSource>(
    () => TokenLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => GetOwnerProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOwnerProfileUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationEmailUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProfilePhotoUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfilePhotoUseCase(sl()));

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      loginWithEmail: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      signInWithGoogleUseCase: sl(),
      authRepository: sl(),
      registerDeviceTokenUseCase: sl(),
      unregisterDeviceTokenUseCase: sl(),
      forgotPasswordUseCase: sl(),
      resendVerificationEmailUsecase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileCubit(
        getOwnerProfile: sl(),
        updateOwnerProfile: sl(),
        updateProfilePhotoUseCase: sl(),
        deleteProfilePhotoUseCase: sl()),
  );

  sl.registerFactory(
    () => DeleteAccountCubit(
      authRepository: sl(),
      localDataSource: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // PET FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<PetRemoteDataSource>(
    () => PetRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetPetsUseCase(sl()));
  sl.registerLazySingleton(() => AddPetUseCase(sl()));
  sl.registerLazySingleton(() => GetPetByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePetUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePetPhotoUseCase(sl()));
  sl.registerLazySingleton(() => DeletePetPhotoUseCase(sl()));
  sl.registerLazySingleton(() => DeletePetUseCase(sl()));
  sl.registerLazySingleton(() => GetWeightHistoryUseCase(sl()));
  sl.registerFactory(() => WeightHistoryCubit(getWeightHistoryUseCase: sl()));

  sl.registerFactory(
    () => PetCubit(
      getPetsUseCase: sl(),
      addPetUseCase: sl(),
      getPetByIdUseCase: sl(),
      updatePetUseCase: sl(),
      updatePetPhotoUseCase: sl(),
      deletePetPhotoUseCase: sl(),
      deletePetUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // VISIT FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<VisitRemoteDataSource>(
    () => VisitRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VisitRepository>(
    () => VisitRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => SearchByCodeUseCase(sl()));
  sl.registerLazySingleton(() => StartVisitUseCase(sl()));
  sl.registerLazySingleton(() => CloseVisitUseCase(sl()));

  sl.registerFactory(
    () => VisitCubit(
      searchByCodeUseCase: sl(),
      startVisitUseCase: sl(),
      closeVisitUseCase: sl(),
      repository: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // TREATMENT FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<TreatmentRemoteDataSource>(
    () => TreatmentRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TreatmentRepository>(
    () => TreatmentRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => AddTreatmentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTreatmentUseCase(sl()));
  sl.registerLazySingleton(() => GetTreatmentUseCase(sl()));

  sl.registerFactory(
    () => TreatmentCubit(
      addTreatmentUseCase: sl(),
      deleteTreatmentUseCase: sl(),
      getTreatmentUseCase: sl(),
      repository: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // NOTIFICATION FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => RegisterDeviceTokenUseCase(sl()));
  sl.registerLazySingleton(() => UnregisterDeviceTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllAsReadUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));

  sl.registerFactory(
    () => NotificationCubit(
      registerDeviceTokenUseCase: sl(),
      getNotificationsUseCase: sl(),
      markAsReadUseCase: sl(),
      markAllAsReadUseCase: sl(),
      getUnreadCountUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // RECOMMENDATION FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<RecommendationRemoteDataSource>(
    () => RecommendationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RecommendationRepository>(
    () => RecommendationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => AddRecommendationUseCase(sl()));
  sl.registerLazySingleton(() => GetRecommendationsUseCase(sl()));

  sl.registerFactory(
    () => RecommendationCubit(
      addRecommendationUseCase: sl(),
      getRecommendationsUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // AI FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(sl()),
  );
  sl.registerFactory(
    () => AiChatCubit(aiRepository: sl()),
  );

  // ---------------------------------------------------------------------------
  // CLINIC FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ClinicRemoteDataSource>(
    () => ClinicRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ClinicRepository>(
    () => ClinicRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => ValidateInviteUseCase(sl()));
  sl.registerLazySingleton(() => AcceptInviteUseCase(sl()));
  sl.registerLazySingleton(() => RegisterAndAcceptInviteUseCase(sl()));
  sl.registerFactory(
    () => ClinicInviteCubit(
      validateInviteUseCase: sl(),
      acceptInviteUseCase: sl(),
      registerAndAcceptInviteUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // THEME FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(storage: sl()),
  );
}

