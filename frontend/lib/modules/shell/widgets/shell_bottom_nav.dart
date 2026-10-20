import 'package:flutter/material.dart';

class ShellBottomNav extends StatelessWidget {
  final int selectedIndex;
  final bool isLoggedIn;
  final bool isAdmin;
  final ValueChanged<int> onTabSelected;

  const ShellBottomNav({
    super.key,
    required this.selectedIndex,
    required this.isLoggedIn,
    required this.isAdmin,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTabSelected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0B4F32),
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'জমি খুঁজুন',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'চাহিদা',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'নিয়ম ও ফি',
          ),
          BottomNavigationBarItem(
            icon: Icon(isLoggedIn ? (isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline) : Icons.login_outlined),
            activeIcon: Icon(isLoggedIn ? (isAdmin ? Icons.admin_panel_settings : Icons.person) : Icons.login),
            label: isLoggedIn ? (isAdmin ? 'অ্যাডমিন' : 'পোর্টাল') : 'লগইন',
          ),
        ],
      ),
    );
  }
}
