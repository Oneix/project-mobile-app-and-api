class FriendModel {
  final int friendshipId;
  final int userId;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime friendsSince;

  FriendModel({
    required this.friendshipId,
    required this.userId,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    required this.isOnline,
    this.lastSeenAt,
    required this.friendsSince,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      friendshipId: json['friendshipId'] as int,
      userId: json['userId'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isOnline: json['isOnline'] as bool,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      friendsSince: DateTime.parse(json['friendsSince'] as String),
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
}

class FriendRequestModel {
  final int id;
  final int senderId;
  final String senderUsername;
  final String? senderFirstName;
  final String? senderLastName;
  final String? senderProfilePictureUrl;
  final int receiverId;
  final String receiverUsername;
  final String status;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    this.senderFirstName,
    this.senderLastName,
    this.senderProfilePictureUrl,
    required this.receiverId,
    required this.receiverUsername,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      senderUsername: json['senderUsername'] as String,
      senderFirstName: json['senderFirstName'] as String?,
      senderLastName: json['senderLastName'] as String?,
      senderProfilePictureUrl: json['senderProfilePictureUrl'] as String?,
      receiverId: json['receiverId'] as int,
      receiverUsername: json['receiverUsername'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get senderFullName {
    if (senderFirstName != null && senderLastName != null) {
      return '$senderFirstName $senderLastName';
    } else if (senderFirstName != null) {
      return senderFirstName!;
    } else if (senderLastName != null) {
      return senderLastName!;
    }
    return senderUsername;
  }
}

class UserSearchResult {
  final int userId;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final bool isOnline;
  final bool isFriend;
  final bool hasPendingRequest;

  UserSearchResult({
    required this.userId,
    required this.username,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    required this.isOnline,
    required this.isFriend,
    required this.hasPendingRequest,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['userId'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isOnline: json['isOnline'] as bool,
      isFriend: json['isFriend'] as bool,
      hasPendingRequest: json['hasPendingRequest'] as bool,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
}
