import 'package:flutter/material.dart';
import '../../../../core/animations/transitions/app_dialog_transition.dart';
import '../../../../core/animations/transitions/form_wizard_transitions.dart';

class ContactInquiryDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> listing,
    required Future<void> Function(double budget, String message) onSubmit,
  }) {
    final budgetCtrl = TextEditingController(text: '${listing['expectedPriceBdt']}');
    final msgCtrl = TextEditingController(
      text: 'আমি এই জমিটি সরেজমিনে পরিদর্শন করতে এবং কাগজপত্র যাচাই সাপেক্ষে ক্রয় করতে আগ্রহী।',
    );
    bool submitting = false;

    AppDialogTransition.show(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          title: Text(
            'আগ্রহ প্রকাশ: ${listing['title']}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'bdHousing অ্যাডমিন আপনার অনুরোধটি যাচাই করে বিক্রেতার সাথে যোগাযোগ ও পরিদর্শনের ব্যবস্থা করবেন।',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber.shade400)),
                    child: const Row(children: [
                      Icon(Icons.shield_outlined, size: 14, color: Color(0xFFE65100)),
                      SizedBox(width: 5),
                      Expanded(child: Text('সতর্কতা: জমি সরজমিন পরিদর্শন ও ই-পর্চা যাচাই ব্যতীত কোনো বায়না বা অগ্রিম টাকা পাঠাবেন না। লেনদেন সরাসরি ক্রেতা ও বিক্রেতার হাতে সম্পন্ন হবে।', style: TextStyle(fontSize: 10, color: Color(0xFF5D4037), height: 1.25))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: budgetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'আপনার প্রস্তাবিত বাজেট (৳)', isDense: true),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: msgCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'আপনার বার্তা বা প্রশ্ন', isDense: true),
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actionsOverflowButtonSpacing: 8,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: submitting
                  ? null
                  : () async {
                      final b = double.tryParse(budgetCtrl.text.trim()) ?? 0;
                      final m = msgCtrl.text.trim();
                      if (b <= 0 || m.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বাজেট এবং বার্তা সঠিকভাবে লিখুন।')));
                        return;
                      }
                      setDialogState(() => submitting = true);
                      try {
                        await onSubmit(b, m);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আগ্রহ প্রকাশের অনুরোধটি সফলভাবে পাঠানো হয়েছে!')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                        }
                      } finally {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: SubmitButtonLoaderToSuccess(
                isLoading: submitting,
                isSuccess: false,
                label: 'অনুরোধ পাঠান',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
