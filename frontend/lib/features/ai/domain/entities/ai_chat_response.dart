import 'package:equatable/equatable.dart';

class AiChatResponse extends Equatable {
  final String messageId;
  final String conversationId;
  final bool emergency;
  final String reply;
  final String disclaimer;
  final String model;
  final String promptVersion;
  final String createdAt;

  const AiChatResponse({
    required this.messageId,
    required this.conversationId,
    required this.emergency,
    required this.reply,
    required this.disclaimer,
    required this.model,
    required this.promptVersion,
    required this.createdAt,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      messageId: json['messageId']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      emergency: json['emergency'] as bool? ?? false,
      reply: json['reply']?.toString() ?? '',
      disclaimer: json['disclaimer']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      promptVersion: json['promptVersion']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'emergency': emergency,
      'reply': reply,
      'disclaimer': disclaimer,
      'model': model,
      'promptVersion': promptVersion,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        messageId,
        conversationId,
        emergency,
        reply,
        disclaimer,
        model,
        promptVersion,
        createdAt,
      ];
}
