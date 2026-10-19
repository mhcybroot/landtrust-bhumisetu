import 'package:flutter/material.dart';

class DemoAccountsBar extends StatelessWidget {
  final bool isLoading;
  final Function(String phone, String pass) onDemoSelect;

  const DemoAccountsBar({
    super.key,
    required this.isLoading,
    required this.onDemoSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚡ ডেমো অ্যাকাউন্ট পরীক্ষা (১-ক্লিক লগইন):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0B4F32)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('অ্যাডমিন ডেমো', '01700000000', 'admin123', const Color(0xFF0A2E1F), Icons.admin_panel_settings),
              _btn('অফিসার ডেমো', '01800000001', '123456', Colors.indigo.shade700, Icons.share),
              _btn('বিক্রেতা ডেমো', '01900000002', '123456', Colors.teal.shade800, Icons.landscape),
              _btn('ক্রেতা ডেমো', '01600000003', '123456', Colors.orange.shade900, Icons.person_search),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, String phone, String pass, Color color, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      onPressed: isLoading ? null : () => onDemoSelect(phone, pass),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
