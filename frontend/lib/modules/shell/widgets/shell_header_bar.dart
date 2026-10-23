import 'package:flutter/material.dart';
import '../../../../core/animations/bouncing_pressable.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/language_toggle_button.dart';
import '../../../../core/widgets/horizontal_scroll_fade_view.dart';

class ShellHeaderBar extends StatelessWidget {
  final int selectedIndex;
  final bool isMobile;
  final bool isLoggedIn;
  final bool isAdmin;
  final Map<String, dynamic>? user;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;
  final VoidCallback? onOpenDrawer;

  const ShellHeaderBar({
    super.key,
    required this.selectedIndex,
    required this.isMobile,
    required this.isLoggedIn,
    required this.isAdmin,
    required this.user,
    required this.onTabSelected,
    required this.onLogout,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B4F32),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 8 : 12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: InkWell(
                  onTap: () => onTabSelected(0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.home_work_rounded, color: Color(0xFF0B4F32), size: 22),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.tr('app_title'),
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              context.tr('app_subtitle'),
                              style: TextStyle(color: Colors.green.shade100, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isMobile)
                Flexible(
                  child: HorizontalScrollFadeView(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _navBtn(0, Icons.home_outlined, context.tr('nav_explore')),
                        _navBtn(1, Icons.assignment_outlined, context.tr('nav_demands')),
                        _navBtn(2, Icons.info_outline, context.tr('nav_rules')),
                        _navBtn(
                          3,
                          isLoggedIn ? (isAdmin ? Icons.admin_panel_settings : Icons.person) : Icons.person_add_alt_1,
                          isLoggedIn ? (isAdmin ? context.tr('nav_admin') : context.tr('nav_portal')) : context.tr('nav_login'),
                        ),
                        const SizedBox(width: 6),
                        const LanguageToggleButton(),
                        if (isLoggedIn) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                            tooltip: context.tr('logout'),
                            onPressed: onLogout,
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isLoggedIn)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => onTabSelected(3),
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('লগইন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.account_circle, color: Colors.white, size: 22),
                        tooltip: 'পোর্টাল',
                        onPressed: () => onTabSelected(3),
                      ),
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                      tooltip: 'মেনু খুলুন',
                      onPressed: onOpenDrawer,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn(int index, IconData icon, String label) {
    final active = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: BouncingPressable(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: active ? const Color(0xFF0B4F32) : Colors.white),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: active ? const Color(0xFF0B4F32) : Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
