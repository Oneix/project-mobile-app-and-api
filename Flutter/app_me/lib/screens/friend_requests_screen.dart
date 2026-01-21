import 'package:flutter/material.dart';
import '../services/friends_service.dart';
import '../models/friend_models.dart';
import '../utils/error_handler.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequestModel> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final requests = await FriendsService.getPendingRequests();
      setState(() {
        _requests = requests;
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

  Future<void> _acceptRequest(FriendRequestModel request) async {
    try {
      await FriendsService.acceptFriendRequest(request.id);
      ErrorHandler.showSuccess(context, 'vriendschapsverzoek geaccepteerd');
      _loadRequests();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    }
  }

  Future<void> _rejectRequest(FriendRequestModel request) async {
    try {
      await FriendsService.rejectFriendRequest(request.id);
      ErrorHandler.showSuccess(context, 'vriendschapsverzoek afgewezen');
      _loadRequests();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('vriendschapsverzoeken'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'geen verzoeken',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _buildRequestItem(request);
                    },
                  ),
                ),
    );
  }

  Widget _buildRequestItem(FriendRequestModel request) {
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
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF4A90E2),
            backgroundImage: request.senderProfilePictureUrl != null && request.senderProfilePictureUrl!.isNotEmpty
                ? NetworkImage(request.senderProfilePictureUrl!)
                : null,
            child: request.senderProfilePictureUrl == null || request.senderProfilePictureUrl!.isEmpty
                ? Text(
                    request.senderUsername[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.senderFullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${request.senderUsername}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _rejectRequest(request),
            icon: const Icon(Icons.close),
            color: const Color(0xFFEF4444),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _acceptRequest(request),
            icon: const Icon(Icons.check),
            color: const Color(0xFF10B981),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
