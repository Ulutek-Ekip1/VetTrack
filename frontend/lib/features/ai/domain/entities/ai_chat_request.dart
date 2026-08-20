import 'package:equatable/equatable.dart';

class AiChatRequest extends Equatable {
  final String? conversationId;
  final String clientMessageId;
  final String? petId;
  final String message;
  final bool aiConsentGiven;

  const AiChatRequest({
    this.conversationId,
    required this.clientMessageId,
    this.petId,
    required this.message,
    this.aiConsentGiven = true,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'clientMessageId': clientMessageId,
      'message': message,
      'aiConsentGiven': aiConsentGiven,
    };
    if (conversationId != null && conversationId!.isNotEmpty) {
      data['conversationId'] = conversationId;
    }
    if (petId != null && petId!.isNotEmpty) {
      data['petId'] = petId;
    }
    // NOT: history alanı backend isteği gereğince eklenmemiştir.
    return data;
  }

  @override
  List<Object?> get props => [
        conversationId,
        clientMessageId,
        petId,
        message,
        aiConsentGiven,
      ];
}
