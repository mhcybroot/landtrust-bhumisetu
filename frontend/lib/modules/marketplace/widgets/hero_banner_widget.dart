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
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: isMobile ? 22 : 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF042416), Color(0xFF0B4F32), Color(0xFF0F5A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.amberAccent, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'বাংলাদেশের বিশ্বস্ত আবাসন ও ভূমি মার্কেটপ্লেস',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'আপনার স্বপ্নের নিরাপদ জমি ও ফ্ল্যাট খুঁজুন',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 22 : 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'সরেজমিনে দলিল ও খতিয়ান যাচাইকৃত শতভাগ নিষ্কণ্টক প্রোপার্টির আধুনিক প্ল্যাটফর্ম • নোয়াখালী, কুমিল্লা, ফেনী ও লক্ষ্মীপুর',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: isMobile ? 12.5 : 14.5, height: 1.4),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  _trustItem(Icons.verified_user_outlined, '১০০% দলিল যাচাই'),
                  _trustItem(Icons.history_edu_outlined, 'মৌজা ও বায়া খতিয়ান তল্লাশি'),
                  _trustItem(Icons.handshake_outlined, 'সরাসরি ক্রেতা-বিক্রেতা ডিল'),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade500,
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: isMobile ? 10 : 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onRoleRegisterClick,
                    icon: const Icon(Icons.add_home_work_rounded, size: 17),
                    label: const Text('বিজ্ঞাপন দিন (Post Ad)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B4F32),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: isMobile ? 10 : 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onRoleRegisterClick,
                    icon: const Icon(Icons.person_search, size: 17),
                    label: const Text('চাহিদা দিন (Post Demand)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: isMobile ? 10 : 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onRoleRegisterClick,
                    icon: const Icon(Icons.badge_outlined, size: 17),
                    label: const Text('প্রতিনিধি নেটওয়ার্ক', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.amberAccent),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
