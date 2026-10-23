import 'package:flutter/material.dart';
import '../../../../core/animations/bouncing_pressable.dart';

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
                    'আবাসন খাতের বিশেষায়িত অনলাইন মার্কেটপ্লেস',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 11 : 12,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'bdHousing (বিডি হাউজিং)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'নিরাপদ জমি ও আবাসন, বিশ্বস্ত সমাধান • কুমিল্লা, নোয়াখালী, ফেনী ও লক্ষ্মীপুর।',
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
                    BouncingPressable(
                      onTap: onRoleRegisterClick,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.amber.shade600, borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_search, size: 16, color: Colors.black),
                            const SizedBox(width: 6),
                            Text('জমি কিনব (ফি ৳${(settings['buyerRegistrationFee'] as num?)?.toInt() ?? 500})', style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    BouncingPressable(
                      onTap: onRoleRegisterClick,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_location_alt_outlined, size: 16, color: Color(0xFF0B4F32)),
                            const SizedBox(width: 6),
                            Text('জমি বিক্রি (ফি ৳${(settings['sellerRegistrationFee'] as num?)?.toInt() ?? 500})', style: const TextStyle(fontSize: 12, color: Color(0xFF0B4F32), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    BouncingPressable(
                      onTap: onRoleRegisterClick,
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.white70), borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.share, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text('মার্কেটিং অফিসার (ফি ৳${(settings['officerRegistrationFee'] as num?)?.toInt() ?? 300})', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
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
