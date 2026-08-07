import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/auth_interceptor.dart';
import '../../features/auth/data/datasources/token_local_data_source.dart';

// Pet Imports
import 'package:vettrack_frontend/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:vettrack_frontend/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:vettrack_frontend/features/pet/domain/repositories/pet_repository.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pet_by_id_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/get_pets_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_photo_usecase.dart';
import 'package:vettrack_frontend/features/pet/domain/usecases/update_pet_usecase.dart';
import 'package:vettrack_frontend/features/pet/presentation/cubit/pet_cubit.dart';

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
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/domain/usecases/get_owner_profile_usecase.dart';
import '../../features/auth/domain/usecases/update_owner_profile_usecase.dart';
import '../../features/auth/presentation/cubit/profile_cubit.dart';

// Treatment Imports
import 'package:vettrack_frontend/features/treatment/domain/usecases/add_treatment_usecase.dart';
import 'package:vettrack_frontend/features/treatment/domain/usecases/delete_treatment_usecase.dart';
import 'package:vettrack_frontend/features/treatment/domain/usecases/get_treatment_usecase.dart';
import 'package:vettrack_frontend/features/treatment/presentation/cubit/treatment_cubit.dart';
import 'package:vettrack_frontend/features/treatment/data/repositories/treatment_repository_impl.dart';
import 'package:vettrack_frontend/features/treatment/data/datasources/treatment_remote_datasource.dart';
import 'package:vettrack_frontend/features/treatment/domain/repositories/treatment_repository.dart';

// Notification Imports
import 'package:vettrack_frontend/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/register_device_token_usecase.dart';
import 'package:vettrack_frontend/features/notification/domain/usecases/unregister_device_token_usecase.dart';
import 'package:vettrack_frontend/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:vettrack_frontend/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:vettrack_frontend/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:vettrack_frontend/features/notification/domain/repositories/notification_repository.dart';

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
      baseUrl: 'http://10.0.2.2:8080/api',
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
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
  sl.registerLazySingleton(() => GetOwnerProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOwnerProfileUseCase(sl()));

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      loginWithEmail: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
      registerDeviceTokenUseCase: sl(),
      unregisterDeviceTokenUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileCubit(
      getOwnerProfile: sl(),
      updateOwnerProfile: sl(),
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
  sl.registerLazySingleton(() => DeletePetUseCase(sl()));

  sl.registerFactory(
    () => PetCubit(
      getPetsUseCase: sl(),
      addPetUseCase: sl(),
      getPetByIdUseCase: sl(),
      updatePetUseCase: sl(),
      updatePetPhotoUseCase: sl(),
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
    ),
  );

  // ---------------------------------------------------------------------------
  // NOTIFICATION FEATURE
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => RegisterDeviceTokenUseCase(sl()));
  sl.registerLazySingleton(() => UnregisterDeviceTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));

  sl.registerFactory(
    () => NotificationCubit(
      registerDeviceTokenUseCase: sl(),
      getNotificationsUseCase: sl(),
    ),
  );
}