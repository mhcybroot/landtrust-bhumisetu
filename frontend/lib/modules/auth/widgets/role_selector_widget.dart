import 'package:flutter/material.dart';

class RoleSelectorWidget extends StatelessWidget {
  final String selectedRole;
  final bool isMobile;
  final Map<String, dynamic> settings;
  final ValueChanged<String> onRoleSelected;

  const RoleSelectorWidget({
    super.key,
    required this.selectedRole,
    required this.isMobile,
    required this.settings,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final buyerFee = settings['buyerRegistrationFee'] ?? 1000;
    final sPourashava = settings['sellerRegistrationFeePourashava'] ?? 2000;
    final sUnion = settings['sellerRegistrationFeeUnion'] ?? 1000;
    final officerFee = settings['officerRegistrationFee'] ?? 1000;

    return LayoutBuilder(builder: (ctx, constraints) {
      final cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 16) / 3;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SizedBox(
            width: cardWidth,
            child: _roleCard(
              'BUYER',
              '১. জমির ক্রেতা',
              'ফি: ৳$buyerFee',
              Icons.person_search,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _roleCard(
              'SELLER',
              '২. জমির বিক্রেতা',
              'ফি: ৳$sUnion - $sPourashava',
              Icons.landscape,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _roleCard(
              'MARKETING_OFFICER',
              '৩. মার্কেটিং অফিসার',
              'ফি: ৳$officerFee',
              Icons.share,
            ),
          ),
        ],
      );
    });
  }

  Widget _roleCard(String role, String title, String sub, IconData icon) {
    final sel = selectedRole == role;
    return InkWell(
      onTap: () => onRoleSelected(role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? const Color(0xFF0B4F32) : Colors.grey.shade300,
            width: sel ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B4F32), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF0B4F32), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
