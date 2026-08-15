import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettrack_frontend/core/error/exceptions.dart';
import 'package:vettrack_frontend/features/ai/domain/entities/ai_chat_request.dart';
import 'package:vettrack_frontend/features/ai/domain/entities/ai_chat_response.dart';
import 'package:vettrack_frontend/features/ai/domain/entities/chat_message.dart';
import 'package:vettrack_frontend/features/ai/domain/repositories/ai_repository.dart';
import 'package:vettrack_frontend/features/ai/presentation/cubit/ai_chat_cubit.dart';
import 'package:vettrack_frontend/features/ai/presentation/cubit/ui_chat_message.dart';

class MockAiRepository implements AiRepository {
  AiChatRequest? lastSendMessageRequest;
  int sendMessageCallCount = 0;
  bool shouldFailSendMessage = false;
  Exception? sendMessageException;
  AiChatResponse? mockSendMessageResponse;

  String? lastGetPetHistoryPetId;
  int? lastGetPetHistoryPage;
  List<ChatMessage> mockPetHistoryResponse = [];

  int getGeneralHistoryCallCount = 0;
  List<ChatMessage> mockGeneralHistoryResponse = [];

  String? lastDeletedConversationId;
  int deleteConversationCallCount = 0;
  bool shouldFailDeleteConversation = false;

  int deleteAllHistoryCallCount = 0;
  bool shouldFailDeleteAllHistory = false;

  @override
  Future<AiChatResponse> sendMessage(AiChatRequest request,
      {CancelToken? cancelToken}) async {
    sendMessageCallCount++;
    lastSendMessageRequest = request;
    if (shouldFailSendMessage) {
      throw sendMessageException ??
          const ServerException('İstek başarısız (500)');
    }
    return mockSendMessageResponse ??
        AiChatResponse(
          messageId: 'ai-msg-1',
          conversationId: request.conversationId ?? 'conv-new-123',
          emergency: false,
          reply: 'AI yanıtı test',
          disclaimer: 'Yasal uyarı',
          model: 'gemini-1.5-flash',
          promptVersion: 'v1.0',
          createdAt: DateTime.now().toIso8601String(),
        );
  }

  @override
  Future<List<ChatMessage>> getGeneralHistory(
      {int page = 0, int limit = 50}) async {
    getGeneralHistoryCallCount++;
    return mockGeneralHistoryResponse;
  }

  @override
  Future<List<ChatMessage>> getPetHistory(String petId,
      {int page = 0, int limit = 50}) async {
    lastGetPetHistoryPetId = petId;
    lastGetPetHistoryPage = page;
    return mockPetHistoryResponse;
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    deleteConversationCallCount++;
    lastDeletedConversationId = conversationId;
    if (shouldFailDeleteConversation) {
      throw const ServerException('Silme hatası (500)');
    }
  }

  @override
  Future<void> deleteAllHistory() async {
    deleteAllHistoryCallCount++;
    if (shouldFailDeleteAllHistory) {
      throw const ServerException('Tümünü silme hatası (500)');
    }
  }
}

void main() {
  late MockAiRepository mockRepository;
  late AiChatCubit cubit;

  setUp(() {
    mockRepository = MockAiRepository();
    cubit = AiChatCubit(aiRepository: mockRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('Step 10: State, Cache ve AI Chat Integration Testleri', () {
    test('1. İlk mesajda conversationId gönderilmemelidir (null)', () async {
      await cubit.sendMessage('Merhaba AI');

      expect(mockRepository.sendMessageCallCount, equals(1));
      expect(mockRepository.lastSendMessageRequest?.conversationId, isNull);
      expect(
          mockRepository.lastSendMessageRequest?.message, equals('Merhaba AI'));
    });

    test('2. İkinci mesajda backend den alınan conversationId gönderilmelidir',
        () async {
      mockRepository.mockSendMessageResponse = AiChatResponse(
        messageId: 'ai-1',
        conversationId: 'conv-abc-999',
        emergency: false,
        reply: 'İlk yanıt',
        disclaimer: 'Uyarı',
        model: 'm1',
        promptVersion: 'p1',
        createdAt: DateTime.now().toIso8601String(),
      );

      await cubit.sendMessage('İlk mesaj');
      expect(cubit.state.activeConversationId, equals('conv-abc-999'));

      await cubit.sendMessage('İkinci mesaj');
      expect(mockRepository.lastSendMessageRequest?.conversationId,
          equals('conv-abc-999'));
    });

    test('3. Retry işleminde aynı clientMessageId kullanılmalıdır', () async {
      mockRepository.shouldFailSendMessage = true;
      mockRepository.sendMessageException =
          const ServerException('Ağ Hatası', 503);

      await cubit.sendMessage('Hatalı Mesaj');
      final failedUserMsg =
          cubit.state.messages.firstWhere((m) => m.role == 'user');
      final firstClientMessageId = failedUserMsg.clientMessageId;
      expect(failedUserMsg.sendStatus, equals(MessageSendStatus.error));

      // Retry dene
      mockRepository.shouldFailSendMessage = false;
      await cubit.retryMessage(failedUserMsg);

      expect(mockRepository.lastSendMessageRequest?.clientMessageId,
          equals(firstClientMessageId));
    });

    test('4. Başarılı AI yanıtı doğru kullanıcı mesajının altına eklenmelidir',
        () async {
      await cubit.sendMessage('Soru?');

      expect(cubit.state.messages.length, equals(2));
      expect(cubit.state.messages[0].role, equals('user'));
      expect(cubit.state.messages[1].role, equals('model'));
      expect(cubit.state.messages[1].content, equals('AI yanıtı test'));
    });

    test('5. emergency: true yanıtında mesaj emergency olarak işaretlenmelidir',
        () async {
      mockRepository.mockSendMessageResponse = AiChatResponse(
        messageId: 'ai-emerg-1',
        conversationId: 'conv-emerg-1',
        emergency: true,
        reply: 'Kediniz kusuyorsa hemen kliniğe gidin!',
        disclaimer: 'Yasal Uayrı',
        model: 'm1',
        promptVersion: 'p1',
        createdAt: DateTime.now().toIso8601String(),
      );

      await cubit.sendMessage('Kedim zehirlendi galiba!');
      final aiMessage =
          cubit.state.messages.firstWhere((m) => m.role == 'model');

      expect(aiMessage.emergency, isTrue);
    });

    test(
        '6. HTTP Hata durumlarında uygun Türkçe mesajlar ve status code atanmalıdır',
        () async {
      // 400 Testi
      mockRepository.shouldFailSendMessage = true;
      mockRepository.sendMessageException =
          const ServerException('Bad Request', 400);
      await cubit.sendMessage('Gecersiz mesaj testi');
      expect(cubit.state.errorMessage, contains('Geçersiz veya boş mesaj'));

      // 401 Testi
      mockRepository.sendMessageException =
          const ServerException('Unauthorized', 401);
      await cubit.sendMessage('Test 401');
      expect(cubit.state.isAuthError, isTrue);

      // 403 Testi
      mockRepository.sendMessageException =
          const ServerException('Forbidden', 403);
      await cubit.sendMessage('Test 403');
      expect(cubit.state.errorMessage, contains('erişim yetkiniz'));

      // 409 Testi
      mockRepository.sendMessageException =
          const ServerException('Conflict', 409);
      await cubit.sendMessage('Test 409');
      expect(cubit.state.statusCode, equals(409));
      expect(cubit.state.errorMessage, contains('Mesaj kimlik çakışması'));

      // 429 Testi
      mockRepository.sendMessageException =
          const ServerException('Too Many Requests', 429, 0);
      await cubit.sendMessage('Test 429');
      expect(cubit.state.errorMessage, contains('Hız Limiti'));

      // 503 Testi
      mockRepository.sendMessageException =
          const ServerException('Service Unavailable', 503);
      await cubit.sendMessage('Test 503');
      expect(
          cubit.state.errorMessage, contains('servisi geçici olarak kullanılamıyor'));
    });

    test(
        '7. Tek konuşma ve tüm geçmiş silme sonrası state ve cache temizlenmelidir',
        () async {
      // Önce geçmiş simüle et
      mockRepository.mockGeneralHistoryResponse = [
        ChatMessage(
          id: 'm1',
          conversationId: 'c1',
          ownerId: 'u1',
          role: 'user',
          content: 'Hi',
          emergency: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
        ChatMessage(
          id: 'm2',
          conversationId: 'c2',
          ownerId: 'u1',
          role: 'user',
          content: 'Hello',
          emergency: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      ];

      await cubit.fetchHistory();
      expect(cubit.state.conversations.length, equals(2));

      // c1 i sil
      final deleteSuccess = await cubit.deleteConversation('c1');
      expect(deleteSuccess, isTrue);
      expect(cubit.state.conversations.length, equals(1));
      expect(cubit.state.conversations.first.conversationId, equals('c2'));

      // Tüm geçmişi sil
      final deleteAllSuccess = await cubit.deleteAllHistory();
      expect(deleteAllSuccess, isTrue);
      expect(cubit.state.conversations, isEmpty);
      expect(cubit.state.rawHistoryMessages, isEmpty);
      expect(cubit.state.messages, isEmpty);
      expect(cubit.state.activeConversationId, isNull);
    });

    test('8. Pet bazlı geçmiş isteği doğru petId ile yapılmalıdır', () async {
      cubit.setPetContext('pet-777');
      await cubit.fetchHistory();

      expect(mockRepository.lastGetPetHistoryPetId, equals('pet-777'));
      expect(mockRepository.lastGetPetHistoryPage, equals(0));
    });
  });
}
