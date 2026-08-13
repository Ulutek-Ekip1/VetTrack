import 'package:equatable/equatable.dart';
import 'ui_chat_message.dart';

class ConversationGroup extends Equatable {
  final String conversationId;
  final String? petId;
  final List<UiChatMessage> messages;
  final String lastMessagePreview;
  final DateTime lastMessageTime;

  const ConversationGroup({
    required this.conversationId,
    this.petId,
    required this.messages,
    required this.lastMessagePreview,
    required this.lastMessageTime,
  });

  @override
  List<Object?> get props => [
        conversationId,
        petId,
        messages,
        lastMessagePreview,
        lastMessageTime,
      ];
}
