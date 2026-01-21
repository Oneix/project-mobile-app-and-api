import 'package:signalr_netcore/signalr_client.dart';
import '../utils/token_storage.dart';
import '../models/group_models.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // Callbacks for 1-on-1 chat events
  Function(int userId, bool isOnline)? onUserStatusChanged;
  Function(Map<String, dynamic> message)? onMessageReceived;
  Function(int messageId)? onMessageRead;
  Function(int messageId, String newContent)? onMessageEdited;
  Function(int messageId)? onMessageDeleted;
  Function(int userId)? onUserTyping;
  Function(int userId)? onUserStoppedTyping;

  // Callbacks for group events
  Function(GroupMessageModel message)? onGroupMessageReceived;
  Function(GroupMessageModel message)? onGroupMessageEdited;
  Function(GroupMessageModel message)? onGroupMessageDeleted;
  Function(GroupModel group)? onGroupCreated;
  Function(GroupModel group)? onGroupUpdated;
  Function(int groupId)? onGroupDeleted;
  Function(int groupId, GroupMemberModel member)? onGroupMemberAdded;
  Function(int groupId, int userId)? onGroupMemberRemoved;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await TokenStorage.getToken();
      if (token == null) {
        print('No token available for SignalR connection');
        return;
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            'http://localhost:5009/chathub',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Register event handlers for 1-on-1 chat
      _hubConnection!.on('UserOnline', _handleUserOnline);
      _hubConnection!.on('UserOffline', _handleUserOffline);
      _hubConnection!.on('ReceiveMessage', _handleReceiveMessage);
      _hubConnection!.on('MessageRead', _handleMessageRead);
      _hubConnection!.on('MessageEdited', _handleMessageEdited);
      _hubConnection!.on('MessageDeleted', _handleMessageDeleted);
      _hubConnection!.on('UserTyping', _handleUserTyping);
      _hubConnection!.on('UserStoppedTyping', _handleUserStoppedTyping);

      // Register event handlers for group chat
      _hubConnection!.on('ReceiveGroupMessage', _handleReceiveGroupMessage);
      _hubConnection!.on('GroupMessageEdited', _handleGroupMessageEdited);
      _hubConnection!.on('GroupMessageDeleted', _handleGroupMessageDeleted);
      _hubConnection!.on('GroupCreated', _handleGroupCreated);
      _hubConnection!.on('GroupUpdated', _handleGroupUpdated);
      _hubConnection!.on('GroupDeleted', _handleGroupDeleted);
      _hubConnection!.on('GroupMemberAdded', _handleGroupMemberAdded);
      _hubConnection!.on('GroupMemberRemoved', _handleGroupMemberRemoved);

      // Register event handlers for groups
      _hubConnection!.on('ReceiveGroupMessage', _handleReceiveGroupMessage);
      _hubConnection!.on('GroupCreated', _handleGroupCreated);
      _hubConnection!.on('GroupUpdated', _handleGroupUpdated);
      _hubConnection!.on('GroupDeleted', _handleGroupDeleted);
      _hubConnection!.on('GroupMemberAdded', _handleGroupMemberAdded);
      _hubConnection!.on('GroupMemberRemoved', _handleGroupMemberRemoved);

      _hubConnection!.onclose(({Exception? error}) {
        print('SignalR connection closed: $error');
        _isConnected = false;
      });

      _hubConnection!.onreconnecting(({Exception? error}) {
        print('SignalR reconnecting: $error');
      });

      _hubConnection!.onreconnected(({String? connectionId}) {
        print('SignalR reconnected: $connectionId');
        _isConnected = true;
      });

      await _hubConnection!.start();
      _isConnected = true;
      print('SignalR connected successfully');
    } catch (e) {
      print('Error connecting to SignalR: $e');
      _isConnected = false;
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _isConnected = false;
      print('SignalR disconnected');
    }
  }

  Future<void> sendMessage(int receiverId, String content) async {
    if (!_isConnected || _hubConnection == null) {
      throw Exception('SignalR not connected');
    }

    try {
      await _hubConnection!.invoke('SendMessage', args: [receiverId, content]);
    } catch (e) {
      print('Error sending message via SignalR: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(int messageId) async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection!.invoke('MarkAsRead', args: [messageId]);
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<void> sendTyping(int receiverId) async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection!.invoke('Typing', args: [receiverId]);
    } catch (e) {
      print('Error sending typing indicator: $e');
    }
  }

  Future<void> sendStopTyping(int receiverId) async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection!.invoke('StopTyping', args: [receiverId]);
    } catch (e) {
      print('Error sending stop typing indicator: $e');
    }
  }

  // Event handlers
  void _handleUserOnline(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final userId = args[0] as int;
      onUserStatusChanged?.call(userId, true);
    }
  }

  void _handleUserOffline(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final userId = args[0] as int;
      onUserStatusChanged?.call(userId, false);
    }
  }

  void _handleReceiveMessage(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final messageJson = args[0] as Map<String, dynamic>;
      onMessageReceived?.call(messageJson);
    }
  }

  void _handleMessageRead(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final messageId = args[0] as int;
      onMessageRead?.call(messageId);
    }
  }

  void _handleMessageEdited(List<Object?>? args) {
    if (args != null && args.length >= 2) {
      final messageId = args[0] as int;
      final newContent = args[1] as String;
      onMessageEdited?.call(messageId, newContent);
    }
  }

  void _handleMessageDeleted(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final messageId = args[0] as int;
      onMessageDeleted?.call(messageId);
    }
  }

  void _handleUserTyping(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final userId = args[0] as int;
      onUserTyping?.call(userId);
    }
  }

  void _handleUserStoppedTyping(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final userId = args[0] as int;
      onUserStoppedTyping?.call(userId);
    }
  }

  // Group event handlers
  void _handleReceiveGroupMessage(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final messageJson = args[0] as Map<String, dynamic>;
      final message = GroupMessageModel.fromJson(messageJson);
      onGroupMessageReceived?.call(message);
    }
  }

  void _handleGroupMessageEdited(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final messageJson = args[0] as Map<String, dynamic>;
      final message = GroupMessageModel.fromJson(messageJson);
      onGroupMessageEdited?.call(message);
    }
  }

  void _handleGroupMessageDeleted(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final messageJson = args[0] as Map<String, dynamic>;
      final message = GroupMessageModel.fromJson(messageJson);
      onGroupMessageDeleted?.call(message);
    }
  }

  void _handleGroupCreated(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final groupJson = args[0] as Map<String, dynamic>;
      final group = GroupModel.fromJson(groupJson);
      onGroupCreated?.call(group);
    }
  }

  void _handleGroupUpdated(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final groupJson = args[0] as Map<String, dynamic>;
      final group = GroupModel.fromJson(groupJson);
      onGroupUpdated?.call(group);
    }
  }

  void _handleGroupDeleted(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final groupId = args[0] as int;
      onGroupDeleted?.call(groupId);
    }
  }

  void _handleGroupMemberAdded(List<Object?>? args) {
    if (args != null && args.length >= 2) {
      final groupId = args[0] as int;
      final memberJson = args[1] as Map<String, dynamic>;
      final member = GroupMemberModel.fromJson(memberJson);
      onGroupMemberAdded?.call(groupId, member);
    }
  }

  void _handleGroupMemberRemoved(List<Object?>? args) {
    if (args != null && args.length >= 2) {
      final groupId = args[0] as int;
      final userId = args[1] as int;
      onGroupMemberRemoved?.call(groupId, userId);
    }
  }

  void dispose() {
    disconnect();
    onUserStatusChanged = null;
    onMessageReceived = null;
    onMessageRead = null;
    onMessageEdited = null;
    onMessageDeleted = null;
    onUserTyping = null;
    onUserStoppedTyping = null;
    onGroupMessageReceived = null;
    onGroupMessageEdited = null;
    onGroupMessageDeleted = null;
    onGroupCreated = null;
    onGroupUpdated = null;
    onGroupDeleted = null;
    onGroupMemberAdded = null;
    onGroupMemberRemoved = null;
  }
}
