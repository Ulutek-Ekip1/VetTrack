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
      throw const ServerException('Geçersiz davet kodu.');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverMsg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])?.toString()
          : null;

      if (status == 404) {
        throw ServerException(serverMsg ?? 'Davet kodu bulunamadı veya geçersiz.', 404);
      } else if (status == 410 || (serverMsg != null && serverMsg.toLowerCase().contains('dolmuş'))) {
        throw ServerException(serverMsg ?? 'Bu davet kodunun süresi dolmuş.', 410);
      } else if (status == 409 || (serverMsg != null && serverMsg.toLowerCase().contains('kullanılmış'))) {
        throw ServerException(serverMsg ?? 'Bu davet kodu daha önce kullanılmış.', 409);
      }
      throw ServerException(serverMsg ?? e.message ?? 'Davet kodu doğrulanamadı.', status);
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
      final serverMsg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])?.toString()
          : null;
      throw ServerException(serverMsg ?? e.message ?? 'Klinik üyeliği kabul edilemedi.', e.response?.statusCode);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
