import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/animations/transitions/finance_payment_transitions.dart';

class OfficerPayoutDialog {
  static void show(
    BuildContext context, {
    required dynamic pendingPayable,
    required bool isMobile,
    required Future<void> Function(double amount, String method, String account) onSubmit,
  }) {
    final amountCtrl = TextEditingController(text: '$pendingPayable');
    String method = 'বিকাশ (bKash)';
    final accCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Row(children: [
            Icon(Icons.payments_outlined, color: Color(0xFF0B4F32), size: 20),
            SizedBox(width: 8),
            Text('কমিশন উইথড্র রিকোয়েস্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('উইথড্রযোগ্য ব্যালেন্স: ৳$pendingPayable', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                const SizedBox(height: 12),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'উইথড্রর পরিমাণ (৳) *', isDense: true)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey('payout_method_$method'),
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'পেমেন্ট গ্রহণের মাধ্যম', isDense: true),
                  items: ['বিকাশ (bKash)', 'নগদ (Nagad)', 'রকেট (Rocket)', 'ব্যাংক একাউন্ট'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setDialogState(() => method = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: accCtrl, decoration: const InputDecoration(labelText: 'একাউন্ট / মোবাইল নম্বর *', isDense: true)),
              ],
            ),
          ),
          actions: [
            BouncingPressable(
              onTap: () => Navigator.pop(ctx),
              child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ),
            BouncingPressable(
              onTap: submitting ? null : () {},
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                icon: PayoutTransferFlyArrow(isTransferring: submitting),
                onPressed: submitting ? null : () async {
                  final a = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (a <= 0 || accCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক পরিমাণ ও একাউন্ট নম্বর দিন।')));
                    return;
                  }
                  setDialogState(() => submitting = true);
                  try {
                    await onSubmit(a, method, accCtrl.text.trim());
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('উইথড্র রিকোয়েস্ট সফলভাবে জমা হয়েছে!')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  } finally {
                    setDialogState(() => submitting = false);
                  }
                },
                label: submitting ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('অনুরোধ পাঠান'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResubmitPaymentDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> user,
    required bool isMobile,
    required Future<void> Function(String method, String phone, String trxId) onSubmit,
  }) {
    String method = user['paymentMethod'] ?? 'বিকাশ (bKash)';
    final phoneCtrl = TextEditingController(text: user['senderPhone'] ?? user['phoneNumber'] ?? '');
    final trxCtrl = TextEditingController(text: user['transactionId'] ?? '');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('সঠিক পেমেন্ট TrxID পুনরায় জমা দিন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey('resubmit_method_$method'),
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'পেমেন্টের মাধ্যম', isDense: true),
                  items: ['বিকাশ (bKash)', 'নগদ (Nagad)', 'ইসলামী ব্যাংক পিএলসি'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setDialogState(() => method = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'প্রেরক মোবাইল নম্বর *', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: trxCtrl, decoration: const InputDecoration(labelText: 'সঠিক ট্রানজ্যাকশন আইডি (TrxID) *', isDense: true)),
              ],
            ),
          ),
          actions: [
            BouncingPressable(
              onTap: () => Navigator.pop(ctx),
              child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ),
            BouncingPressable(
              onTap: submitting ? null : () {},
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                onPressed: submitting ? null : () async {
                  if (trxCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক TrxID লিখুন।')));
                    return;
                  }
                  setDialogState(() => submitting = true);
                  try {
                    await onSubmit(method, phoneCtrl.text.trim(), trxCtrl.text.trim());
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পেমেন্ট তথ্য পুনরায় সফলভাবে জমা হয়েছে!')));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  } finally {
                    setDialogState(() => submitting = false);
                  }
                },
                child: submitting ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('জমা দিন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
