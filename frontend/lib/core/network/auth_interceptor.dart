import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/token_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final TokenLocalDataSource localDataSource;

  AuthInterceptor(this.localDataSource);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await localDataSource.getToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // İsteğe devam et
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // 401 Unauthenticated alındığında loglama veya yönlendirme mantığı 
      // ileride buraya eklenebilir (Refresh token vs).
    }
    super.onError(err, handler);
  }
}
