import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyPolicyView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('গোপনীয়তা নীতিমালা (Privacy Policy)'),
        backgroundColor: const Color(0xFF0B4F32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildDisclaimerCard(),
                const SizedBox(height: 16),
                _buildSection(
                  '১. সংগৃহীত তথ্যাবলি (Collected Information)',
                  Icons.person_pin_rounded,
                  [
                    '• অ্যাকাউন্ট তথ্য: ব্যবহারকারীর নাম, সচল মোবাইল নম্বর এবং পাসওয়ার্ড।',
                    '• এলাকা ও ভৌগোলিক তথ্য: কাঙ্ক্ষিত জেলা, উপজেলা, পৌরসভা বা ইউনিয়ন (কোনো ব্যাকগ্রাউন্ড লাইভ ট্র্যাকিং করা হয় না)।',
                    '• প্রোপার্টির ছবি ও বিবরণ: বিক্রেতা বা প্রতিনিধি কর্তৃক আপলোডকৃত জমি বা ফ্ল্যাটের ছবি ও তথ্য।',
                    '• টেকনিক্যাল ডেটা: ক্র্যাশ ডায়াগনস্টিকস ও অ্যাপের পারফরম্যান্স বিশ্লেষণ।',
                  ],
                ),
                const SizedBox(height: 14),
                _buildSection(
                  '২. তথ্যের ব্যবহার ও উদ্দেশ্য (Purpose of Data)',
                  Icons.security_rounded,
                  [
                    '• সদস্য অ্যাকাউন্ট ও লগইন নিরাপত্তা নিশ্চিতকরণ।',
                    '• ক্রেতা ও বিক্রেতার মাঝে সরাসরি নিরাপদ যোগাযোগ স্থাপন।',
                    '• ভুয়া লিস্টিং ও প্রতারণা প্রতিরোধে ভেরিফিকেশন।',
                    '• কোনো অবস্থাতেই ব্যবহারকারীর ডেটা তৃতীয় পক্ষের কাছে বিক্রি করা হয় না।',
                  ],
                ),
                const SizedBox(height: 14),
                _buildSection(
                  '৩. আর্থিক লেনদেন ও এসক্রো সতর্কতা (P2P Transactions)',
                  Icons.handshake_outlined,
                  [
                    '• bdHousing কোনো ব্যাংকিং বা এসক্রো (Escrow) প্ল্যাটফর্ম নয়।',
                    '• জমি বা ফ্ল্যাট কেনার আর্থিক লেনদেন অ্যাপের মাধ্যমে পরিচালিত হয় না।',
                    '• আর্থিক লেনদেন ক্রেতা ও বিক্রেতার মাঝে সরাসরি অফলাইনে আইনি প্রক্রিয়ায় সম্পন্ন হয়।',
                  ],
                ),
                const SizedBox(height: 14),
                _buildSection(
                  '৪. অ্যাকাউন্ট ও ডেটা মুছে ফেলার অধিকার (Data Deletion)',
                  Icons.delete_forever_rounded,
                  [
                    '• ইন-অ্যাপ ডিলিট: প্রোফাইল সেটিংস থেকে "অ্যাকাউন্ট ডিলিট করুন" চেপে সরাসরি অ্যাকাউন্ট মোছা যায়।',
                    '• ওয়েব আবেদন: অ্যাপ ছাড়া আমাদের ওয়েবসাইট (https://bdhousing.com.bd/delete-account) থেকেও ডেটা মোছার আবেদন করা যাবে।',
                    '• অনুরোধ প্রাপ্তির ৪৮ ঘণ্টার মধ্যে সার্ভার থেকে ব্যক্তিগত তথ্য স্থায়ীভাবে অপসারিত হয়।',
                  ],
                ),
                const SizedBox(height: 14),
                _buildSection(
                  '৫. যোগাযোগ ও অভিযোগ কর্মকর্তা (Contact Support)',
                  Icons.support_agent_rounded,
                  [
                    '• ইমেইল: support@bdhousing.com.bd',
                    '• ঠিকানা: প্রধান কার্যালয়, মাইজদী কোর্ট, সদর, নোয়াখালী।',
                    '• হটলাইন: 01711-889900',
                  ],
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text('© 2026 bdHousing • সর্বস্বত্ব সংরক্ষিত', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B4F32),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏡 bdHousing গোপনীয়তা ও ডেটা সুরক্ষা নীতিমালা', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Google Play Data Safety & User Privacy Compliant', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFB300)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFB71C1C), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'আইনগত ঘোষণা: bdHousing একটি স্বাধীন বেসরকারি রিয়েল এস্টেট মার্কেটপ্লেস এবং এটি গণপ্রজাতন্ত্রী বাংলাদেশ সরকার বা ভূমি মন্ত্রণালয়ের কোনো অফিশিয়াল সেবা নয়। ই-পর্চা যাচাইয়ের লিংক ব্যবহারকারীর সুবিধার্থে পাবলিক রেফারেন্স হিসেবে দেওয়া হয়েছে।',
              style: TextStyle(fontSize: 12, color: Color(0xFF3E2723), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> items) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF0B4F32)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B4F32))),
              ],
            ),
            const SizedBox(height: 8),
            ...items.map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(it, style: const TextStyle(fontSize: 12.5, height: 1.4)),
                )),
          ],
        ),
      ),
    );
  }
}
