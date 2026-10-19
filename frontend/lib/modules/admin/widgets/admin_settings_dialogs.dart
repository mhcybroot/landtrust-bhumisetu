import 'package:flutter/material.dart';

class AdminSettingsDialogs {
  static void showAddPaymentMethodDialog(
    BuildContext context, {
    required bool isMobile,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    final provCtrl = TextEditingController(text: 'বিকাশ (bKash)');
    final accCtrl = TextEditingController();
    String type = 'মার্চেন্ট / পেমেন্ট';
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('নতুন পেমেন্ট মেথড যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: provCtrl, decoration: const InputDecoration(labelText: 'প্রোভাইডার নাম *', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: accCtrl, decoration: const InputDecoration(labelText: 'একাউন্ট নম্বর *', isDense: true)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'একাউন্টের ধরন', isDense: true),
                  items: ['মার্চেন্ট / পেমেন্ট', 'ব্যক্তিগত (Personal)', 'এজেন্ট (Agent)', 'ব্যাংক হিসাব'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setDialogState(() => type = v!),
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
                      if (provCtrl.text.trim().isEmpty || accCtrl.text.trim().isEmpty) return;
                      setDialogState(() => submitting = true);
                      try {
                        await onSubmit({
                          'providerName': provCtrl.text.trim(),
                          'accountNumber': accCtrl.text.trim(),
                          'accountType': type,
                        });
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      } finally {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: const Text('যোগ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddLocationDialog(
    BuildContext context, {
    required bool isMobile,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    final distCtrl = TextEditingController(text: 'নোয়াখালী');
    final upzCtrl = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('নতুন জেলা / উপজেলা যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: distCtrl, decoration: const InputDecoration(labelText: 'জেলার নাম (বাংলা) *', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: upzCtrl, decoration: const InputDecoration(labelText: 'উপজেলার নাম (বাংলা) *', isDense: true)),
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
                      if (distCtrl.text.trim().isEmpty || upzCtrl.text.trim().isEmpty) return;
                      setDialogState(() => submitting = true);
                      try {
                        await onSubmit({
                          'districtNameBn': distCtrl.text.trim(),
                          'districtNameEn': distCtrl.text.trim(),
                          'upazilaNameBn': upzCtrl.text.trim(),
                          'upazilaNameEn': upzCtrl.text.trim(),
                        });
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      } finally {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: const Text('যোগ করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
