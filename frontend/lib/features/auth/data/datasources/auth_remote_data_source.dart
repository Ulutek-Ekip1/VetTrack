import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import 'token_local_data_source.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> register(
      String email, String password, String name, String? phone, UserRole role);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final TokenLocalDataSource localDataSource;

  AuthRemoteDataSourceImpl(this.dio, this.localDataSource);

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['accessToken'];

        if (token != null) {
          await localDataSource.cacheToken(token);
        }

        return UserModel.fromJson(userData);
      } else {
        throw Exception("Giriş başarısız: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception("E-posta veya şifre hatalı");
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception("Beklenmedik bir hata oluştu: $e");
    }
  }

  @override
  Future<UserModel> register(String email, String password, String name,
      String? phone, UserRole role) async {
    try {
      final roleStr = role == UserRole.vet ? 'vet_staff' : 'owner';

      final data = {
        'email': email,
        'password': password,
        'name': name,
        'role': roleStr,
      };

      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      final response = await dio.post('/auth/register', data: data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userData = response.data['user'];
        final token = response.data['accessToken'];

        if (token != null) {
          await localDataSource.cacheToken(token);
        }

        return UserModel.fromJson(userData);
      } else {
        throw Exception("Kayıt başarısız: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception("Bu e-posta adresi zaten kullanımda");
      }
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception("Beklenmedik bir kayıt hatası: $e");
    }
  }

  @override
  Future<void> logout() async {
    // API Sözleşmesinde logout endpoint'i yok, sadece yerel token silinir.
    await localDataSource.deleteToken();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // API Sözleşmesindeki endpoint: GET /auth/me
      // Bu isteğin başarılı olması için Dio'nun içine Token'ın Header olarak eklenmesi gerekir (Interceptor).
      final response = await dio.get('/auth/me');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      try {
        final errorMsg = e.response?.data['message'];
        if (errorMsg != null) return errorMsg.toString();
      } catch (_) {}
    }
    return e.message ?? "Bilinmeyen bağlantı hatası";
  }
}
