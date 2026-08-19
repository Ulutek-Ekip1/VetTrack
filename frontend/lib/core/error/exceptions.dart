import 'package:dio/dio.dart';
import 'error_handler.dart';

class ServerException implements Exception {
  final String? message;
  final int? statusCode;
  final int? retryAfterSeconds;

  const ServerException([
    this.message,
    this.statusCode,
    this.retryAfterSeconds,
  ]);

  factory ServerException.fromDio(DioException e, {String? defaultMessage}) {
    return ErrorHandler.handleDioError(e, defaultMessage: defaultMessage);
  }

  @override
  String toString() {
    return message ?? 'Sunucudan yanıt alınamadı. Lütfen daha sonra tekrar deneyiniz.';
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);

  @override
  String toString() => message;
}

