import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:landtrust_app/core/animations/legal_verification_animations.dart';
import 'package:landtrust_app/core/animations/transitions/finance_payment_transitions.dart';
import 'package:landtrust_app/core/constants/app_constants.dart';
import 'package:landtrust_app/core/network/api_client.dart';

class DigitalIdCardDialog extends StatefulWidget {
  final Map<String, dynamic> officerData;
  final bool isMobile;

  const DigitalIdCardDialog({super.key, required this.officerData, required this.isMobile});

  static void show(BuildContext context, {required Map<String, dynamic> officerData, required bool isMobile}) {
    showDialog(context: context, builder: (ctx) => DigitalIdCardDialog(officerData: officerData, isMobile: isMobile));
  }

  @override
  State<DigitalIdCardDialog> createState() => _DigitalIdCardDialogState();
}

class _DigitalIdCardDialogState extends State<DigitalIdCardDialog> {
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    final officer = (widget.officerData['officer'] as Map<String, dynamic>?) ?? {};
    final name = officer['fullName'] ?? 'অফিসার নাম';
    final role = officer['role']?.toString() ?? 'MARKETING_OFFICER';
    final code = widget.officerData['referralCode'] ?? officer['myReferralCode'] ?? 'LT-OFF-XXXX';
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
      insetPadding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 12 : 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.isMobile ? 350 : 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: BankCardFlipCvvTransition(
                  showBack: _showBack,
                  front: _buildFront(name, roleLabel, area, code),
                  back: _buildBack(qrUrl),
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF07301E), Color(0xFF0B4F32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.home_work_rounded, color: Color(0xFF0B4F32), size: 18)),
          const SizedBox(width: 8),
          const Text('bdHousing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 2),
        const Text('আবাসন খাতের বিশেষায়িত মার্কেটপ্লেস', style: TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(12)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.verified, color: Colors.white, size: 10),
            SizedBox(width: 3),
            Flexible(child: Text('LIFETIME CERTIFIED PARTNER', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFront(String name, String roleLabel, String area, String code) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        CircleAvatar(radius: 26, backgroundColor: const Color(0xFF0B4F32), child: Text(name.isNotEmpty ? name[0] : 'U', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F2B48))),
        Text(roleLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0B4F32))),
        if (area.isNotEmpty) Text(area, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFF1F8F5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
          child: Row(children: [
            const Text('পার্টনার কোড: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
            Expanded(child: Text(code, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)))),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('🔄 ট্যাপ করে পেছনের কিউআর ও সিলমোহর দেখুন', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildBack(String qrUrl) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Stack(alignment: Alignment.topRight, children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(qrUrl, width: 95, height: 95, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.qr_code_2, size: 60, color: Color(0xFF0B4F32)))),
          const TrustSealStamp(size: 32),
        ]),
        const SizedBox(height: 6),
        const Text('স্ক্যান করে প্রোফাইল ও রেফারেল নিশ্চিত করুন', style: TextStyle(fontSize: 10, color: Colors.black54)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(8)),
          child: Text('অনুমোদিত মাঠ প্রতিনিধি • hotline: ${AppConstants.defaultSupportPhone}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Colors.black54)),
        ),
        const SizedBox(height: 6),
        const Text('🔄 ট্যাপ করে আইডি কার্ডের সামনে ফিরুন', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildActions(BuildContext context, String shareLink) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.copy, size: 14),
            label: const Text('লিংক কপি', style: TextStyle(fontSize: 11)),
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
            child: const Text('বন্ধ করুন', style: TextStyle(fontSize: 11)),
          ),
        ),
      ]),
    );
  }
}
