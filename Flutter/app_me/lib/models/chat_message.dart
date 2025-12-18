class ChatMessage {
  final String name;
  final String message;
  final String time;
  final int? unreadCount;
  final ChatMessageColor avatarColor;
  final bool isOnline;
  final bool isGroup;
  final bool isSentByMe;

  const ChatMessage({
    required this.name,
    required this.message,
    required this.time,
    this.unreadCount,
    required this.avatarColor,
    this.isOnline = false,
    this.isGroup = false,
    this.isSentByMe = false,
  });
}

enum ChatMessageColor {
  blue(0xFF4A90E2),
  green(0xFF10B981),
  gray(0xFF6B7280),
  darkGray(0xFF2C2C2C);

  const ChatMessageColor(this.value);
  final int value;
}