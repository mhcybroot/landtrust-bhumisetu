import 'package:flutter/material.dart';

class HeroBannerWidget extends StatelessWidget {
  final bool isMobile;
  final Map<String, dynamic> settings;
  final TextEditingController searchCtrl;
  final VoidCallback onSearch;
  final VoidCallback onRoleRegisterClick;

  const HeroBannerWidget({
    super.key,
    required this.isMobile,
    required this.settings,
    required this.searchCtrl,
    required this.onSearch,
    required this.onRoleRegisterClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 20 : 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF083A24), Color(0xFF136841)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'নোয়াখালী থেকে শুরু • সারাদেশে বিশ্বস্ত নেটওয়ার্ক',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 11 : 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ভূমি সেতু (Bhumi Setu)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'নিরাপদ জমি কেনাবেচা, সরাসরি চাহিদা সংগ্রহ ও মার্কেটিং অফিসার রেফারেল নেটওয়ার্ক।',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isMobile ? 13 : 15,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 10 : 12,
                        ),
                      ),
                      onPressed: onRoleRegisterClick,
                      icon: const Icon(Icons.person_search, size: 16),
                      label: Text(
                        'জমি কিনব (ফি ৳${(settings['buyerRegistrationFee'] as num?)?.toInt() ?? 500})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0B4F32),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 10 : 12,
                        ),
                      ),
                      onPressed: onRoleRegisterClick,
                      icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                      label: Text(
                        'জমি বিক্রি (ফি ৳${(settings['sellerRegistrationFee'] as num?)?.toInt() ?? 500})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 10 : 12,
                        ),
                      ),
                      onPressed: onRoleRegisterClick,
                      icon: const Icon(Icons.share, size: 16),
                      label: Text(
                        'মার্কেটিং অফিসার (ফি ৳${(settings['officerRegistrationFee'] as num?)?.toInt() ?? 300})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
