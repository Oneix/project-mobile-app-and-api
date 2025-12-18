import 'user_model.dart';

enum MessageType { text, image, file }

class Message {
  final String id;
  final String content;
  final MessageType type;
  final String senderId;
  final DateTime timestamp;
  final bool isRead;

  const Message({
    required this.id,
    required this.content,
    required this.type,
    required this.senderId,
    required this.timestamp,
    this.isRead = false,
  });

  Message copyWith({
    String? id,
    String? content,
    MessageType? type,
    String? senderId,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Chat {
  final String id;
  final String name;
  final String? profileImageUrl;
  final Message? lastMessage;
  final int unreadCount;
  final bool isGroup;
  final List<User> participants;

  const Chat({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.lastMessage,
    this.unreadCount = 0,
    this.isGroup = false,
    this.participants = const [],
  });

  Chat copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    Message? lastMessage,
    int? unreadCount,
    bool? isGroup,
    List<User>? participants,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      participants: participants ?? this.participants,
    );
  }
}