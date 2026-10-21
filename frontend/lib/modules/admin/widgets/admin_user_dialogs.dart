import 'package:flutter/material.dart';
import 'package:landtrust_app/core/utils/communication_utils.dart';

class AdminUserDialogs {
  static void showVerifyPaymentDialog(
    BuildContext context, {
    required Map<String, dynamic> user,
    required bool isMobile,
    required Future<void> Function(bool approve, String? note) onSubmit,
  }) {
    final noteCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text('পেমেন্ট যাচাই: ${user['fullName']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('মোবাইল: ${user['phoneNumber']} • ভূমিকা: ${user['role']}'),
                const SizedBox(height: 4),
                Text('মাধ্যম: ${user['paymentMethod']} • প্রেরক: ${user['senderPhone']}'),
                const SizedBox(height: 4),
                Text('TrxID: ${user['transactionId']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      icon: const Icon(Icons.chat, size: 14, color: Color(0xFF25D366)),
                      label: const Text('WhatsApp প্রুফ', style: TextStyle(fontSize: 11, color: Color(0xFF075E54))),
                      onPressed: () => CommunicationUtils.openPaymentVerificationChat(
                        phone: user['phoneNumber']?.toString() ?? '',
                        userName: user['fullName']?.toString() ?? '',
                        trxId: user['transactionId']?.toString() ?? '',
                        method: user['paymentMethod']?.toString(),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      icon: const Icon(Icons.phone, size: 14, color: Colors.blue),
                      label: const Text('কল দিন', style: TextStyle(fontSize: 11, color: Colors.blue)),
                      onPressed: () => CommunicationUtils.makePhoneCall(user['phoneNumber']?.toString() ?? ''),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'অ্যাডমিন নোট (ঐচ্ছিক)', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      await onSubmit(false, noteCtrl.text.trim());
                      if (context.mounted) Navigator.pop(ctx);
                    },
              child: const Text('বাতিল করুন (Reject)'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      await onSubmit(true, noteCtrl.text.trim());
                      if (context.mounted) Navigator.pop(ctx);
                    },
              child: submitting ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('অনুমোদন করুন (Approve)'),
            ),
          ],
        ),
      ),
    );
  }

  static void showResetPasswordDialog(
    BuildContext context, {
    required Map<String, dynamic> user,
    required bool isMobile,
    required Future<void> Function(String pass) onSubmit,
  }) {
    final passCtrl = TextEditingController(text: '123456');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text('পাসওয়ার্ড রিসেট (${user['fullName']})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: isMobile ? double.infinity : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('সদস্যের জন্য নতুন পাসওয়ার্ড সেট করুন:'),
                const SizedBox(height: 10),
                TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'নতুন পাসওয়ার্ড', isDense: true)),
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
                      await onSubmit(passCtrl.text.trim());
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড সফলভাবে রিসেট করা হয়েছে!')));
                      }
                    },
              child: const Text('রিসেট করুন'),
            ),
          ],
        ),
      ),
    );
  }

  static void showRefundFeeDialog(
    BuildContext context, {
    required Map<String, dynamic> user,
    required bool isMobile,
    required Future<void> Function(String reason, String trxId) onSubmit,
  }) {
    final reasonCtrl = TextEditingController(text: 'সদস্যের অনুরোধে নিবন্ধন ফি ফেরত');
    final trxCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text('নিবন্ধন ফি রিফান্ড (${user['fullName']})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: isMobile ? double.infinity : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'রিফান্ডের কারণ', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: trxCtrl, decoration: const InputDecoration(labelText: 'ফেরত পাঠানোর TrxID', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
              onPressed: submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      await onSubmit(reasonCtrl.text.trim(), trxCtrl.text.trim());
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('রিফান্ড রেকর্ড সফলভাবে সম্পন্ন হয়েছে!')));
                      }
                    },
              child: const Text('রিফান্ড নিশ্চিত করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
