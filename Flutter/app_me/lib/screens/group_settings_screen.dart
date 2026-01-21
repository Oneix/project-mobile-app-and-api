import 'package:flutter/material.dart';
import '../models/group_models.dart';
import '../models/friend_models.dart';
import '../services/groups_service.dart';
import '../services/friends_service.dart';
import '../services/user_service.dart';

class GroupSettingsScreen extends StatefulWidget {
  final int groupId;

  const GroupSettingsScreen({super.key, required this.groupId});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  GroupModel? _group;
  int? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await UserService.getProfile();
      final group = await GroupsService.getGroupDetails(widget.groupId);
      if (mounted) {
        setState(() {
          _currentUserId = profile.userId;
          _group = group;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading group: $e')));
      }
    }
  }

  bool get _isAdmin {
    if (_group == null || _currentUserId == null) return false;
    final member = _group!.members.firstWhere(
      (m) => m.userId == _currentUserId,
      orElse: () => _group!.members.first,
    );
    return member.isAdmin;
  }

  bool get _isOwner {
    return _group?.ownerId == _currentUserId;
  }

  Future<void> _renameGroup() async {
    final controller = TextEditingController(text: _group?.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Group'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty) {
      try {
        final updated = await GroupsService.updateGroup(
          widget.groupId,
          name: result.trim(),
        );
        if (mounted) {
          setState(() {
            _group = updated;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Group renamed')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error renaming group: $e')));
        }
      }
    }
  }

  Future<void> _addMember() async {
    try {
      final friends = await FriendsService.getFriends();
      final currentMemberIds = _group!.members.map((m) => m.userId).toSet();
      final availableFriends = friends
          .where((f) => !currentMemberIds.contains(f.userId))
          .toList();

      if (availableFriends.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All friends are already members')),
          );
        }
        return;
      }

      final selected = await showDialog<FriendModel>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Member'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableFriends.length,
              itemBuilder: (context, index) {
                final friend = availableFriends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: friend.profilePictureUrl != null
                        ? NetworkImage(friend.profilePictureUrl!)
                        : null,
                    child: friend.profilePictureUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(friend.fullName),
                  subtitle: Text('@${friend.username}'),
                  onTap: () => Navigator.pop(context, friend),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selected != null) {
        await GroupsService.addMember(widget.groupId, selected.userId);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${selected.fullName} added to group')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding member: $e')));
      }
    }
  }

  Future<void> _removeMember(GroupMemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove ${member.username} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GroupsService.removeMember(widget.groupId, member.userId);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.username} removed from group')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error removing member: $e')));
        }
      }
    }
  }

  Future<void> _leaveGroup() async {
    if (_isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Owner cannot leave. Transfer ownership or delete group first',
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && _currentUserId != null) {
      try {
        await GroupsService.removeMember(widget.groupId, _currentUserId!);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context); // Go back to groups tab
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error leaving group: $e')));
        }
      }
    }
  }

  Future<void> _deleteGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GroupsService.deleteGroup(widget.groupId);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context); // Go back to groups tab
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting group: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Group Settings',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _group == null
          ? const Center(child: Text('Group not found'))
          : ListView(
              children: [
                // Group info section
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4A90E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.group,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _group!.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_group!.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _group!.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${_group!.members.length} ${_group!.members.length == 1 ? 'member' : 'members'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Group actions
                if (_isAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Rename Group'),
                    onTap: _renameGroup,
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Add Member'),
                    onTap: _addMember,
                  ),
                  const Divider(),
                ],

                // Members section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Members',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                ..._group!.members.map((member) {
                  final isCurrentUser = member.userId == _currentUserId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member.profilePictureUrl != null
                          ? NetworkImage(member.profilePictureUrl!)
                          : null,
                      child: member.profilePictureUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.username + (isCurrentUser ? ' (You)' : ''),
                          ),
                        ),
                        if (member.isOwner)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCD34D),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Owner',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (member.isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF60A5FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: member.isOnline
                        ? const Text(
                            'Online',
                            style: TextStyle(color: Color(0xFF10B981)),
                          )
                        : null,
                    trailing: _isAdmin && !member.isOwner
                        ? IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeMember(member),
                          )
                        : null,
                  );
                }),
                const Divider(),

                // Danger zone
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.orange),
                  title: const Text(
                    'Leave Group',
                    style: TextStyle(color: Colors.orange),
                  ),
                  onTap: _leaveGroup,
                ),
                if (_isOwner)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete Group',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _deleteGroup,
                  ),
              ],
            ),
    );
  }
}
