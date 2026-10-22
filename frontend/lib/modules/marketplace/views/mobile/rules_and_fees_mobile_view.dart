import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/safety_warning_card.dart';

class RulesAndFeesMobileView extends StatelessWidget {
  final Map<String, dynamic> config;

  const RulesAndFeesMobileView({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final settings = (config['settings'] as Map<String, dynamic>?) ?? {};
    final paymentMethods = (config['paymentMethods'] as List<dynamic>?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const SafetyWarningCard(isMobile: true),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: 'নিবন্ধন ফি ও কমিশন',
          icon: Icons.payments_outlined,
          children: [
            _feeRow('ক্রেতা নিবন্ধন ফি', '৳${settings['buyerRegistrationFee'] ?? 500}', 'চাহিদা প্রকাশ ও সহায়তা'),
            const Divider(height: 14),
            _feeRow('বিক্রেতা নিবন্ধন ফি', '৳${settings['sellerRegistrationFee'] ?? 500}', 'বিজ্ঞাপন ও নথি যাচাই'),
            const Divider(height: 14),
            _feeRow('মার্কেটিং অফিসার', '৳${settings['officerRegistrationFee'] ?? 300}', 'রেফারেল কোড ও কমিশন'),
          ],
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: 'পেমেন্ট পাঠানোর মাধ্যমসমূহ',
          icon: Icons.account_balance_wallet_outlined,
          children: [
            const Text('নিচের যেকোনো নম্বরে ফি পাঠিয়ে TrxID সংগ্রহ করুন:', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 10),
            ...paymentMethods.map((pm) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_android, size: 20, color: Color(0xFF0B4F32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${pm['providerName']} (${pm['accountType']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${pm['accountNumber']}', style: const TextStyle(fontSize: 12, color: Color(0xFF0B4F32), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: Color(0xFF0B4F32)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: pm['accountNumber'].toString()));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${pm['accountNumber']} কপি হয়েছে!')));
                        },
                      ),
                    ],
                  ),
                )),
          ],
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: 'জরুরি সহায়তা ও হেল্পলাইন',
          icon: Icons.support_agent_outlined,
          children: [
            Text('📞 সাপোর্ট: ${settings['supportPhone'] ?? '01800-000000'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('📍 অফিস: ${settings['officeAddress'] ?? 'মাইজদী কোর্ট, নোয়াখালী'}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('✉️ ইমেইল: ${settings['supportEmail'] ?? 'support@landtrust.com.bd'}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0B4F32), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _feeRow(String label, String fee, String note) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(note, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        Text(fee, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4F32))),
      ],
    );
  }
}
