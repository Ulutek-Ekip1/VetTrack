import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

class TokenLocalDataSourceImpl implements TokenLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const String cachedTokenKey = 'CACHED_AUTH_TOKEN';

  TokenLocalDataSourceImpl(this.secureStorage);

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: cachedTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: cachedTokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: cachedTokenKey);
  }
}
