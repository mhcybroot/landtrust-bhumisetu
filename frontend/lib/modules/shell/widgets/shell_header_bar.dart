import 'package:flutter/material.dart';

class ShellHeaderBar extends StatelessWidget {
  final int selectedIndex;
  final bool isMobile;
  final bool isLoggedIn;
  final bool isAdmin;
  final Map<String, dynamic>? user;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onLogout;

  const ShellHeaderBar({
    super.key,
    required this.selectedIndex,
    required this.isMobile,
    required this.isLoggedIn,
    required this.isAdmin,
    required this.user,
    required this.onTabSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B4F32),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 10 : 12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => onTabSelected(0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.terrain, color: Color(0xFF0B4F32), size: 24),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ভূমি সেতু',
                          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'নোয়াখালী জেলা নেটওয়ার্ক',
                          style: TextStyle(color: Colors.green.shade100, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Row(
                  children: [
                    _navBtn(0, Icons.home_outlined, 'জমি খুঁজুন'),
                    _navBtn(1, Icons.assignment_outlined, 'জমি কিনতে চাই'),
                    _navBtn(2, Icons.info_outline, 'নিয়মাবলি ও ফি'),
                    _navBtn(
                      3,
                      isLoggedIn ? (isAdmin ? Icons.admin_panel_settings : Icons.person) : Icons.person_add_alt_1,
                      isLoggedIn ? (isAdmin ? 'অ্যাডমিন প্যানেল' : 'আমার পোর্টাল') : 'নিবন্ধন / লগইন',
                    ),
                    if (isLoggedIn) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
                        tooltip: 'লগআউট',
                        onPressed: onLogout,
                      ),
                    ],
                  ],
                )
              else if (isLoggedIn)
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  tooltip: 'লগআউট',
                  onPressed: onLogout,
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
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: active ? Colors.white : Colors.transparent,
          foregroundColor: active ? const Color(0xFF0B4F32) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => onTabSelected(index),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
