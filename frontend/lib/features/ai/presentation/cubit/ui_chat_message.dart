import 'package:equatable/equatable.dart';

enum MessageSendStatus { sending, sent, error }

class UiChatMessage extends Equatable {
  final String id;
  final String? clientMessageId;
  final String conversationId;
  final String role; // "user" | "model"
  final String content;
  final bool emergency;
  final String? disclaimer;
  final MessageSendStatus sendStatus;
  final String? errorMessage;
  final String createdAt;

  const UiChatMessage({
    required this.id,
    this.clientMessageId,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.emergency,
    this.disclaimer,
    required this.sendStatus,
    this.errorMessage,
    required this.createdAt,
  });

  UiChatMessage copyWith({
    String? id,
    String? clientMessageId,
    String? conversationId,
    String? role,
    String? content,
    bool? emergency,
    String? disclaimer,
    MessageSendStatus? sendStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? createdAt,
  }) {
    return UiChatMessage(
      id: id ?? this.id,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      emergency: emergency ?? this.emergency,
      disclaimer: disclaimer ?? this.disclaimer,
      sendStatus: sendStatus ?? this.sendStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientMessageId,
        conversationId,
        role,
        content,
        emergency,
        disclaimer,
        sendStatus,
        errorMessage,
        createdAt,
      ];
}
