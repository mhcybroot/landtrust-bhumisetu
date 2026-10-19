import 'package:flutter/material.dart';

class AdminFinanceDialogs {
  static void showAddExpenseDialog(
    BuildContext context, {
    required bool isMobile,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    String bucket = 'PLATFORM_REVENUE';
    final amountCtrl = TextEditingController(text: '1000');
    final descCtrl = TextEditingController(text: 'সার্ভার ও হোস্টিং বিল পরিশোধ');
    final methodCtrl = TextEditingController(text: 'বিকাশ');
    final trxCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('তহবিল থেকে ব্যয় সংযোজন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: bucket,
                  decoration: const InputDecoration(labelText: 'ব্যয়ের ফান্ড নির্বাচন', isDense: true),
                  items: [
                    const DropdownMenuItem(value: 'PLATFORM_REVENUE', child: Text('১. প্ল্যাটফর্ম পরিচালনা আয় (৬০%)')),
                    const DropdownMenuItem(value: 'FIELD_VERIFICATION_FUND', child: Text('২. সরজমিন পরিদর্শন তহবিল (২৫%)')),
                    const DropdownMenuItem(value: 'DISPUTE_RESERVE_FUND', child: Text('৩. বিরোধ নিষ্পত্তি রিজার্ভ (১৫%)')),
                  ],
                  onChanged: (v) => setDialogState(() => bucket = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ব্যয়ের পরিমাণ (৳) *', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'ব্যয়ের কারণ / বিবরণ *', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: methodCtrl, decoration: const InputDecoration(labelText: 'পেমেন্ট মাধ্যম', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: trxCtrl, decoration: const InputDecoration(labelText: 'ভাউচার / TrxID (ঐচ্ছিক)', isDense: true)),
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
                      final a = double.tryParse(amountCtrl.text.trim()) ?? 0;
                      if (a <= 0 || descCtrl.text.trim().isEmpty) return;
                      setDialogState(() => submitting = true);
                      try {
                        await onSubmit({
                          'fundBucket': bucket,
                          'amountBdt': a,
                          'description': descCtrl.text.trim(),
                          'paymentMethod': methodCtrl.text.trim(),
                          'transactionId': trxCtrl.text.trim(),
                        });
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      } finally {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: const Text('ব্যয় রেকর্ড করুন'),
            ),
          ],
        ),
      ),
    );
  }

  static void showCounterOfferDialog(
    BuildContext context, {
    required Map<String, dynamic> proposal,
    required bool isMobile,
    required Future<void> Function(double fee, String note) onSubmit,
  }) {
    final feeCtrl = TextEditingController(text: '${proposal['customerProposedFeeBdt']}');
    final noteCtrl = TextEditingController(text: 'কাজের পরিধি বিবেচনায় আমাদের পাল্টা প্রস্তাব');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text('পাল্টা প্রস্তাবনা (${proposal['proposalTitle']})', style: const TextStyle(fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'আমাদের প্রস্তাবিত ফি (৳) *', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'পাল্টা প্রস্তাবের যৌক্তিকতা', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
              onPressed: submitting
                  ? null
                  : () async {
                      final f = double.tryParse(feeCtrl.text.trim()) ?? 0;
                      if (f <= 0) return;
                      setDialogState(() => submitting = true);
                      try {
                        await onSubmit(f, noteCtrl.text.trim());
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      } finally {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: const Text('পাল্টা প্রস্তাব পাঠান'),
            ),
          ],
        ),
      ),
    );
  }
}
