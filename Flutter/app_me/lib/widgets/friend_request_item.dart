import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendRequestItem extends StatelessWidget {
  final Friend friend;
  final bool showButtons;
  final bool showAcceptReject;
  final VoidCallback? onRemove;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const FriendRequestItem({
    super.key,
    required this.friend,
    this.showButtons = false,
    this.showAcceptReject = false,
    this.onRemove,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Color(friend.avatarColor.value),
                child: Text(
                  friend.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              if (friend.isOnline)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 14,
                    color: friend.isOnline ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          if (showButtons)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          if (showAcceptReject) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onReject,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onAccept,
                icon: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }
}