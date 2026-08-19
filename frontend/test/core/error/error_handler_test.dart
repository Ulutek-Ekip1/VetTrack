import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/error/error_handler.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';

void main() {
  group('ErrorHandler Tests', () {
    test('400 Bad Request with custom message should extract backend message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {'message': 'Geçersiz parametre girildi.'},
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 400);
      expect(exception.message, 'Geçersiz parametre girildi.');
    });

    test('400 Bad Request with validationErrors map should format errors', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'validationErrors': {
              'email': 'Geçerli bir e-posta giriniz.',
              'password': 'Şifre en az 6 karakter olmalıdır.',
            },
          },
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 400);
      expect(exception.message, contains('Geçerli bir e-posta giriniz.'));
      expect(exception.message, contains('Şifre en az 6 karakter olmalıdır.'));
    });

    test('401 Unauthorized should return user friendly session expired message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'error': 'UNAUTHORIZED'},
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 401);
      expect(exception.message, contains('Oturum süreniz doldu'));
    });

    test('403 Forbidden should return permission denied message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/visits/vet'),
        response: Response(
          requestOptions: RequestOptions(path: '/visits/vet'),
          statusCode: 403,
          data: {'message': 'Bu kliniğe erişim yetkiniz yok.'},
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 403);
      expect(exception.message, 'Bu kliniğe erişim yetkiniz yok.');
    });

    test('403 Forbidden without backend message should return fallback message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/visits/vet'),
        response: Response(
          requestOptions: RequestOptions(path: '/visits/vet'),
          statusCode: 403,
          data: null,
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 403);
      expect(exception.message, 'Bu işlem veya veriye erişim yetkiniz bulunmamaktadır.');
    });

    test('404 Not Found should return not found message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/pets/123'),
        response: Response(
          requestOptions: RequestOptions(path: '/pets/123'),
          statusCode: 404,
          data: {'message': 'Evcil hayvan bulunamadı.'},
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 404);
      expect(exception.message, 'Evcil hayvan bulunamadı.');
    });

    test('409 Conflict should return conflict message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/clinics/invites/accept'),
        response: Response(
          requestOptions: RequestOptions(path: '/clinics/invites/accept'),
          statusCode: 409,
          data: {'message': 'Bu davet kodu daha önce kullanılmış.'},
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 409);
      expect(exception.message, 'Bu davet kodu daha önce kullanılmış.');
    });

    test('410 Gone should return expired message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/clinics/invites/validate'),
        response: Response(
          requestOptions: RequestOptions(path: '/clinics/invites/validate'),
          statusCode: 410,
          data: null,
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 410);
      expect(exception.message, 'Bu işlemin veya davet kodunun süresi dolmuş.');
    });

    test('429 Too Many Requests should parse retry-after header', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/ai/chat'),
        response: Response(
          requestOptions: RequestOptions(path: '/ai/chat'),
          statusCode: 429,
          headers: Headers.fromMap({
            'retry-after': ['30']
          }),
          data: null,
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 429);
      expect(exception.retryAfterSeconds, 30);
      expect(exception.message, contains('Çok fazla istek gönderildi'));
    });

    test('500 Internal Server Error with technical stacktrace should mask into friendly message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: 'org.springframework.dao.DataAccessException: Connection refused\n\tat com.vettrack...',
        ),
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.statusCode, 500);
      expect(exception.message, 'Sunucu kaynaklı bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.');
    });

    test('Connection Timeout should return network timeout message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.message, contains('zaman aşımı'));
    });

    test('Connection Error should return network connection error message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final exception = ErrorHandler.handleDioError(dioException);

      expect(exception.message, contains('Sunucuya bağlanılamadı'));
    });

    test('ServerException.fromDio factory delegates to ErrorHandler', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
          data: null,
        ),
      );

      final exception = ServerException.fromDio(dioException);

      expect(exception.statusCode, 403);
      expect(exception.message, 'Bu işlem veya veriye erişim yetkiniz bulunmamaktadır.');
    });
  });
}
