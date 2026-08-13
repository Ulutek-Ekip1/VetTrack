import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message.dart';
import 'conversation_group.dart';
import 'ui_chat_message.dart';

class AiChatState extends Equatable {
  final List<UiChatMessage> messages;
  final bool isSending;
  final bool isLoadingHistory;
  final bool isHistoryError;
  final bool isPetAccessError;
  final String? historyErrorMessage;
  final int historyPage;
  final bool hasMoreHistory;
  final bool isLoadingMoreHistory;
  final List<ConversationGroup> conversations;
  final List<ChatMessage> rawHistoryMessages;
  final String? activeConversationId;
  final String? activePetId;
  final String? errorMessage;
  final int? statusCode;

  const AiChatState({
    this.messages = const [],
    this.isSending = false,
    this.isLoadingHistory = false,
    this.isHistoryError = false,
    this.isPetAccessError = false,
    this.historyErrorMessage,
    this.historyPage = 0,
    this.hasMoreHistory = true,
    this.isLoadingMoreHistory = false,
    this.conversations = const [],
    this.rawHistoryMessages = const [],
    this.activeConversationId,
    this.activePetId,
    this.errorMessage,
    this.statusCode,
  });

  AiChatState copyWith({
    List<UiChatMessage>? messages,
    bool? isSending,
    bool? isLoadingHistory,
    bool? isHistoryError,
    bool? isPetAccessError,
    String? historyErrorMessage,
    bool clearHistoryErrorMessage = false,
    int? historyPage,
    bool? hasMoreHistory,
    bool? isLoadingMoreHistory,
    List<ConversationGroup>? conversations,
    List<ChatMessage>? rawHistoryMessages,
    String? activeConversationId,
    bool clearConversationId = false,
    String? activePetId,
    bool clearPetId = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? statusCode,
    bool clearStatusCode = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isHistoryError: isHistoryError ?? this.isHistoryError,
      isPetAccessError: isPetAccessError ?? this.isPetAccessError,
      historyErrorMessage: clearHistoryErrorMessage
          ? null
          : (historyErrorMessage ?? this.historyErrorMessage),
      historyPage: historyPage ?? this.historyPage,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      isLoadingMoreHistory: isLoadingMoreHistory ?? this.isLoadingMoreHistory,
      conversations: conversations ?? this.conversations,
      rawHistoryMessages: rawHistoryMessages ?? this.rawHistoryMessages,
      activeConversationId: clearConversationId
          ? null
          : (activeConversationId ?? this.activeConversationId),
      activePetId: clearPetId ? null : (activePetId ?? this.activePetId),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      statusCode:
          clearStatusCode ? null : (statusCode ?? this.statusCode),
    );
  }

  @override
  List<Object?> get props => [
        messages,
        isSending,
        isLoadingHistory,
        isHistoryError,
        isPetAccessError,
        historyErrorMessage,
        historyPage,
        hasMoreHistory,
        isLoadingMoreHistory,
        conversations,
        rawHistoryMessages,
        activeConversationId,
        activePetId,
        errorMessage,
        statusCode,
      ];
}
