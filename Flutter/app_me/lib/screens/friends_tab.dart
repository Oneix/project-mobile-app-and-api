import 'package:flutter/material.dart';
import '../services/friends_service.dart';
import '../models/friend_models.dart';
import '../utils/error_handler.dart';
import 'friend_requests_screen.dart';
import 'add_friend_screen.dart';
import 'chat_detail_screen.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  List<FriendModel> _friends = [];
  int _pendingRequestsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadPendingRequestsCount();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final friends = await FriendsService.getFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ErrorHandler.showError(context, e.toString());
      }
    }
  }

  Future<void> _loadPendingRequestsCount() async {
    try {
      final requests = await FriendsService.getPendingRequests();
      setState(() {
        _pendingRequestsCount = requests.length;
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _unfriend(FriendModel friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('vriend verwijderen'),
        content: Text('weet je zeker dat je ${friend.fullName} wilt verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('annuleren'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('verwijderen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FriendsService.unfriend(friend.friendshipId);
        ErrorHandler.showSuccess(context, 'vriend verwijderd');
        _loadFriends();
      } catch (e) {
        if (mounted) {
          ErrorHandler.showError(context, e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Friend and Requests Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddFriendScreen()),
                    );
                    _loadFriends();
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('vrienden zoeken'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Stack(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FriendRequestsScreen()),
                      );
                      _loadFriends();
                      _loadPendingRequestsCount();
                    },
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('verzoeken'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4A90E2),
                      side: const BorderSide(color: Color(0xFF4A90E2)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_pendingRequestsCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _pendingRequestsCount > 9 ? '9+' : '$_pendingRequestsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Friends List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _friends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'nog geen vrienden',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'zoek vrienden om toe te voegen',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFriends,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _friends.length,
                        itemBuilder: (context, index) {
                          final friend = _friends[index];
                          return _buildFriendItem(friend);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFriendItem(FriendModel friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4A90E2),
                backgroundImage: friend.profilePictureUrl != null && friend.profilePictureUrl!.isNotEmpty
                    ? NetworkImage(friend.profilePictureUrl!)
                    : null,
                child: friend.profilePictureUrl == null || friend.profilePictureUrl!.isEmpty
                    ? Text(
                        friend.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (friend.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  friend.isOnline ? 'online' : 'offline',
                  style: TextStyle(
                    fontSize: 14,
                    color: friend.isOnline ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onSelected: (value) {
              if (value == 'message') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      name: friend.fullName,
                      avatarColor: const Color(0xFF4A90E2),
                      isOnline: friend.isOnline,
                      isGroup: false,
                    ),
                  ),
                );
              } else if (value == 'unfriend') {
                _unfriend(friend);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'message',
                child: Row(
                  children: [
                    Icon(Icons.message, size: 20),
                    SizedBox(width: 12),
                    Text('bericht sturen'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unfriend',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, color: Color(0xFFEF4444), size: 20),
                    SizedBox(width: 12),
                    Text('vriend verwijderen', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
