class GroupModel {
  final int id;
  final String name;
  final String? description;
  final String? groupPictureUrl;
  final int ownerId;
  final String ownerUsername;
  final List<GroupMemberModel> members;
  final GroupMessageModel? lastMessage;
  final int unreadCount;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.groupPictureUrl,
    required this.ownerId,
    required this.ownerUsername,
    required this.members,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      groupPictureUrl: json['groupPictureUrl'],
      ownerId: json['ownerId'],
      ownerUsername: json['ownerUsername'],
      members:
          (json['members'] as List<dynamic>?)
              ?.map((m) => GroupMemberModel.fromJson(m))
              .toList() ??
          [],
      lastMessage: json['lastMessage'] != null
          ? GroupMessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'groupPictureUrl': groupPictureUrl,
      'ownerId': ownerId,
      'ownerUsername': ownerUsername,
      'members': members.map((m) => m.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class GroupMemberModel {
  final int userId;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final bool isAdmin;
  final bool isOwner;
  final bool isOnline;
  final DateTime joinedAt;

  String get name {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  GroupMemberModel({
    required this.userId,
    required this.username,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    required this.isAdmin,
    required this.isOwner,
    required this.isOnline,
    required this.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePictureUrl: json['profilePictureUrl'],
      isAdmin: json['isAdmin'] ?? false,
      isOwner: json['isOwner'] ?? false,
      isOnline: json['isOnline'] ?? false,
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'isAdmin': isAdmin,
      'isOwner': isOwner,
      'isOnline': isOnline,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class GroupMessageModel {
  final int id;
  final int groupId;
  final int senderId;
  final String senderUsername;
  final String? senderProfilePictureUrl;
  final String content;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;

  GroupMessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderUsername,
    this.senderProfilePictureUrl,
    required this.content,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    this.deletedAt,
    required this.createdAt,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    return GroupMessageModel(
      id: json['id'],
      groupId: json['groupId'],
      senderId: json['senderId'],
      senderUsername: json['senderUsername'],
      senderProfilePictureUrl: json['senderProfilePictureUrl'],
      content: json['content'],
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.parse(json['editedAt'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderProfilePictureUrl': senderProfilePictureUrl,
      'content': content,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CreateGroupRequest {
  final String name;
  final String? description;
  final List<int> memberIds;

  CreateGroupRequest({
    required this.name,
    this.description,
    required this.memberIds,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description, 'memberIds': memberIds};
  }
}

class SendGroupMessageRequest {
  final String content;

  SendGroupMessageRequest({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
