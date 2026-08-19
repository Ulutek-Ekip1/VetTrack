import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/datasources/token_local_data_source.dart';
import '../models/invite_validation_model.dart';

abstract class ClinicRemoteDataSource {
  Future<InviteValidationModel> validateInviteToken(String token);
  Future<void> acceptInvite(String token);
  Future<void> registerAndAcceptInvite({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String token,
  });
}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
  final Dio dio;
  final TokenLocalDataSource localDataSource;

  ClinicRemoteDataSourceImpl(this.dio, this.localDataSource);

  @override
  Future<InviteValidationModel> validateInviteToken(String token) async {
    try {
      final response = await dio.get(
        '/clinics/invites/validate',
        queryParameters: {'token': token.trim()},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return InviteValidationModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Geçersiz davet kodu.', 400);
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Davet kodu doğrulanamadı.');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> acceptInvite(String token) async {
    try {
      final response = await dio.post(
        '/clinics/invites/accept',
        data: {'token': token.trim()},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Davet kabul edilemedi: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Klinik üyeliği kabul edilemedi.');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> registerAndAcceptInvite({
    required String email,
    required String password,
    required String name,
    String? phone,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/clinics/invites/register-and-accept',
        data: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
          'phone': phone?.trim(),
          'token': token.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final tokenVal = response.data['accessToken'];
        if (tokenVal != null) {
          await localDataSource.cacheToken(tokenVal);
        }
      } else {
        throw ServerException('Kayıt işlemi tamamlanamadı: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e, defaultMessage: 'Kayıt ve davet kabulü gerçekleştirilemedi.');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
