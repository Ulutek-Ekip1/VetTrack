import 'package:dio/dio.dart';
import '../../../../core/error/error_handler.dart';
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
        throw const ServerException('İstek iptal edildi.');
      }
      throw _handleDioError(e);
    } catch (e) {
      throw const ServerException('Mesaj gönderilirken beklenmeyen bir hata oluştu.');
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
    } catch (e) {
      throw const ServerException('Sohbet geçmişi alınırken hata oluştu.');
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
    } catch (e) {
      throw const ServerException('Pet sohbet geçmişi alınırken hata oluştu.');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await dio.delete('/api/ai/chat/history/conversation/$conversationId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw const ServerException('Sohbet silinirken hata oluştu.');
    }
  }

  @override
  Future<void> deleteAllHistory() async {
    try {
      await dio.delete('/api/ai/chat/history');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw const ServerException('Tüm sohbet geçmişi silinirken hata oluştu.');
    }
  }

  ServerException _handleDioError(DioException e) {
    return ErrorHandler.handleDioError(e, defaultMessage: 'Yapay zeka servisiyle iletişim kurulamadı.');
  }
}
