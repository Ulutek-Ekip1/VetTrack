import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenLocalDataSource {
  Future<void> cacheToken(String token, {bool persist = true});
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<bool> isRememberMe();
}

class TokenLocalDataSourceImpl implements TokenLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String cachedTokenKey = 'CACHED_AUTH_TOKEN';
  static const String rememberMeKey = 'REMEMBER_ME_ENABLED';
  String? _sessionToken;

  TokenLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheToken(String token, {bool persist = true}) async {
    _sessionToken = token;
    if (persist) {
      await secureStorage.write(key: cachedTokenKey, value: token);
      await secureStorage.write(key: rememberMeKey, value: 'true');
    } else {
      await secureStorage.delete(key: cachedTokenKey);
      await secureStorage.delete(key: rememberMeKey);
    }
  }

  @override
  Future<String?> getToken() async {
    if (_sessionToken != null) return _sessionToken;

    final rememberMe = await secureStorage.read(key: rememberMeKey);
    if (rememberMe != 'true') return null;

    return secureStorage.read(key: cachedTokenKey);
  }

  @override
  Future<void> deleteToken() async {
    _sessionToken = null;
    await secureStorage.delete(key: cachedTokenKey);
    await secureStorage.delete(key: rememberMeKey);
  }

  @override
  Future<bool> isRememberMe() async {
    final rememberMe = await secureStorage.read(key: rememberMeKey);
    return rememberMe == 'true';
  }
}
