enum MessageType { user, bot }

class ChatMessage {
  final String text;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.type,
  });

  bool get isUser => type == MessageType.user;
  bool get isBot => type == MessageType.bot;

  // Format the timestamp for display
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
