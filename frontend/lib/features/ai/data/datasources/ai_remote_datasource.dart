import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ai_chat_request.dart';
import '../../domain/entities/ai_chat_response.dart';
import '../../domain/entities/chat_message.dart';

abstract class AiRemoteDataSource {
  Future<AiChatResponse> sendMessage(
    AiChatRequest request, {
    CancelToken? cancelToken,
  });

  Future<List<ChatMessage>> getGeneralHistory({
    int page = 0,
    int limit = 50,
  });

  Future<List<ChatMessage>> getPetHistory(
    String petId, {
    int page = 0,
    int limit = 50,
  });

  Future<void> deleteConversation(String conversationId);

  Future<void> deleteAllHistory();
}

class AiRemoteDataSourceImpl implements AiRemoteDataSource {
  final Dio dio;

  AiRemoteDataSourceImpl(this.dio);

  @override
  Future<AiChatResponse> sendMessage(
    AiChatRequest request, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.post(
        '/api/ai/chat',
        data: request.toJson(),
        cancelToken: cancelToken,
      );

      return AiChatResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw ServerException('İstek iptal edildi.');
      }
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException('Mesaj gönderilirken beklenmeyen bir hata oluştu.');
    }
  }

  @override
  Future<List<ChatMessage>> getGeneralHistory({
    int page = 0,
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/api/ai/chat/history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List list = response.data as List;
      return list
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ChatMessage>> getPetHistory(
    String petId, {
    int page = 0,
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '/api/ai/chat/history/$petId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List list = response.data as List;
      return list
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await dio.delete('/api/ai/chat/history/conversation/$conversationId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteAllHistory() async {
    try {
      await dio.delete('/api/ai/chat/history');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      String message = '';
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'].toString();
      }

      switch (statusCode) {
        case 400:
          return ServerException(
              message.isNotEmpty ? message : 'Geçersiz sohbet isteği (400).');
        case 401:
          return ServerException('Oturum süreniz doldu, lütfen tekrar giriş yapın (401).');
        case 403:
          return ServerException(
              message.isNotEmpty ? message : 'Bu işleme erişim yetkiniz bulunmuyor (403).');
        case 409:
          return ServerException(
              message.isNotEmpty ? message : 'Idempotency çakışması: Aynı mesaj kimliği tekrar kullanılamaz (409).');
        case 429:
          return ServerException(
              'Çok fazla istek gönderdiniz. Lütfen biraz bekleyip tekrar deneyin (429).');
        case 503:
          return ServerException(
              'Yapay zeka servisi şu anda geçici olarak hizmet veremiyor (503).');
        default:
          return ServerException(
              message.isNotEmpty ? message : 'Sunucu hatası ($statusCode).');
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ServerException('Bağlantı hatası: İnternet bağlantınızı kontrol ediniz.');
    }

    return ServerException(e.message ?? 'Ağ hatası oluştu.');
  }
}
