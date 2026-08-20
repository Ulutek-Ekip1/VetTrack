import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/token_local_data_source.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

class AuthInterceptor extends Interceptor {
  final TokenLocalDataSource localDataSource;
  final AuthCubit Function() getAuthCubit;

  AuthInterceptor(this.localDataSource, this.getAuthCubit);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;

    // Giriş, kayıt ve şifre sıfırlama gibi genel (public) isteklerde Authorization header'ı ekleme
    if (!_isPublicAuthPath(path)) {
      final token = await localDataSource.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // İsteğe devam et
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final hasAuthorizationHeader =
        err.requestOptions.headers['Authorization'] != null;

    if (err.response?.statusCode == 401 && hasAuthorizationHeader) {
      final requestPath = err.requestOptions.path;

      if (!_isPublicAuthPath(requestPath)) {
        final data = err.response?.data;
        final errorCode = (data is Map) ? data['error'] : null;

        // Yetki/özel durum hatalarında (örn. REAUTHENTICATION_REQUIRED, EMAIL_NOT_VERIFIED)
        // kullanıcı oturumu hemen kapatılmamalı; yalnızca gerçek token süresi dolması /
        // geçersiz token durumlarında (UNAUTHORIZED veya standart 401) oturum sonlandırılmalıdır.
        final isSpecificNonExpiryError =
            errorCode == 'REAUTHENTICATION_REQUIRED' ||
                errorCode == 'EMAIL_NOT_VERIFIED' ||
                errorCode == 'INVALID_CREDENTIALS';

        if (!isSpecificNonExpiryError) {
          getAuthCubit().handleSessionExpired();
        }
      }
    }

    super.onError(err, handler);
  }

  bool _isPublicAuthPath(String path) {
    return path == '/auth/login' ||
        path == '/auth/register' ||
        path == '/auth/resend-verification' ||
        path == '/auth/forgot-password' ||
        path == '/auth/reset-password';
  }
}
