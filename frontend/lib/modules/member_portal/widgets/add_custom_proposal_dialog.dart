import 'package:flutter/material.dart';
import 'package:landtrust_app/core/network/api_client.dart';

class AddCustomProposalDialog {
  static void show(
    BuildContext context, {
    required bool isMobile,
    required VoidCallback onSubmitted,
  }) {
    final titleCtrl = TextEditingController(text: 'নিষ্কণ্টক কাগজপত্র যাচাই ও সীমানা নির্ধারণ সেবা');
    final descCtrl = TextEditingController(text: 'উপজেলা সাব-রেজিস্ট্রি অফিস থেকে তল্লাশি ও সরজমিনে আমিন দ্বারা জমি পরিমাপ সহায়তা চাই।');
    final feeCtrl = TextEditingController(text: '5000');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> submit() async {
            final f = double.tryParse(feeCtrl.text.trim()) ?? 0;
            if (titleCtrl.text.trim().isEmpty || f <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('শিরোনাম ও পারিশ্রমিক লিখুন।')));
              return;
            }
            setDialogState(() => submitting = true);
            try {
              await ApiClient.post('/member/proposals', body: {
                'proposalTitle': titleCtrl.text.trim(),
                'scopeDescription': descCtrl.text.trim(),
                'customerProposedFeeBdt': f,
              });
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বিশেষ প্রস্তাবটি সফলভাবে প্রেরণ করা হয়েছে!')));
                onSubmitted();
              }
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
            } finally {
              setDialogState(() => submitting = false);
            }
          }

          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
            title: const Row(children: [
              Icon(Icons.handshake_outlined, color: Color(0xFF0B4F32), size: 20),
              SizedBox(width: 8),
              Text('নতুন বিশেষ সেবা চুক্তি প্রস্তাব', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            content: SizedBox(
              width: isMobile ? null : 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'সেবার শিরোনাম *', isDense: true)),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'কাজের পরিধি ও বিবরণ *', isDense: true)),
                  const SizedBox(height: 10),
                  TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'আপনার প্রস্তাবিত পারিশ্রমিক (৳) *', isDense: true)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                onPressed: submitting ? null : submit,
                child: submitting ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('প্রস্তাব পাঠান'),
              ),
            ],
          );
        },
      ),
    );
  }
}
