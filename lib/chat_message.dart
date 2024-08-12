class ChatMessage {
  final String role;
  final List<ChatPart> parts;

  ChatMessage({required this.role, required this.parts});

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'parts': parts.map((part) => part.toJson()).toList(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    var partsList = json['parts'] as List;
    List<ChatPart> parts = partsList.map((i) => ChatPart.fromJson(i)).toList();

    return ChatMessage(
      role: json['role'],
      parts: parts,
    );
  }
}

class ChatPart {
  final String text;

  ChatPart({required this.text});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }

  factory ChatPart.fromJson(Map<String, dynamic> json) {
    return ChatPart(
      text: json['text'],
    );
  }
}
