import 'package:flutter/material.dart';

class AdminCommunicationDialogs {
  /// নির্দিষ্ট সদস্যের কাছে ব্যক্তিগত নোটিফিকেশন পাঠানোর ডায়ালগ
  static void showSendNotificationDialog(
    BuildContext context, {
    required Map<String, dynamic> user,
    required bool isMobile,
    required Future<void> Function(String title, String message) onSubmit,
  }) {
    final titleCtrl = TextEditingController(text: 'LandApp থেকে গুরুত্বপূর্ণ বার্তা');
    final msgCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text('নোটিফিকেশন পাঠান (${user['fullName']})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'শিরোনাম (Title)', isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'বার্তা (Message)',
                    hintText: 'ইউজারের উদ্দেশে বিস্তারিত বার্তা লিখুন...',
                    isDense: true,
                  ),
                ),
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
                      final title = titleCtrl.text.trim();
                      final msg = msgCtrl.text.trim();
                      if (msg.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বার্তার বিবরণ খালি রাখা যাবে না')));
                        return;
                      }
                      setDialogState(() => submitting = true);
                      await onSubmit(title, msg);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সদস্যের কাছে নোটিফিকেশন সফলভাবে পাঠানো হয়েছে!')));
                      }
                    },
              child: submitting
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('পাঠিয়ে দিন'),
            ),
          ],
        ),
      ),
    );
  }

  /// প্ল্যাটফর্মের সকল সদস্যের জন্য জরুরি ঘোষণা ব্রডকাস্ট করার ডায়ালগ
  static void showBroadcastNotificationDialog(
    BuildContext context, {
    required bool isMobile,
    required Future<void> Function(String title, String message, String? role) onSubmit,
  }) {
    final titleCtrl = TextEditingController(text: 'জরুরি নোটিশ / ঘোষণা');
    final msgCtrl = TextEditingController();
    String targetRole = 'ALL';
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('সিস্টেম ব্রডকাস্ট নোটিশ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey('role_$targetRole'),
                  initialValue: targetRole,
                  decoration: const InputDecoration(labelText: 'প্রাপক গ্রুপ (Target Users)', isDense: true),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('সকল সদস্য (All Users)')),
                    DropdownMenuItem(value: 'MARKETING_OFFICER', child: Text('শুধুমাত্র অফিসারগণ')),
                    DropdownMenuItem(value: 'SELLER', child: Text('শুধুমাত্র বিক্রেতাগণ')),
                    DropdownMenuItem(value: 'BUYER', child: Text('শুধুমাত্র ক্রেতাগণ')),
                  ],
                  onChanged: (val) => setDialogState(() => targetRole = val ?? 'ALL'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'শিরোনাম (Title)', isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'ঘোষণার বিবরণ',
                    hintText: 'সকলের জন্য নোটিশের বিবরণ লিখুন...',
                    isDense: true,
                  ),
                ),
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
                      final title = titleCtrl.text.trim();
                      final msg = msgCtrl.text.trim();
                      if (msg.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('নোটিশের বিবরণ খালি রাখা যাবে না')));
                        return;
                      }
                      setDialogState(() => submitting = true);
                      await onSubmit(title, msg, targetRole);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সফলভাবে ব্রডকাস্ট করা হয়েছে!')));
                      }
                    },
              child: submitting
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('ব্রডকাস্ট করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
