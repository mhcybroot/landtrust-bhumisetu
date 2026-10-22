import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/safety_warning_card.dart';

class RulesAndFeesWebView extends StatelessWidget {
  final Map<String, dynamic> config;

  const RulesAndFeesWebView({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final settings = (config['settings'] as Map<String, dynamic>?) ?? {};
    final paymentMethods = (config['paymentMethods'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('নিয়মাবলি, নিবন্ধন ফি ও যোগাযোগ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
              const SizedBox(height: 14),
              const SafetyWarningCard(isMobile: false),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('১. নিবন্ধন ফি ও কমিশন হার', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('• ক্রেতা নিবন্ধন ফি: ৳${settings['buyerRegistrationFee'] ?? 1000} (চাহিদা নিবন্ধন ও সংযোগ সহায়তা)'),
                      Text('• বিক্রেতা নিবন্ধন ফি: ৳${settings['sellerRegistrationFee'] ?? 1000} (বাস্তব প্রোপার্টি ফিল্ড পরিদর্শন, নথি যাচাই ও লিস্টিং সেবা ফি)'),
                      Text('• মার্কেটিং অফিসার নিবন্ধন ফি: ৳${settings['officerRegistrationFee'] ?? 1000} (ইউনিক কোড ও কমিশন পোর্টাল)'),
                      const Divider(height: 20),
                      const Text('২. পেমেন্ট পাঠানোর মাধ্যমসমূহ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...paymentMethods.map((pm) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFF4FBF7), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.15))),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet, size: 18, color: Color(0xFF0B4F32)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${pm['providerName']} (${pm['accountType']}): ${pm['accountNumber']}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16, color: Color(0xFF0B4F32)),
                                  tooltip: 'নম্বর কপি করুন',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: pm['accountNumber'].toString()));
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${pm['accountNumber']} কপি হয়েছে!')));
                                  },
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 20),
                      const Text('৩. নিরাপত্তা, আইনি নোটিশ ও শর্তাবলী', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('• অনুমতি ছাড়া কোনো দলিল বা ব্যক্তিগত মোবাইল নম্বর উন্মুক্ত করা হয় না।'),
                      const Text('• প্রতিটি ফি বাস্তব যাচাইযোগ্য অফলাইন সেবা ও বিজ্ঞাপনের বিপরীতে প্রযোজ্য।'),
                      const Text('• চূড়ান্ত বায়না বা দলিলের পূর্বে বিজ্ঞ আইনজীবী ও সার্ভেয়ার দ্বারা কাগজপত্র যাচাই করা আবশ্যক।'),
                      const Text('• bdHousing কোনো সরকারি সংস্থা নয়; এটি একটি স্বাধীন বেসরকারি আবাসন মার্কেটপ্লেস।'),
                      const Divider(height: 20),
                      Text(
                        'অফিস: ${settings['officeAddress'] ?? 'মাইজদী কোর্ট, নোয়াখালী'} | হেল্পলাইন: ${settings['supportPhone'] ?? '01800-000000'} | ইমেইল: ${settings['supportEmail'] ?? 'support@bdhousing.com.bd'}',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
