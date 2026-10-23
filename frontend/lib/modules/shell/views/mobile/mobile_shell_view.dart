import 'package:flutter/material.dart';
import '../../../../core/animations/animated_fade_switcher.dart';
import '../../../../core/animations/bouncing_pressable.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/language_toggle_button.dart';
import '../../view_models/shell_view_model.dart';
import '../../widgets/shell_bottom_nav.dart';
import '../../widgets/shell_drawer.dart';

class MobileShellView extends StatelessWidget {
  final ShellViewModel shellVm;
  final Widget activeView;
  final Map<String, dynamic>? config;

  const MobileShellView({
    super.key,
    required this.shellVm,
    required this.activeView,
    this.config,
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
        titleSpacing: 10,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.terrain, color: Color(0xFF0B4F32), size: 18),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('app_title'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  context.tr('app_subtitle'),
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const LanguageToggleButton(compact: true),
          if (!isLoggedIn)
            BouncingPressable(
              onTap: () => shellVm.setTabIndex(3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(context.tr('nav_login'), style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold)),
              ),
            )
          else
            BouncingPressable(
              onTap: () => shellVm.setTabIndex(3),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Icon(Icons.account_circle, color: Colors.white, size: 22),
              ),
            ),
          Builder(
            builder: (ctx) => BouncingPressable(
              onTap: () => Scaffold.of(ctx).openEndDrawer(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Icon(Icons.menu_rounded, color: Colors.white, size: 22),
              ),
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
        config: config,
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

