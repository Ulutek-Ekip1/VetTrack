class ServerException implements Exception {
  final String? message;
  final int? statusCode;
  final int? retryAfterSeconds;

  const ServerException([
    this.message,
    this.statusCode,
    this.retryAfterSeconds,
  ]);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);
}
