import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/ai_chat_request.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import 'ai_chat_state.dart';
import 'conversation_group.dart';
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

  Future<void> fetchHistory({bool isLoadMore = false, String? petId}) async {
    if (isLoadMore) {
      if (!state.hasMoreHistory || state.isLoadingMoreHistory) return;
      emit(state.copyWith(isLoadingMoreHistory: true));
    } else {
      emit(state.copyWith(
        isLoadingHistory: true,
        isHistoryError: false,
        clearHistoryErrorMessage: true,
        historyPage: 0,
      ));
    }

    final pageToFetch = isLoadMore ? state.historyPage + 1 : 0;
    final targetPetId = petId ?? state.activePetId;

    try {
      final List<ChatMessage> fetched = (targetPetId != null && targetPetId.isNotEmpty)
          ? await aiRepository.getPetHistory(targetPetId, page: pageToFetch, limit: 50)
          : await aiRepository.getGeneralHistory(page: pageToFetch, limit: 50);

      _processFetchedHistory(fetched, isLoadMore: isLoadMore, fetchedPage: pageToFetch);
    } catch (e) {
      String errorMsg = 'Sohbet geçmişi yüklenirken hata oluştu.';
      if (e is ServerException && e.message != null && e.message!.isNotEmpty) {
        errorMsg = e.message!;
      }
      if (isLoadMore) {
        emit(state.copyWith(isLoadingMoreHistory: false));
      } else {
        emit(state.copyWith(
          isLoadingHistory: false,
          isHistoryError: true,
          historyErrorMessage: errorMsg,
        ));
      }
    }
  }

  void _processFetchedHistory(List<ChatMessage> fetched,
      {required bool isLoadMore, required int fetchedPage}) {
    final existingMap = <String, ChatMessage>{};
    if (isLoadMore) {
      for (final m in state.rawHistoryMessages) {
        existingMap[m.id] = m;
      }
    }
    for (final m in fetched) {
      existingMap[m.id] = m; // Deduplicate by message id
    }

    final allRaw = existingMap.values.toList();

    // Group by conversationId
    final Map<String, List<ChatMessage>> grouped = {};
    for (final m in allRaw) {
      grouped.putIfAbsent(m.conversationId, () => []).add(m);
    }

    final List<ConversationGroup> conversationGroups = [];

    grouped.forEach((convId, rawMsgs) {
      // Sort messages ascending by createdAt for chat chronology
      rawMsgs.sort((a, b) {
        final dtA = DateTime.tryParse(a.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dtB = DateTime.tryParse(b.createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dtA.compareTo(dtB);
      });

      final uiMsgs = rawMsgs.map((m) {
        return UiChatMessage(
          id: m.id,
          clientMessageId: m.clientMessageId,
          conversationId: m.conversationId,
          role: m.role,
          content: m.content,
          emergency: m.emergency,
          sendStatus: MessageSendStatus.sent,
          createdAt: m.createdAt,
        );
      }).toList();

      final lastMsg = rawMsgs.last;
      final lastTime = DateTime.tryParse(lastMsg.createdAt) ?? DateTime.now();

      String? convPetId;
      for (final m in rawMsgs) {
        if (m.petId != null && m.petId!.isNotEmpty) {
          convPetId = m.petId;
          break;
        }
      }

      conversationGroups.add(ConversationGroup(
        conversationId: convId,
        petId: convPetId,
        messages: uiMsgs,
        lastMessagePreview: lastMsg.content,
        lastMessageTime: lastTime,
      ));
    });

    // Sort conversations descending by lastMessageTime (newest first)
    conversationGroups.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

    emit(state.copyWith(
      rawHistoryMessages: allRaw,
      conversations: conversationGroups,
      isLoadingHistory: false,
      isLoadingMoreHistory: false,
      isHistoryError: false,
      historyPage: fetchedPage,
      hasMoreHistory: fetched.length >= 50,
    ));
  }

  void selectConversation(ConversationGroup group) {
    emit(state.copyWith(
      activeConversationId: group.conversationId,
      activePetId: group.petId,
      messages: group.messages,
      clearErrorMessage: true,
    ));
  }

  void startNewConversation() {
    emit(state.copyWith(
      clearConversationId: true,
      messages: const [],
      clearErrorMessage: true,
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
