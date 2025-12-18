class Friend {
  final String name;
  final FriendColor avatarColor;
  final bool isOnline;
  final FriendStatus status;

  const Friend({
    required this.name,
    required this.avatarColor,
    this.isOnline = false,
    required this.status,
  });
}

enum FriendStatus {
  friend,
  pendingRequest,
  sentRequest
}

enum FriendColor {
  blue(0xFF4A90E2),
  green(0xFF10B981),
  gray(0xFF6B7280),
  darkGray(0xFF2C2C2C);

  const FriendColor(this.value);
  final int value;
}