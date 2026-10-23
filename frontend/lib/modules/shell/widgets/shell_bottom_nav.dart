import 'package:flutter/material.dart';
import '../../../../core/animations/delight_financial_animations.dart';
import '../../../../core/localization/app_strings.dart';

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

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return BottomNavBubbleJump(
      icon: icon,
      isSelected: selectedIndex == index,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileIcon = isLoggedIn ? (isAdmin ? Icons.admin_panel_settings : Icons.person) : Icons.login;
    final profileOutlineIcon = isLoggedIn ? (isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline) : Icons.login_outlined;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06), width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
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
        selectedFontSize: 11.5,
        unselectedFontSize: 10.5,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.home_outlined, 0),
            activeIcon: _buildAnimatedIcon(Icons.home, 0),
            label: context.tr('nav_explore'),
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.assignment_outlined, 1),
            activeIcon: _buildAnimatedIcon(Icons.assignment, 1),
            label: context.tr('nav_demands'),
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(Icons.verified_user_outlined, 2),
            activeIcon: _buildAnimatedIcon(Icons.verified_user, 2),
            label: context.tr('nav_rules'),
          ),
          BottomNavigationBarItem(
            icon: _buildAnimatedIcon(profileOutlineIcon, 3),
            activeIcon: _buildAnimatedIcon(profileIcon, 3),
            label: isLoggedIn ? (isAdmin ? context.tr('nav_admin') : context.tr('nav_portal')) : context.tr('nav_login'),
          ),
        ],
      ),
    );
  }
}

