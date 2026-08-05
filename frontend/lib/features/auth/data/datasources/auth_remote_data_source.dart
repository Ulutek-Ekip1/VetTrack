import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/owner_model.dart';
import '../../domain/entities/user_entity.dart';
import 'token_local_data_source.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> register(
      String email, String password, String name, String? phone, UserRole role);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<OwnerModel> getOwnerProfile();
  Future<OwnerModel> updateOwnerProfile(Map<String, dynamic> data);
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
        throw Exception("Bu e-posta ile kayıtlı bir hesap var, lütfen farklı bir e-posta ile deneyin.");
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

  @override
  Future<OwnerModel> getOwnerProfile() async {
    try {
      final response = await dio.get('/owners/me');
      if (response.statusCode == 200) {
        return OwnerModel.fromJson(response.data);
      } else {
        throw Exception("Profil bilgileri alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      // Çevrimdışı/Yerel testler için mock verisi
      return OwnerModel(
        id: '123',
        name: 'Oguz',
        surname: 'Karan',
        email: 'test@example.com',
        phone: '05555555555',
        address: 'Bursa, Nilüfer',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<OwnerModel> updateOwnerProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/owners/me', data: data);
      if (response.statusCode == 200) {
        return OwnerModel.fromJson(response.data);
      } else {
        throw Exception("Profil güncellenemedi: ${response.statusCode}");
      }
    } catch (e) {
      // Çevrimdışı/Yerel testler için güncellenmiş mock verisi
      return OwnerModel(
        id: '123',
        name: data['name'] ?? 'Oguz',
        surname: data['surname'],
        email: 'test@example.com',
        phone: data['phone'],
        address: data['address'],
        createdAt: DateTime.now(),
      );
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      try {
        final errorMsg = e.response?.data['message'];
        if (errorMsg != null) return errorMsg.toString();
      } catch (_) {}
    }

    final message = e.message ?? "";
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        message.contains('XMLHttpRequest') ||
        message.contains('SocketException')) {
      return "İnternet bağlantınız koptu veya sunucuya erişilemiyor. Lütfen internetinizi kontrol edin.";
    }

    return message.isNotEmpty ? message : "Bilinmeyen bağlantı hatası";
  }
}
