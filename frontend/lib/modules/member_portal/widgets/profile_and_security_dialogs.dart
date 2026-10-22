import 'package:flutter/material.dart';

class ProfileAndSecurityDialog {
  static void show(
    BuildContext context, {
    required Map<String, dynamic> user,
    required bool isMobile,
    required List<String> districts,
    required List<String> Function(String) getUpazilas,
    required Future<void> Function(String name, String district, String upazila, String address) onUpdateProfile,
    required Future<void> Function(String oldPass, String newPass) onChangePassword,
    Future<void> Function()? onDeleteAccount,
  }) {
    final nameCtrl = TextEditingController(text: user['fullName'] ?? '');
    String district = user['district']?.toString() ?? (districts.isNotEmpty ? districts.first : 'নোয়াখালী');
    if (!districts.contains(district) && districts.isNotEmpty) district = districts.first;

    List<String> upazilas = getUpazilas(district);
    String upazila = user['upazila']?.toString() ?? (upazilas.isNotEmpty ? upazilas.first : 'নোয়াখালী সদর');
    if (!upazilas.contains(upazila) && upazilas.isNotEmpty) upazila = upazilas.first;

    final addrCtrl = TextEditingController(text: user['address'] ?? '');
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool savingProfile = false;
    bool changingPass = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('প্রোফাইল ও নিরাপত্তা সেটিংস', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ব্যক্তিগত তথ্য আপডেট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B4F32))),
                  const SizedBox(height: 8),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'পূর্ণ নাম', isDense: true)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _w(isMobile, DropdownButtonFormField<String>(
                      value: district,
                      decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
                      items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          district = v!;
                          upazilas = getUpazilas(district);
                          upazila = upazilas.first;
                        });
                      },
                    )),
                    _w(isMobile, DropdownButtonFormField<String>(
                      value: upazila,
                      decoration: const InputDecoration(labelText: 'উপজেলা', isDense: true),
                      items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setDialogState(() => upazila = v!),
                    )),
                  ]),
                  const SizedBox(height: 8),
                  TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'বর্তমান ঠিকানা', isDense: true)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                      onPressed: savingProfile
                          ? null
                          : () async {
                              setDialogState(() => savingProfile = true);
                              try {
                                await onUpdateProfile(nameCtrl.text.trim(), district, upazila, addrCtrl.text.trim());
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('প্রোফাইল তথ্য সফলভাবে সংরক্ষিত হয়েছে!')));
                                  Navigator.pop(ctx);
                                }
                              } catch (e) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                              } finally {
                                setDialogState(() => savingProfile = false);
                              }
                            },
                      child: savingProfile ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('তথ্য সংরক্ষণ'),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text('পাসওয়ার্ড পরিবর্তন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B4F32))),
                  const SizedBox(height: 8),
                  TextField(controller: currentPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'বর্তমান পাসওয়ার্ড', isDense: true)),
                  const SizedBox(height: 8),
                  TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'নতুন পাসওয়ার্ড', isDense: true)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
                      onPressed: changingPass
                          ? null
                          : () async {
                              if (currentPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বর্তমান ও নতুন উভয় পাসওয়ার্ড লিখুন।')));
                                return;
                              }
                              setDialogState(() => changingPass = true);
                              try {
                                await onChangePassword(currentPassCtrl.text, newPassCtrl.text);
                                if (context.mounted) {
                                  currentPassCtrl.clear();
                                  newPassCtrl.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তিত হয়েছে!')));
                                }
                              } catch (e) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                              } finally {
                                setDialogState(() => changingPass = false);
                              }
                            },
                      child: changingPass ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('পাসওয়ার্ড পরিবর্তন'),
                    ),
                  ),
                  if (onDeleteAccount != null) ...[
                    const Divider(height: 24),
                    const Text('অ্যাকাউন্ট ও ডেটা ডিলিট (Danger Zone)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                    const SizedBox(height: 4),
                    const Text('প্লে স্টোর নীতি অনুযায়ী আপনি যেকোনো সময় আপনার অ্যাকাউন্ট ও যাবতীয় ডেটা মুছে ফেলতে পারেন।', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                      icon: const Icon(Icons.delete_forever_rounded, size: 16),
                      label: const Text('অ্যাকাউন্ট ডিলিট করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _confirmAccountDeletion(context, ctx, onDeleteAccount),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
          ],
        ),
      ),
    );
  }

  static void _confirmAccountDeletion(BuildContext context, BuildContext dialogCtx, Future<void> Function() onDelete) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('অ্যাকাউন্ট মুছে ফেলতে চান?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: const Text('আপনার প্রোফাইল, ফোন নম্বর ও সমস্ত ডেটা সার্ভার থেকে স্থায়ীভাবে অপসারিত হবে। এই প্রক্রিয়াটি অপরিবর্তনীয়।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(c);
              Navigator.pop(dialogCtx);
              try {
                await onDelete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অ্যাকাউন্ট সফলভাবে মুছে ফেলা হয়েছে।')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('হ্যাঁ, মুছে ফেলুন'),
          ),
        ],
      ),
    );
  }

  static Widget _w(bool isMobile, Widget child) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = isMobile ? constraints.maxWidth : (constraints.maxWidth - 8) / 2;
      return SizedBox(width: width, child: child);
    });
  }
}
