import 'user_model.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequest {
  final String id;
  final User fromUser;
  final User toUser;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.status,
    required this.createdAt,
  });

  FriendRequest copyWith({
    String? id,
    User? fromUser,
    User? toUser,
    FriendRequestStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}