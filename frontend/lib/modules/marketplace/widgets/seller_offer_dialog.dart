import 'package:flutter/material.dart';

class SellerOfferDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> requirement,
    required Future<void> Function(String details, double price, double fee) onSubmit,
  }) {
    final detailsCtrl = TextEditingController(
      text: '${requirement['preferredUpazila']} এলাকায় আমার নিষ্কণ্টক ${requirement['landType']} জমি রয়েছে, যা আপনার চাহিদার সাথে সামঞ্জস্যপূর্ণ।',
    );
    final priceCtrl = TextEditingController(text: '${requirement['maxBudgetBdt']}');
    final feeCtrl = TextEditingController(text: '50000');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'জমির প্রস্তাব (${requirement['preferredUpazila']})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ক্রেতা: ${requirement['buyerName']} • বাজেট: ৳${requirement['minBudgetBdt']}–৳${requirement['maxBudgetBdt']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 13),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailsCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'আপনার জমির সংক্ষিপ্ত বিবরণ *', isDense: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'প্রত্যাশিত মোট মূল্য (৳) *', isDense: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: feeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'প্রস্তাবিত প্ল্যাটফর্ম সমন্বয় ফি (৳)', isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F32),
                foregroundColor: Colors.white,
              ),
              onPressed: submitting
                  ? null
                  : () async {
                      final p = double.tryParse(priceCtrl.text.trim()) ?? 0;
                      final f = double.tryParse(feeCtrl.text.trim()) ?? 0;
                      final d = detailsCtrl.text.trim();
                      if (d.isEmpty || p <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('বিবরণ ও মূল্য সঠিকভাবে লিখুন।')),
                        );
                        return;
                      }
                      setDialogState(() => submitting = true);
                      try {
                        await onSubmit(d, p, f);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('আপনার জমির প্রস্তাবটি সফলভাবে প্রেরণ করা হয়েছে!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      } finally {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('প্রস্তাব পাঠান'),
            ),
          ],
        ),
      ),
    );
  }
}
