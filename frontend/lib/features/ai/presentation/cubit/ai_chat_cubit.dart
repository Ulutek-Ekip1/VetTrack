import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/ai_chat_request.dart';
import '../../domain/repositories/ai_repository.dart';
import 'ai_chat_state.dart';
import 'ui_chat_message.dart';

class AiChatCubit extends Cubit<AiChatState> {
  final AiRepository aiRepository;
  CancelToken? _cancelToken;

  AiChatCubit({required this.aiRepository}) : super(const AiChatState());

  void setPetContext(String? petId) {
    emit(state.copyWith(
      activePetId: petId,
      clearPetId: petId == null || petId.isEmpty,
    ));
  }

  void clearPetContext() {
    emit(state.copyWith(
      clearPetId: true,
      clearConversationId: true, // Pet bağlamı kaldırıldığında aktif conversationId temizlenir
    ));
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || state.isSending) return;

    final clientMessageId = UuidGenerator.generateV4();

    final userMessage = UiChatMessage(
      id: clientMessageId,
      clientMessageId: clientMessageId,
      conversationId: state.activeConversationId ?? '',
      role: 'user',
      content: trimmedText,
      emergency: false,
      sendStatus: MessageSendStatus.sending,
      createdAt: DateTime.now().toIso8601String(),
    );

    final updatedMessages = List<UiChatMessage>.from(state.messages)..add(userMessage);

    emit(state.copyWith(
      messages: updatedMessages,
      isSending: true,
      clearErrorMessage: true,
      clearStatusCode: true,
    ));

    await _executeSendRequest(
      clientMessageId: clientMessageId,
      messageText: trimmedText,
      existingUserMessageId: clientMessageId,
    );
  }

  Future<void> retryMessage(UiChatMessage failedUserMessage) async {
    if (state.isSending) return;

    final clientMessageId = failedUserMessage.clientMessageId ?? UuidGenerator.generateV4();

    final updatedMessages = state.messages.map((m) {
      if (m.id == failedUserMessage.id) {
        return m.copyWith(
          sendStatus: MessageSendStatus.sending,
          clearErrorMessage: true,
        );
      }
      return m;
    }).toList();

    emit(state.copyWith(
      messages: updatedMessages,
      isSending: true,
      clearErrorMessage: true,
      clearStatusCode: true,
    ));

    await _executeSendRequest(
      clientMessageId: clientMessageId,
      messageText: failedUserMessage.content,
      existingUserMessageId: failedUserMessage.id,
    );
  }

  Future<void> _executeSendRequest({
    required String clientMessageId,
    required String messageText,
    required String existingUserMessageId,
  }) async {
    _cancelToken = CancelToken();

    final request = AiChatRequest(
      conversationId: state.activeConversationId,
      clientMessageId: clientMessageId,
      petId: state.activePetId,
      message: messageText,
    );

    try {
      final response = await aiRepository.sendMessage(request, cancelToken: _cancelToken);

      final updatedMessages = state.messages.map((m) {
        if (m.id == existingUserMessageId) {
          return m.copyWith(
            conversationId: response.conversationId,
            sendStatus: MessageSendStatus.sent,
          );
        }
        return m;
      }).toList();

      final aiMessage = UiChatMessage(
        id: response.messageId,
        conversationId: response.conversationId,
        role: 'model',
        content: response.reply,
        emergency: response.emergency,
        disclaimer: response.disclaimer,
        sendStatus: MessageSendStatus.sent,
        createdAt: response.createdAt,
      );

      updatedMessages.add(aiMessage);

      emit(state.copyWith(
        messages: updatedMessages,
        activeConversationId: response.conversationId,
        isSending: false,
      ));
    } catch (e) {
      if (_cancelToken?.isCancelled ?? false) {
        // İptal durumunda state temizleme harici işlem yapılmaz
        emit(state.copyWith(isSending: false));
        return;
      }

      int? statusCode;
      String errorMsg = 'Mesaj gönderilirken ağ hatası oluştu.';

      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMsg = e.message!;
        final match = RegExp(r'\((\d{3})\)').firstMatch(e.message!);
        if (match != null) {
          statusCode = int.tryParse(match.group(1)!);
        }
      }

      final updatedMessages = state.messages.map((m) {
        if (m.id == existingUserMessageId) {
          return m.copyWith(
            sendStatus: MessageSendStatus.error,
            errorMessage: errorMsg,
          );
        }
        return m;
      }).toList();

      emit(state.copyWith(
        messages: updatedMessages,
        isSending: false,
        errorMessage: errorMsg,
        statusCode: statusCode,
      ));
    } finally {
      _cancelToken = null;
    }
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('Screen disposed');
    return super.close();
  }
}
