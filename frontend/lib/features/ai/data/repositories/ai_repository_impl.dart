import 'package:dio/dio.dart';
import 'package:vettrack_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:vettrack_frontend/features/ai/data/datasources/ai_remote_datasource.dart';
import 'package:vettrack_frontend/features/ai/domain/entities/ai_chat_request.dart';
import 'package:vettrack_frontend/features/ai/domain/entities/ai_chat_response.dart';
import 'package:vettrack_frontend/features/ai/domain/entities/chat_message.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource remoteDataSource;

  AiRepositoryImpl(this.remoteDataSource);

  @override
  Future<AiChatResponse> sendMessage(
    AiChatRequest request, {
    CancelToken? cancelToken,
  }) {
    return remoteDataSource.sendMessage(request, cancelToken: cancelToken);
  }

  @override
  Future<List<ChatMessage>> getGeneralHistory({
    int page = 0,
    int limit = 50,
  }) {
    return remoteDataSource.getGeneralHistory(page: page, limit: limit);
  }

  @override
  Future<List<ChatMessage>> getPetHistory(
    String petId, {
    int page = 0,
    int limit = 50,
  }) {
    return remoteDataSource.getPetHistory(petId, page: page, limit: limit);
  }

  @override
  Future<void> deleteConversation(String conversationId) {
    return remoteDataSource.deleteConversation(conversationId);
  }

  @override
  Future<void> deleteAllHistory() {
    return remoteDataSource.deleteAllHistory();
  }
}
