import 'package:flutter/material.dart';

class ShellFooter extends StatelessWidget {
  final bool isMobile;

  const ShellFooter({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF072618),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Text(
                '© ২০২৬ bdHousing — আবাসন খাতের বিশেষায়িত অনলাইন মার্কেটপ্লেস',
                style: TextStyle(
                  color: Colors.green.shade100,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'নিরাপদ জমি ও আবাসন, বিশ্বস্ত সমাধান • কুমিল্লা • নোয়াখালী • ফেনী • লক্ষ্মীপুর',
                style: TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
