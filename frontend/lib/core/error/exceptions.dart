class ServerException implements Exception {
  final String? message;
  final int? statusCode;
  final int? retryAfterSeconds;

  const ServerException([
    this.message,
    this.statusCode,
    this.retryAfterSeconds,
  ]);

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
