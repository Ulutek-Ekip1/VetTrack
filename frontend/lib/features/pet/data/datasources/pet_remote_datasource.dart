// Fotoğraf Supabase Storage yükleyici
import 'package:dio/dio.dart';
import 'package:vettrack_frontend/features/auth/data/datasources/token_local_data_source.dart';

abstract class PetRemoteDataSource {}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final Dio dio;
  final TokenLocalDataSource localDataSource;

  PetRemoteDataSourceImpl(this.dio, this.localDataSource);
}
