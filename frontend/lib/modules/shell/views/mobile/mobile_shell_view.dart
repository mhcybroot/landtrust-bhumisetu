import 'package:flutter/material.dart';
import '../../../../core/animations/animated_fade_switcher.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/language_toggle_button.dart';
import '../../view_models/shell_view_model.dart';
import '../../widgets/shell_bottom_nav.dart';
import '../../widgets/shell_drawer.dart';

class MobileShellView extends StatelessWidget {
  final ShellViewModel shellVm;
  final Widget activeView;

  const MobileShellView({
    super.key,
    required this.shellVm,
    required this.activeView,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTab = shellVm.selectedTabIndex;
    final isLoggedIn = shellVm.isLoggedIn;
    final isAdmin = shellVm.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4F32),
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.terrain, color: Color(0xFF0B4F32), size: 20),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('app_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  context.tr('app_subtitle'),
                  style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const LanguageToggleButton(),
          if (!isLoggedIn)
            TextButton(
              onPressed: () => shellVm.setTabIndex(3),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(context.tr('nav_login'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
          else
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 24),
              tooltip: 'আমার পোর্টাল',
              onPressed: () => shellVm.setTabIndex(3),
            ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
              tooltip: 'মেনু',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: ShellDrawer(
        selectedIndex: selectedTab,
        isLoggedIn: isLoggedIn,
        isAdmin: isAdmin,
        user: shellVm.currentUser,
        onTabSelected: shellVm.setTabIndex,
        onLogout: shellVm.logout,
      ),
      body: AnimatedFadeSwitcher(
        child: KeyedSubtree(
          key: ValueKey(selectedTab),
          child: activeView,
        ),
      ),
      bottomNavigationBar: ShellBottomNav(
        selectedIndex: selectedTab,
        isLoggedIn: isLoggedIn,
        isAdmin: isAdmin,
        onTabSelected: shellVm.setTabIndex,
      ),
    );
  }
}

