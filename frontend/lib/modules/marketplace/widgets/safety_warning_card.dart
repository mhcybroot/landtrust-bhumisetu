import 'package:flutter/material.dart';
import '../../../../core/animations/transitions/app_dialog_transition.dart';
import '../../../../core/animations/transitions/finance_payment_transitions.dart';

class SafetyWarningCard extends StatelessWidget {
  final bool isMobile;
  final bool isCompact;

  const SafetyWarningCard({
    super.key,
    required this.isMobile,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 10 : (isMobile ? 12 : 16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Warm Amber Light
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8F00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SecurityShieldLockSnap(isLocked: true),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'জরুরি জনসচেতনতামূলক সতর্কবার্তা ও লেনদেন নীতি',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFFB71C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'যেকোনো অনলাইন প্ল্যাটফর্ম বা ওয়েবসাইট থেকে জমি বা ফ্ল্যাট পছন্দ করার পর কোনো অবস্থাতেই আগে টাকা লেনদেন করবেন না। সরাসরি জমিতে গিয়ে অবস্থান যাচাই করুন এবং সরকারি ই-পর্চা বা ভূমি অফিসের মাধ্যমে দলিলের সত্যতা নিশ্চিত হয়ে তবেই আইনি প্রক্রিয়ায় রেজিস্ট্রেশন সম্পন্ন করুন।',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF3E2723), height: 1.4),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.handshake_outlined, color: Color(0xFF0B4F32), size: 16),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'লেনদেন হবে সরাসরি ক্রেতা এবং বিক্রেতার হাতে। আমরা শুধুমাত্র একটি নিরাপদ মধ্যস্থতা তৈরি করে দেব।',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF0B4F32)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'আইনগত ঘোষণা: bdHousing একটি স্বাধীন বেসরকারি মার্কেটপ্লেস এবং এটি কোনো সরকারি দপ্তর বা বাংলাদেশ ভূমি মন্ত্রণালয়ের সাথে সরাসরি সংযুক্ত নয়।',
                    style: TextStyle(fontSize: 10.5, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0B4F32),
                    side: const BorderSide(color: Color(0xFF0B4F32)),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  ),
                  icon: const Icon(Icons.account_balance_outlined, size: 14),
                  label: const Text('🏛️ সরকারি ই-পর্চা যাচাই', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _openEPorchaGuidance(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEPorchaGuidance(BuildContext context) {
    AppDialogTransition.show(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.verified, color: Color(0xFF0B4F32)),
            SizedBox(width: 8),
            Text('সরকারি ই-পর্চা ও খতিয়ান যাচাই', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('জমি রেজিস্ট্রির আগে সরকারি পোর্টালে সিএস, এসএ, আরএস ও বিএস খতিয়ান মিলিয়ে নিন:'),
            SizedBox(height: 8),
            SelectableText('🌐 eporcha.gov.bd (ভূমি মন্ত্রণালয়)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
            SizedBox(height: 4),
            SelectableText('🌐 mutation.land.gov.bd (ই-নামজারি)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
            SizedBox(height: 8),
            Text('ডিসক্লেইমার: উক্ত পোর্টালসমূহ সরকারি সেবা। bdHousing কোনো সরকারি সত্তা নয়, তথ্য যাচাইয়ে ব্যবহারকারীদের রেফারেন্স হিসেবে এই লিংকগুলো প্রদান করা হয়েছে।', style: TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে')),
        ],
      ),
    );
  }
}
