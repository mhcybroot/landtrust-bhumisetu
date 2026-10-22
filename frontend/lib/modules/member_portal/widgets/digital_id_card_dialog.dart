import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:landtrust_app/core/network/api_client.dart';

class DigitalIdCardDialog extends StatelessWidget {
  final Map<String, dynamic> officerData;
  final bool isMobile;

  const DigitalIdCardDialog({super.key, required this.officerData, required this.isMobile});

  static void show(BuildContext context, {required Map<String, dynamic> officerData, required bool isMobile}) {
    showDialog(context: context, builder: (ctx) => DigitalIdCardDialog(officerData: officerData, isMobile: isMobile));
  }

  @override
  Widget build(BuildContext context) {
    final officer = (officerData['officer'] as Map<String, dynamic>?) ?? {};
    final name = officer['fullName'] ?? 'অফিসার নাম';
    final role = officer['role']?.toString() ?? 'MARKETING_OFFICER';
    final code = officerData['referralCode'] ?? officer['myReferralCode'] ?? 'LT-OFF-XXXX';
    final district = officer['district'] ?? '';
    final upazila = officer['upazila'] ?? '';
    final area = [upazila, district].where((s) => s.isNotEmpty).join(', ');
    final shareLink = '${ApiClient.publicWebOrigin}/?ref=$code';
    final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${Uri.encodeComponent(shareLink)}';

    final roleLabel = switch (role) {
      'DISTRICT_AGENT' => 'জেলা প্রধান প্রতিনিধি',
      'UPAZILA_AGENT' => 'উপজেলা প্রধান এজেন্ট',
      'MARKETING_OFFICER' => upazila.contains('পৌরসভা') ? 'পৌরসভা মার্কেটিং অফিসার' : 'ইউনিয়ন মার্কেটিং অফিসার',
      _ => 'অনুমোদিত প্রতিনিধি',
    };

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? 350 : 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(children: [
                  _buildAvatarAndName(name, roleLabel, area),
                  const SizedBox(height: 12),
                  _buildIdRow(code),
                  const SizedBox(height: 12),
                  _buildQrSection(qrUrl),
                  const SizedBox(height: 12),
                  _buildNotice(),
                ]),
              ),
              _buildActions(context, shareLink),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF07301E), Color(0xFF0B4F32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.home_work_rounded, color: Color(0xFF0B4F32), size: 20)),
          const SizedBox(width: 8),
          const Text('bdHousing', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 2),
        const Text('আবাসন খাতের বিশেষায়িত মার্কেটপ্লেস', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
          decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(12)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.verified, color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text('LIFETIME CERTIFIED PARTNER', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAvatarAndName(String name, String roleLabel, String area) {
    return Column(children: [
      CircleAvatar(radius: 28, backgroundColor: const Color(0xFF0B4F32), child: Text(name.isNotEmpty ? name[0] : 'U', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
      const SizedBox(height: 6),
      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F2B48)), textAlign: TextAlign.center),
      Text(roleLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Color(0xFF0B4F32))),
      if (area.isNotEmpty) Text(area, style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
    ]);
  }

  Widget _buildIdRow(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFF1F8F5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('অফিসিয়াল পার্টনার কোড:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(code, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
      ]),
    );
  }

  Widget _buildQrSection(String qrUrl) {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          qrUrl,
          width: 110,
          height: 110,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(width: 110, height: 110, color: Colors.grey.shade200, child: const Icon(Icons.qr_code_2, size: 60, color: Color(0xFF0B4F32))),
        ),
      ),
      const SizedBox(height: 4),
      const Text('স্ক্যান করে প্রোফাইল ও রেফারেল নিশ্চিত করুন', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
    ]);
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(8)),
      child: const Text(
        'এই পরিচয়পত্রধারী ব্যক্তি bdHousing-এর অনুমোদিত মাঠ প্রতিনিধি। জমি/ফ্ল্যাটের কাগজপত্র যাচাই ও সহায়তা প্রদানে তিনি আনুষ্ঠানিকভাবে ক্ষমতাপ্রাপ্ত।\nহটলাইন: ০১৭০০-০০০০০০ • bdhousing.com.bd',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 9.5, color: Colors.black54, height: 1.3),
      ),
    );
  }

  Widget _buildActions(BuildContext context, String shareLink) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.copy, size: 15),
            label: const Text('লিংক কপি', style: TextStyle(fontSize: 11.5)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shareLink));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অফিসারের ডিজিটাল কার্ড ও রেফারেল লিংক কপি হয়েছে!')));
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন', style: TextStyle(fontSize: 11.5)),
          ),
        ),
      ]),
    );
  }
}
