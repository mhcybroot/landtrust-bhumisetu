import 'package:flutter/material.dart';

class AwardCommissionDialog {
  static void show(
    BuildContext context, {
    required List<dynamic> users,
    required bool isMobile,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    final officers = users.where((u) => u['role'] == 'MARKETING_OFFICER' || u['role'] == 'UPAZILA_AGENT' || u['role'] == 'DISTRICT_AGENT').toList();
    if (officers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কোনো মার্কেটিং অফিসার বা এজেন্ট পাওয়া যায়নি।')));
      return;
    }

    int officerId = officers.first['id'] as int;
    final dealCtrl = TextEditingController(text: '1000000');
    final percentCtrl = TextEditingController(text: '0.5');
    final noteCtrl = TextEditingController(text: 'জমির সফল দলিল সম্পাদন কমিশন');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final deal = double.tryParse(dealCtrl.text.trim()) ?? 0;
          final pct = double.tryParse(percentCtrl.text.trim()) ?? 0;
          final calcCommission = (deal * pct) / 100;

          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
            title: const Text('মার্কেটিং অফিসারকে ডিল কমিশন প্রদান', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SizedBox(
              width: isMobile ? double.infinity : 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    value: officerId,
                    decoration: const InputDecoration(labelText: 'মার্কেটিং অফিসার নির্বাচন', isDense: true),
                    items: officers.map((o) => DropdownMenuItem<int>(value: o['id'] as int, child: Text('${o['fullName']} (${o['myReferralCode'] ?? ''})'))).toList(),
                    onChanged: (v) => setDialogState(() => officerId = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: dealCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সম্পাদিত জমির মোট মূল্য (৳)', isDense: true), onChanged: (_) => setDialogState(() {})),
                  const SizedBox(height: 10),
                  TextField(controller: percentCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'কমিশন হার (%)', isDense: true), onChanged: (_) => setDialogState(() {})),
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
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                onPressed: submitting
                    ? null
                    : () async {
                        setDialogState(() => submitting = true);
                        try {
                          await onSubmit({
                            'officerId': officerId,
                            'baseDealAmountBdt': deal,
                            'percentageRate': pct,
                            'commissionAmountBdt': calcCommission,
                            'note': noteCtrl.text.trim(),
                          });
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কমিশন সফলভাবে প্রদান করা হয়েছে!')));
                          }
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                        } finally {
                          setDialogState(() => submitting = false);
                        }
                      },
                child: submitting ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('কমিশন বরাদ্দ করুন'),
              ),
            ],
          );
        },
      ),
    );
  }
}
