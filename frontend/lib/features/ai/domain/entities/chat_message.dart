import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final String? clientMessageId;
  final String? replyToClientMessageId;
  final String ownerId;
  final String? petId;
  final String role; // "user" | "model"
  final String content;
  final bool emergency;
  final String? model;
  final String? promptVersion;
  final String createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    this.clientMessageId,
    this.replyToClientMessageId,
    required this.ownerId,
    this.petId,
    required this.role,
    required this.content,
    required this.emergency,
    this.model,
    this.promptVersion,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      clientMessageId: json['clientMessageId']?.toString(),
      replyToClientMessageId: json['replyToClientMessageId']?.toString(),
      ownerId: json['ownerId']?.toString() ?? '',
      petId: json['petId']?.toString(),
      role: json['role']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      emergency: json['emergency'] as bool? ?? false,
      model: json['model']?.toString(),
      promptVersion: json['promptVersion']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'clientMessageId': clientMessageId,
      'replyToClientMessageId': replyToClientMessageId,
      'ownerId': ownerId,
      'petId': petId,
      'role': role,
      'content': content,
      'emergency': emergency,
      'model': model,
      'promptVersion': promptVersion,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        clientMessageId,
        replyToClientMessageId,
        ownerId,
        petId,
        role,
        content,
        emergency,
        model,
        promptVersion,
        createdAt,
      ];
}
