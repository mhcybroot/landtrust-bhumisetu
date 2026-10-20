import 'package:flutter/material.dart';

class ShellDrawer extends StatelessWidget {
  final int selectedIndex;
  final bool isLoggedIn;
  final bool isAdmin;
  final Map<String, dynamic>? user;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;

  const ShellDrawer({
    super.key,
    required this.selectedIndex,
    required this.isLoggedIn,
    required this.isAdmin,
    required this.user,
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
                  _drawerItem(0, Icons.home_rounded, 'জমি খুঁজুন (মার্কেটপ্লেস)', context),
                  _drawerItem(1, Icons.assignment_rounded, 'জমি ক্রয়ের চাহিদা সমূহ', context),
                  _drawerItem(2, Icons.verified_user_rounded, 'নিয়মাবলি ও প্ল্যাটফর্ম ফি', context),
                  const Divider(height: 24, thickness: 1),
                  _drawerItem(
                    3,
                    isLoggedIn ? (isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded) : Icons.login_rounded,
                    isLoggedIn ? (isAdmin ? 'অ্যাডমিন ড্যাশবোর্ড' : 'আমার পোর্টাল') : 'লগইন / নতুন নিবন্ধন',
                    context,
                  ),
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded, color: Color(0xFF0B4F32)),
                    title: const Text('জরুরি হেল্পলাইন', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('নোয়াখালী জেলা সমন্বয়ক'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      _showHelplineDialog(context);
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
              child: Text('ভূমি সেতু v1.0.1 • নোয়াখালী', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B4F32),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.terrain, color: Color(0xFF0B4F32), size: 22),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ভূমি সেতু', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  Text('নোয়াখালী জেলা প্ল্যাটফর্ম', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isLoggedIn && user != null ? (user!['fullName']?.toString() ?? 'ইউজার') : 'নিরাপদ জমি কেনাবেচা',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (isLoggedIn && user != null)
            Text('${user!['role'] ?? ''} • ${user!['phoneNumber'] ?? ''}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _drawerItem(int index, IconData icon, String title, BuildContext context) {
    final active = selectedIndex == index;
    return Container(
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
    );
  }

  void _showHelplineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.support_agent, color: Color(0xFF0B4F32)), SizedBox(width: 8), Text('হেল্পলাইন ও সহায়তা')]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ভূমি সেতু নোয়াখালী অফিস:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('📞 হটলাইন: ০১৭১১-০০০০০০ / ০১৮১১-০০০০০০'),
            Text('📍 অফিস: মাইজদী কোর্ট রোড, নোয়াখালী সদর'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে'))],
      ),
    );
  }
}
