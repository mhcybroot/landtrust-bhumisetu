import 'package:flutter/material.dart';
import '../../../../core/animations/transitions/transition_aliases.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/language_toggle_button.dart';
import '../../chat/views/my_chat_threads_dialog.dart';
import '../../marketplace/views/privacy_policy_view.dart';
import 'shell_helpline_dialog.dart';

class ShellDrawer extends StatelessWidget {
  final int selectedIndex;
  final bool isLoggedIn;
  final bool isAdmin;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? config;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;

  const ShellDrawer({
    super.key,
    required this.selectedIndex,
    required this.isLoggedIn,
    required this.isAdmin,
    required this.user,
    this.config,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(0, Icons.home_rounded, context.tr('nav_explore'), context),
                  _drawerItem(1, Icons.assignment_rounded, context.tr('nav_demands'), context),
                  _drawerItem(2, Icons.info_rounded, context.tr('nav_rules'), context),
                  const Divider(height: 16, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.language_rounded, color: Color(0xFF0B4F32), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.isBangla ? 'ভাষা পরিবর্তন' : 'Language',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const LanguageToggleButton(onLightBackground: true),
                      ],
                    ),
                  ),
                  _drawerItem(
                    3,
                    isLoggedIn ? (isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded) : Icons.login_rounded,
                    isLoggedIn ? (isAdmin ? context.tr('nav_admin') : context.tr('nav_portal')) : context.tr('nav_login'),
                    context,
                  ),
                  if (isLoggedIn)
                    ListTile(
                      leading: const Icon(Icons.mark_chat_unread_rounded, color: Color(0xFF0B4F32)),
                      title: const Text('লাইভ সাপোর্ট চ্যাট', style: TextStyle(fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        Navigator.pop(context);
                        MyChatThreadsDialog.show(context, isMobile: true);
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded, color: Color(0xFF0B4F32)),
                    title: const Text('জরুরি হেল্পলাইন', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('নোয়াখালী জেলা সমন্বয়ক'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      ShellHelplineDialog.show(context, config);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF0B4F32)),
                    title: const Text('গোপনীয়তা ও ডেটা সুরক্ষা', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      PrivacyPolicyView.show(context);
                    },
                  ),
                  if (isLoggedIn) ...[
                    const Divider(height: 24, thickness: 1),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      title: const Text('লগআউট করুন', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.pop(context);
                        onLogout();
                      },
                    ),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('bdHousing v1.2.0 • আবাসন প্ল্যাটফর্ম', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  String _roleBangla(String? role) => switch (role) {
    'ADMIN' => 'প্রধান পরিচালক (Admin)',
    'DISTRICT_AGENT' => 'জেলা প্রধান প্রতিনিধি',
    'UPAZILA_AGENT' => 'উপজেলা এজেন্ট',
    'MARKETING_OFFICER' => 'মার্কেটিং অফিসার',
    'SELLER' => 'জমির বিক্রেতা (Seller)',
    _ => 'জমির ক্রেতা (Buyer)',
  };

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0B4F32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.home_work_rounded, color: Color(0xFF0B4F32), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('bdHousing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      isLoggedIn ? (user?['fullName'] ?? 'সদস্য') : 'আবাসন মার্কেটপ্লেস',
                      style: TextStyle(color: Colors.green.shade100, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoggedIn && user != null) ...[
            const SizedBox(height: 8),
            Text(
              'মোবাইল: ${user?['phoneNumber'] ?? ''} • ভূমিকা: ${_roleBangla(user?['role']?.toString())}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _drawerItem(int index, IconData icon, String title, BuildContext context) {
    final active = selectedIndex == index;
    return StaggeredSheetItemsSlide(
      index: index,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(color: active ? const Color(0xFFE8F5E9) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: active ? const Color(0xFF0B4F32) : Colors.grey.shade700),
          title: Text(title, style: TextStyle(color: active ? const Color(0xFF0B4F32) : Colors.black87, fontWeight: active ? FontWeight.bold : FontWeight.w500)),
          trailing: active ? const Icon(Icons.check_circle, color: Color(0xFF0B4F32), size: 18) : null,
          onTap: () {
            Navigator.pop(context);
            onTabSelected(index);
          },
        ),
      ),
    );
  }
}
