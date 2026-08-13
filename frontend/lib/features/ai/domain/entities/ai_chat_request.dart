import 'package:equatable/equatable.dart';

class AiChatRequest extends Equatable {
  final String? conversationId;
  final String clientMessageId;
  final String? petId;
  final String message;

  const AiChatRequest({
    this.conversationId,
    required this.clientMessageId,
    this.petId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'clientMessageId': clientMessageId,
      'message': message,
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
      ];
}
