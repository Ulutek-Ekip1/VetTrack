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
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // İsteğe devam et
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final requestPath = err.requestOptions.path;
      if (requestPath != '/auth/login' && requestPath != '/auth/register') {
        getAuthCubit().handleSessionExpired();
      }
    }
    super.onError(err, handler);
  }
}
