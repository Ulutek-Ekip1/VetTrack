import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/invite_validation_model.dart';

abstract class ClinicRemoteDataSource {
  Future<InviteValidationModel> validateInviteToken(String token);
  Future<void> acceptInvite(String token);
}

class ClinicRemoteDataSourceImpl implements ClinicRemoteDataSource {
  final Dio dio;

  ClinicRemoteDataSourceImpl(this.dio);

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
      throw ServerException.fromDio(e, defaultMessage: 'Davet kodu doğrulanamadı.');
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
      throw ServerException.fromDio(e, defaultMessage: 'Klinik üyeliği kabul edilemedi.');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
