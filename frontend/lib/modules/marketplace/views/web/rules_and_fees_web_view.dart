import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('১. নিবন্ধন ফি ও কমিশন হার', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('• ক্রেতা নিবন্ধন ফি: ৳${settings['buyerRegistrationFee'] ?? 500} (চাহিদা নিবন্ধন ও সংযোগ সহায়তা)'),
                      Text('• বিক্রেতা নিবন্ধন ফি: ৳${settings['sellerRegistrationFee'] ?? 500} (বিজ্ঞাপন প্রকাশ ও নথি যাচাই)'),
                      Text('• মার্কেটিং অফিসার নিবন্ধন ফি: ৳${settings['officerRegistrationFee'] ?? 300} (ইউনিক কোড ও প্রশিক্ষণ)'),
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
                      const Text('৩. নিরাপত্তা ও নীতিমালা', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('• অনুমতি ছাড়া কোনো দলিল বা ব্যক্তিগত মোবাইল নম্বর উন্মুক্ত করা হয় না।'),
                      const Text('• প্রতিটি সম্মানী ও কমিশন বাস্তব যাচাইযোগ্য লেনদেনের বিপরীতে প্রদান করা হয়।'),
                      const Text('• চূড়ান্ত বায়না বা দলিলের পূর্বে বিজ্ঞ আইনজীবী ও সার্ভেয়ার দ্বারা কাগজপত্র যাচাই করা আবশ্যক।'),
                      const Divider(height: 20),
                      Text(
                        'অফিস: ${settings['officeAddress'] ?? 'মাইজদী কোর্ট, নোয়াখালী'} | হেল্পলাইন: ${settings['supportPhone'] ?? '01800-000000'} | ইমেইল: ${settings['supportEmail'] ?? 'support@landtrust.com.bd'}',
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
