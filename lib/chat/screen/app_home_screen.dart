import 'package:flutter/material.dart';
import 'package:mivo/chat/screen/chat_list_screen.dart';
import 'package:mivo/chat/screen/profile_screen.dart';
import 'package:mivo/chat/screen/user_list_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {

  int _currentIndex = 0;
 // bool _hasInitialized = false;

  //screen for each tab
  final List<Widget> _screens = [
    ChatListScreen(),
    UserListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          unselectedFontSize: 14,
          onTap: (index){
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ]),
    );
  }
}
