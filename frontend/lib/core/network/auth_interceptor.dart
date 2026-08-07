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
    
    // Giriş ve kayıt gibi genel (public) isteklerde Authorization header'ı ekleme
    if (path != '/auth/login' && path != '/auth/register') {
      final token = await localDataSource.getToken();
      print("AuthInterceptor - Request Path: $path, Token: ${token != null ? 'Present (Ends with ${token.substring(token.length > 10 ? token.length - 10 : 0)})' : 'NULL'}");
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } else {
      print("AuthInterceptor - Public Request Path: $path");
    }

    // İsteğe devam et
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("AuthInterceptor - Error on path: ${err.requestOptions.path}, Status: ${err.response?.statusCode}, Error: ${err.message}, Response data: ${err.response?.data}");
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      if (requestPath != '/auth/login' && requestPath != '/auth/register') {
        print("AuthInterceptor - Session expired, redirecting to login...");
        getAuthCubit().handleSessionExpired();
      }
    }
    super.onError(err, handler);
  }
}
