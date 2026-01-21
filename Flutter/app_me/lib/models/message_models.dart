class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final bool isRead;
  final DateTime? readAt;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    this.readAt,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      isRead: json['isRead'],
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      isEdited: json['isEdited'],
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      isDeleted: json['isDeleted'],
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ChatConversationModel {
  final int userId;
  final String name;
  final String? profilePictureUrl;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final MessageModel? lastMessage;
  final int unreadCount;

  ChatConversationModel({
    required this.userId,
    required this.name,
    this.profilePictureUrl,
    required this.isOnline,
    this.lastSeenAt,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      userId: json['userId'],
      name: json['name'],
      profilePictureUrl: json['profilePictureUrl'],
      isOnline: json['isOnline'],
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt']) : null,
      lastMessage: json['lastMessage'] != null 
          ? MessageModel.fromJson(json['lastMessage']) 
          : null,
      unreadCount: json['unreadCount'],
    );
  }
}

class SendMessageRequest {
  final int receiverId;
  final String content;

  SendMessageRequest({
    required this.receiverId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'content': content,
    };
  }
}

class EditMessageRequest {
  final String content;

  EditMessageRequest({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}
