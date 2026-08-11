import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
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
  Future<UserModel> signInWithGoogle();
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
      // Supabase OAuth dönüşlerinde oturumu senkronize etmek için:
      final supabaseSession = Supabase.instance.client.auth.currentSession;
      if (supabaseSession != null) {
        final cachedToken = await localDataSource.getToken();
        if (cachedToken == null || cachedToken != supabaseSession.accessToken) {
          await localDataSource.cacheToken(supabaseSession.accessToken);
        }
      }

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
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web'de Google Giriş için Supabase'in kendi OAuth akışını kullanıyoruz.
        // Web ortamı Veteriner Paneli olduğu için yönlendirme sonrası Supabase veya profil tarafında rol okunur.
        final redirectTo = Uri.base.origin;
        
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectTo,
        );
        
        // Yönlendirme yapılacağı için bu metodun return değerine ulaşılmayacaktır.
        return UserModel(
          id: '',
          authId: '',
          email: '',
          name: 'Yönlendiriliyor...',
          role: UserRole.vet,
          createdAt: DateTime.now(),
        );
      } else {
        // Mobil için mevcut google_sign_in akışı
        final googleSignIn = GoogleSignIn(
          serverClientId: AppConstants.googleWebClientId.isEmpty ? null : AppConstants.googleWebClientId,
          scopes: ['email', 'profile', 'openid'],
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw Exception("Google ile giriş iptal edildi.");
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        final accessToken = googleAuth.accessToken;

        if (idToken == null) {
          throw Exception("Google Kimlik Doğrulama Token'ı alınamadı.");
        }

        final response = await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        if (response.user == null || response.session == null) {
          throw Exception("Supabase oturumu başlatılamadı.");
        }

        // Cache the token locally
        await localDataSource.cacheToken(response.session!.accessToken);

        final user = response.user!;
        var metadata = user.userMetadata ?? {};
        var rawRole = metadata['role'] as String?;

        // Eğer kullanıcı ilk kez Google ile giriş yapıyorsa ve rolü henüz set edilmediyse:
        // Mobil tarafı olduğu için varsayılan rol 'owner' olarak güncellenir.
        if (rawRole == null || rawRole.isEmpty) {
          rawRole = 'owner';
          try {
            await Supabase.instance.client.auth.updateUser(
              UserAttributes(data: {'role': 'owner'}),
            );
          } catch (_) {}
        }

        return UserModel(
          id: user.id,
          authId: user.id,
          email: user.email ?? '',
          name: (metadata['name'] ?? metadata['full_name'] ?? 'Google Kullanıcısı') as String,
          phone: user.phone,
          role: rawRole == 'vet_staff' || rawRole == 'VET' ? UserRole.vet : UserRole.owner,
          createdAt: DateTime.parse(user.createdAt),
        );
      }
    } catch (e) {
      throw Exception("Google giriş hatası: $e");
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
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      rethrow;
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
