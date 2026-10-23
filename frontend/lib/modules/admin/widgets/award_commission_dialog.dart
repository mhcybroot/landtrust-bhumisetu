import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/animations/delight_financial_animations.dart';
import 'package:landtrust_app/core/animations/finance_escrow_animations.dart';

class AwardCommissionDialog extends StatefulWidget {
  final List<dynamic>? users;
  final Map<String, dynamic>? proposal;
  final bool isMobile;
  final Future<void> Function(Map<String, dynamic> payload)? onSubmit;

  const AwardCommissionDialog({
    super.key,
    this.users,
    this.proposal,
    required this.isMobile,
    this.onSubmit,
  });

  static void show(
    BuildContext context, {
    required List<dynamic> users,
    required bool isMobile,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AwardCommissionDialog(users: users, isMobile: isMobile, onSubmit: onSubmit),
    );
  }

  @override
  State<AwardCommissionDialog> createState() => _AwardCommissionDialogState();
}

class _AwardCommissionDialogState extends State<AwardCommissionDialog> {
  late int officerId;
  late final TextEditingController dealCtrl;
  late final TextEditingController percentCtrl;
  late final TextEditingController noteCtrl;
  bool submitting = false;
  bool showConfetti = false;

  @override
  void initState() {
    super.initState();
    final officers = _getOfficers();
    officerId = officers.isNotEmpty ? (officers.first['id'] as int) : 1;
    dealCtrl = TextEditingController(text: '1000000');
    percentCtrl = TextEditingController(text: '0.5');
    noteCtrl = TextEditingController(text: 'জমির সফল দলিল সম্পাদন কমিশন');
  }

  List<dynamic> _getOfficers() {
    final list = widget.users ?? [
      {'id': 1, 'fullName': 'করিম এজেন্ট', 'myReferralCode': 'LT-AG-01', 'role': 'MARKETING_OFFICER'}
    ];
    return list.where((u) => u['role'] == 'MARKETING_OFFICER' || u['role'] == 'UPAZILA_AGENT' || u['role'] == 'DISTRICT_AGENT').toList();
  }

  @override
  Widget build(BuildContext context) {
    final officers = _getOfficers();
    final deal = double.tryParse(dealCtrl.text.trim()) ?? 0;
    final pct = double.tryParse(percentCtrl.text.trim()) ?? 0;
    final calcCommission = (deal * pct) / 100;

    return Stack(alignment: Alignment.topCenter, children: [
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 12 : 24, vertical: 16),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.workspace_premium, color: Color(0xFFD97706), size: 22),
            SizedBox(width: 8),
            Text('মার্কেটিং অফিসারকে ডিল কমিশন প্রদান', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          SizedBox(height: 6),
          MilestonePathGlow(totalInstallments: 4, paidInstallments: 3),
        ]),
        content: SizedBox(
          width: widget.isMobile ? double.infinity : 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (officers.isNotEmpty)
                DropdownButtonFormField<int>(
                  key: ValueKey('officer_$officerId'),
                  initialValue: officerId,
                  decoration: const InputDecoration(labelText: 'মার্কেটিং অফিসার নির্বাচন', isDense: true),
                  items: officers.map((o) => DropdownMenuItem<int>(value: o['id'] as int, child: Text('${o['fullName']} (${o['myReferralCode'] ?? ''})'))).toList(),
                  onChanged: (v) => setState(() => officerId = v!),
                ),
              const SizedBox(height: 10),
              TextField(controller: dealCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সম্পাদিত জমির মোট মূল্য (৳)', isDense: true), onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              TextField(controller: percentCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'কমিশন হার (%)', isDense: true), onChanged: (_) => setState(() {})),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                child: Text('গণনাকৃত মোট কমিশন: ৳$calcCommission', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
              ),
              const SizedBox(height: 10),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'কমিশন প্রদানের বিবরণ / নোট', isDense: true)),
            ],
          ),
        ),
        actions: [
          BouncingPressable(onTap: () => Navigator.pop(context), child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল'))),
          BouncingPressable(
            onTap: submitting ? null : () {},
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: submitting ? null : () async {
                setState(() { submitting = true; showConfetti = true; });
                try {
                  if (widget.onSubmit != null) {
                    await widget.onSubmit!({
                      'officerId': officerId,
                      'baseDealAmountBdt': deal,
                      'percentageRate': pct,
                      'commissionAmountBdt': calcCommission,
                      'note': noteCtrl.text.trim(),
                    });
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কমিশন সফলভাবে প্রদান করা হয়েছে!')));
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                } finally {
                  if (mounted) setState(() => submitting = false);
                }
              },
              child: submitting ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('কমিশন বরাদ্দ করুন'),
            ),
          ),
        ],
      ),
      if (showConfetti) const Positioned(top: 10, child: ConfettiCelebration()),
    ]);
  }
}
