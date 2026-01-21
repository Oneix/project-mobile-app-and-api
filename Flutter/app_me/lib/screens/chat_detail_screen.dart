import 'package:flutter/material.dart';
import 'dart:async';
import '../models/message_models.dart';
import '../services/messages_service.dart';
import '../services/signalr_service.dart';
import '../utils/token_storage.dart';

class ChatDetailScreen extends StatefulWidget {
  final int userId;
  final String name;
  final Color avatarColor;
  final bool isOnline;
  final bool isGroup;
  final String? profilePictureUrl;

  const ChatDetailScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.avatarColor,
    this.isOnline = false,
    this.isGroup = false,
    this.profilePictureUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isUserOnline = false;
  int? _currentUserId;
  final SignalRService _signalR = SignalRService();
  Timer? _typingTimer;
  bool _isSendingTyping = false;

  @override
  void initState() {
    super.initState();
    _isUserOnline = widget.isOnline;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _getCurrentUserId();
    await _loadMessages();
    await _markMessagesAsRead();
    _setupSignalR();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _getCurrentUserId() async {
    // Extract current user ID from token
    final token = await TokenStorage.getToken();
    if (token != null) {
      // Decode JWT to get user ID - for simplicity, store it in token storage
      // or get from a user service
      // For now, we'll use the senderId from first sent message
      _currentUserId = 0; // Will be set when we load messages
    }
  }

  void _setupSignalR() {
    // Listen for new messages
    _signalR.onMessageReceived = (messageJson) {
      final message = MessageModel.fromJson(messageJson);
      if (message.senderId == widget.userId || message.receiverId == widget.userId) {
        setState(() {
          // Check if message already exists (avoid duplicates)
          if (!_messages.any((m) => m.id == message.id)) {
            _messages.add(message);
          }
        });
        _scrollToBottom();
        
        // Mark as read if message is from the other user
        if (message.senderId == widget.userId) {
          MessagesService.markMessagesAsRead(widget.userId);
        }
      }
    };

    // Listen for message edits
    _signalR.onMessageEdited = (messageId, newContent) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = MessageModel(
            id: _messages[index].id,
            senderId: _messages[index].senderId,
            receiverId: _messages[index].receiverId,
            content: newContent,
            isRead: _messages[index].isRead,
            readAt: _messages[index].readAt,
            isEdited: true,
            editedAt: DateTime.now(),
            isDeleted: _messages[index].isDeleted,
            deletedAt: _messages[index].deletedAt,
            createdAt: _messages[index].createdAt,
            updatedAt: DateTime.now(),
          );
        }
      });
    };

    // Listen for message deletes
    _signalR.onMessageDeleted = (messageId) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          _messages[index] = MessageModel(
            id: _messages[index].id,
            senderId: _messages[index].senderId,
            receiverId: _messages[index].receiverId,
            content: '[message deleted]',
            isRead: _messages[index].isRead,
            readAt: _messages[index].readAt,
            isEdited: _messages[index].isEdited,
            editedAt: _messages[index].editedAt,
            isDeleted: true,
            deletedAt: DateTime.now(),
            createdAt: _messages[index].createdAt,
            updatedAt: DateTime.now(),
          );
        }
      });
    };

    // Listen for online/offline status
    _signalR.onUserStatusChanged = (userId, isOnline) {
      if (userId == widget.userId) {
        setState(() {
          _isUserOnline = isOnline;
        });
      }
    };
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await MessagesService.getMessageHistory(widget.userId);
      if (mounted) {
        setState(() {
          _messages = messages; // Backend already returns oldest first
          _isLoading = false;
        });
        
        // Set current user ID from messages
        if (_messages.isNotEmpty) {
          final firstSentMessage = _messages.firstWhere(
            (m) => _messages.any((msg) => msg.senderId != widget.userId),
            orElse: () => _messages.first,
          );
          if (firstSentMessage.senderId != widget.userId) {
            _currentUserId = firstSentMessage.senderId;
          } else {
            _currentUserId = firstSentMessage.receiverId;
          }
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await MessagesService.markMessagesAsRead(widget.userId);
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text;
    _messageController.clear();
    
    // Stop typing indicator
    if (_isSendingTyping) {
      _signalR.sendStopTyping(widget.userId);
      _isSendingTyping = false;
    }

    try {
      final request = SendMessageRequest(
        receiverId: widget.userId,
        content: content,
      );
      
      final message = await MessagesService.sendMessage(request);
      
      setState(() {
        _messages.add(message);
        _currentUserId = message.senderId;
      });
      
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _onTyping() {
    // Cancel previous timer
    _typingTimer?.cancel();
    
    // Send typing indicator if not already sending
    if (!_isSendingTyping) {
      _signalR.sendTyping(widget.userId);
      _isSendingTyping = true;
    }
    
    // Set timer to stop typing after 2 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isSendingTyping) {
        _signalR.sendStopTyping(widget.userId);
        _isSendingTyping = false;
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showMessageOptions(MessageModel message) {
    // Only show options for messages sent by current user
    if (message.senderId != _currentUserId) return;
    if (message.isDeleted) return;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Bewerken'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Verwijderen', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editMessage(MessageModel message) async {
    final controller = TextEditingController(text: message.content);
    
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bericht bewerken'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Typ je bericht...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty && result != message.content) {
      try {
        final request = EditMessageRequest(content: result.trim());
        await MessagesService.editMessage(message.id, request);
        
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = MessageModel(
              id: message.id,
              senderId: message.senderId,
              receiverId: message.receiverId,
              content: result.trim(),
              isRead: message.isRead,
              readAt: message.readAt,
              isEdited: true,
              editedAt: DateTime.now(),
              isDeleted: message.isDeleted,
              deletedAt: message.deletedAt,
              createdAt: message.createdAt,
              updatedAt: DateTime.now(),
            );
          }
        });
      } catch (e) {
        print('Error editing message: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to edit message: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteMessage(MessageModel message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bericht verwijderen'),
          content: const Text('Weet je zeker dat je dit bericht wilt verwijderen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await MessagesService.deleteMessage(message.id);
        
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = MessageModel(
              id: message.id,
              senderId: message.senderId,
              receiverId: message.receiverId,
              content: '[message deleted]',
              isRead: message.isRead,
              readAt: message.readAt,
              isEdited: message.isEdited,
              editedAt: message.editedAt,
              isDeleted: true,
              deletedAt: DateTime.now(),
              createdAt: message.createdAt,
              updatedAt: DateTime.now(),
            );
          }
        });
      } catch (e) {
        print('Error deleting message: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete message: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    if (_isSendingTyping) {
      _signalR.sendStopTyping(widget.userId);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                widget.profilePictureUrl != null
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(widget.profilePictureUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.avatarColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                if (_isUserOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _isUserOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: _isUserOnline ? const Color(0xFF10B981) : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.isGroup)
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {},
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Geen berichten',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start het gesprek!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSentByMe = message.senderId == _currentUserId;
                          return _buildMessageBubble(message, isSentByMe);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isSentByMe) {
    return GestureDetector(
      onLongPress: () => _showMessageOptions(message),
      child: Align(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: isSentByMe ? const Color(0xFF4A90E2) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
              bottomRight: Radius.circular(isSentByMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: message.isDeleted
                      ? (isSentByMe ? Colors.white70 : Colors.grey)
                      : (isSentByMe ? Colors.white : Colors.black),
                  fontSize: 15,
                  fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      color: isSentByMe ? Colors.white70 : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                  if (message.isEdited && !message.isDeleted) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(bewerkt)',
                      style: TextStyle(
                        color: isSentByMe ? Colors.white70 : Colors.grey,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (isSentByMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                onChanged: (value) => _onTyping(),
                decoration: const InputDecoration(
                  hintText: 'Typ een bericht...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
