
import 'package:flutter/material.dart';
import '../widgets/custom_widgets.dart';
import '../services/signalr_service.dart';
import 'chats_tab.dart';
import 'friends_tab.dart';
import 'groups_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final SignalRService _signalR = SignalRService();

  @override
  void initState() {
    super.initState();
    _initializeSignalR();
  }

  Future<void> _initializeSignalR() async {
    try {
      await _signalR.connect();
      print('SignalR connected in HomeScreen');
    } catch (e) {
      print('Error connecting to SignalR in HomeScreen: $e');
    }
  }

  @override
  void dispose() {
    _signalR.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Custom App Bar
          CustomAppBar(
            onProfileTap: () {
              setState(() {
                _selectedIndex = 3; // Navigate to Profile tab
              });
            },
          ),
          // Tab Content
          Expanded(child: _getSelectedTabContent()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _getSelectedTabContent() {
    switch (_selectedIndex) {
      case 0:
        return const ChatsTab();
      case 1:
        return const FriendsTab();
      case 2:
        return const GroupsTab();
      case 3:
        return const ProfileTab();
      default:
        return const ChatsTab();
    }
  }
}
