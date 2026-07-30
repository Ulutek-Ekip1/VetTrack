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
      baseUrl:
          'http://10.0.2.2:8080/api', // Android Emulator default local backend
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(AuthInterceptor(sl()));
    return dio;
  });

  // ---------------------------------------------------------------------------
  // AUTH FEATURE (Kimlik Doğrulama Özelliği)
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

  sl.registerFactory(
    () => AuthCubit(
      loginWithEmail: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
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
}
