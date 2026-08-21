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
  final int? errorCode;
  final String? errorType;
  final String createdAt;

  // Parsed content without QUICK_REPLY tag
  String get displayContent {
    final quickReplyRegex = RegExp(r'\[QUICK_REPLY:(.*?)\]');
    return content.replaceAll(quickReplyRegex, '').trim();
  }

  // Parsed quick replies list
  List<String> get quickReplies {
    final quickReplyRegex = RegExp(r'\[QUICK_REPLY:(.*?)\]');
    final match = quickReplyRegex.firstMatch(content);
    if (match != null && match.groupCount >= 1) {
      final optionsStr = match.group(1);
      if (optionsStr != null) {
        return optionsStr.split('|').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return [];
  }

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
    this.errorCode,
    this.errorType,
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
    int? errorCode,
    bool clearErrorCode = false,
    String? errorType,
    bool clearErrorType = false,
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
      errorCode: clearErrorCode ? null : (errorCode ?? this.errorCode),
      errorType: clearErrorType ? null : (errorType ?? this.errorType),
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
        errorCode,
        errorType,
        createdAt,
      ];
}
