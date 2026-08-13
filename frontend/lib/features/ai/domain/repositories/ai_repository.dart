import 'package:dio/dio.dart';
import '../entities/ai_chat_request.dart';
import '../entities/ai_chat_response.dart';
import '../entities/chat_message.dart';

abstract class AiRepository {
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
