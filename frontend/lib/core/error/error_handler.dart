import 'package:dio/dio.dart';
import 'exceptions.dart';

class ErrorHandler {
  /// Converts any [DioException] into a domain-safe, user-friendly [ServerException].
  static ServerException handleDioError(
    DioException e, {
    String? defaultMessage,
  }) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final retryAfterSeconds =
          int.tryParse(e.response!.headers.value('retry-after') ?? '');
      final data = e.response!.data;

      String? serverMessage;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('validationErrors') &&
            data['validationErrors'] is Map &&
            (data['validationErrors'] as Map).isNotEmpty) {
          final valMap = data['validationErrors'] as Map;
          serverMessage = valMap.values.map((v) => v.toString()).join(', ');
        } else if (data.containsKey('message') &&
            data['message'] != null &&
            data['message'].toString().trim().isNotEmpty) {
          final rawMsg = data['message'].toString().trim();
          if (_isFriendlyServerMessage(rawMsg)) {
            serverMessage = rawMsg;
          }
        }
      } else if (data is String && data.trim().isNotEmpty) {
        // Do not use raw HTML or stack trace strings as user messages
        if (!data.contains('<html') && !data.contains('Exception') && data.length < 200) {
          final rawStr = data.trim();
          if (_isFriendlyServerMessage(rawStr)) {
            serverMessage = rawStr;
          }
        }
      }

      final errorCode = data is Map<String, dynamic>
          ? (data['error'] ?? data['errorCode'])?.toString()
          : null;

      switch (statusCode) {
        case 400:
          return ServerException(
            serverMessage ?? defaultMessage ?? 'Geçersiz istek gönderildi.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 401:
          return ServerException(
            serverMessage ?? 'Oturum süreniz doldu veya yetkisiz erişim. Lütfen tekrar giriş yapınız.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 403:
          return ServerException(
            serverMessage ?? 'Bu işlem veya veriye erişim yetkiniz bulunmamaktadır.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 404:
          return ServerException(
            serverMessage ?? defaultMessage ?? 'İstenen kayıt veya sayfa bulunamadı.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 409:
          return ServerException(
            serverMessage ?? defaultMessage ?? 'Bu kayıt zaten mevcut veya işlem çakışması oluştu.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 410:
          return ServerException(
            serverMessage ?? 'Bu işlemin veya davet kodunun süresi dolmuş.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 413:
          return ServerException(
            serverMessage ?? 'Yüklenen dosya boyutu çok büyük (maksimum 15MB).',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 415:
          return ServerException(
            serverMessage ?? 'Desteklenmeyen dosya formatı.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 429:
          return ServerException(
            serverMessage ?? 'Çok fazla istek gönderildi. Lütfen bir süre bekleyip tekrar deneyiniz.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException(
            _isFriendlyServerMessage(serverMessage)
                ? serverMessage!
                : 'Sunucu kaynaklı bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
        default:
          return ServerException(
            serverMessage ?? defaultMessage ?? 'Sunucu hatası ($statusCode).',
            statusCode,
            retryAfterSeconds,
            errorCode,
          );
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(
          'Sunucuya bağlanırken zaman aşımı oluştu. Lütfen internet bağlantınızı kontrol ediniz.',
        );
      case DioExceptionType.connectionError:
        return const ServerException(
          'Sunucuya bağlanılamadı. Lütfen internet bağlantınızı kontrol ediniz.',
        );
      case DioExceptionType.cancel:
        return const ServerException('İstek iptal edildi.');
      case DioExceptionType.badCertificate:
        return const ServerException('Güvenli bağlantı kurulamadı (Sertifika hatası).');
      case DioExceptionType.unknown:
      default:
        final rawMsg = e.error?.toString() ?? e.message ?? '';
        if (rawMsg.toLowerCase().contains('socket') ||
            rawMsg.toLowerCase().contains('network') ||
            rawMsg.toLowerCase().contains('connection') ||
            rawMsg.toLowerCase().contains('failed host lookup')) {
          return const ServerException(
            'İnternet bağlantısı kurulamadı. Lütfen ağ bağlantınızı kontrol ediniz.',
          );
        }
        return ServerException(defaultMessage ?? 'Beklenmeyen bir hata oluştu.');
    }
  }

  static bool _isFriendlyServerMessage(String? msg) {
    if (msg == null || msg.trim().isEmpty) return false;
    final lower = msg.toLowerCase();
    if (lower.contains('exception') ||
        lower.contains('nullpointer') ||
        lower.contains('stacktrace') ||
        lower.contains('internal server error') ||
        lower.contains('sql') ||
        lower.contains('hibernate')) {
      return false;
    }
    return true;
  }
}
