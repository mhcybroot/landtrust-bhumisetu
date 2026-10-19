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
                '© ২০২৬ ভূমি সেতু (Bhumi Setu) — নোয়াখালী জেলা নেটওয়ার্ক',
                style: TextStyle(
                  color: Colors.green.shade100,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'নিরাপদ জমি কেনাবেচা, দলিল যাচাই ও মধ্যস্থতা প্ল্যাটফর্ম। অনুমোদন ব্যতীত দলিল প্রকাশ নিষিদ্ধ।',
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
