import 'package:equatable/equatable.dart';
import 'ui_chat_message.dart';

class AiChatState extends Equatable {
  final List<UiChatMessage> messages;
  final bool isSending;
  final bool isLoadingHistory;
  final String? activeConversationId;
  final String? activePetId;
  final String? errorMessage;
  final int? statusCode;

  const AiChatState({
    this.messages = const [],
    this.isSending = false,
    this.isLoadingHistory = false,
    this.activeConversationId,
    this.activePetId,
    this.errorMessage,
    this.statusCode,
  });

  AiChatState copyWith({
    List<UiChatMessage>? messages,
    bool? isSending,
    bool? isLoadingHistory,
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
        activeConversationId,
        activePetId,
        errorMessage,
        statusCode,
      ];
}
