import 'package:flutter/material.dart';

class RequirementFormDialog {
  static void show(
    BuildContext context, {
    Map<String, dynamic>? existing,
    required bool isMobile,
    required List<String> districts,
    required List<String> Function(String) getUpazilas,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    String landType = existing?['landType'] ?? 'আবাসিক';
    String district = existing?['preferredDistrict'] ?? (districts.isNotEmpty ? districts.first : 'নোয়াখালী');
    if (!districts.contains(district) && districts.isNotEmpty) district = districts.first;

    List<String> upazilas = getUpazilas(district);
    String upazila = existing?['preferredUpazila'] ?? (upazilas.isNotEmpty ? upazilas.first : 'নোয়াখালী সদর');
    if (!upazilas.contains(upazila) && upazilas.isNotEmpty) upazila = upazilas.first;

    final areaCtrl = TextEditingController(text: existing?['preferredArea'] ?? '');
    final minAreaCtrl = TextEditingController(text: existing?['minAreaDecimal']?.toString() ?? '5');
    final maxAreaCtrl = TextEditingController(text: existing?['maxAreaDecimal']?.toString() ?? '15');
    final minBudCtrl = TextEditingController(text: existing?['minBudgetBdt']?.toString() ?? '1000000');
    final maxBudCtrl = TextEditingController(text: existing?['maxBudgetBdt']?.toString() ?? '3000000');
    String timeline = existing?['purchaseTimeline'] ?? '১ মাসের মধ্যে';
    final purposeCtrl = TextEditingController(text: existing?['purpose'] ?? 'বাড়ি নির্মাণ');
    final reqsCtrl = TextEditingController(text: existing?['specialRequirements'] ?? 'নিষ্কণ্টক কাগজপত্র ও পাকা রাস্তা সংলগ্ন');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text(
            existing != null ? 'চাহিদা সম্পাদনা' : 'নতুন জমি ক্রয়ের চাহিদা নিবন্ধন',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SizedBox(
            width: isMobile ? double.infinity : 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _w(isMobile, DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: landType,
                        decoration: const InputDecoration(labelText: 'জমির ধরন', isDense: true),
                        items: ['আবাসিক', 'বাণিজ্যিক', 'কৃষি', 'ভিটা জমি', 'বাগান বাড়ি'].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setDialogState(() => landType = v!),
                      )),
                      _w(isMobile, DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: district,
                        decoration: const InputDecoration(labelText: 'পছন্দের জেলা', isDense: true),
                        items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) {
                          setDialogState(() {
                            district = v!;
                            upazilas = getUpazilas(district);
                            upazila = upazilas.first;
                          });
                        },
                      )),
                      _w(isMobile, DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: upazila,
                        decoration: const InputDecoration(labelText: 'পছন্দের উপজেলা', isDense: true),
                        items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setDialogState(() => upazila = v!),
                      )),
                      _w(isMobile, TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'নির্দিষ্ট এলাকা / পাড়া', isDense: true))),
                      _w(isMobile, TextField(controller: minAreaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ন্যূনতম শতাংশ *', isDense: true))),
                      _w(isMobile, TextField(controller: maxAreaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ শতাংশ *', isDense: true))),
                      _w(isMobile, TextField(controller: minBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন বাজেট (৳) *', isDense: true))),
                      _w(isMobile, TextField(controller: maxBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (৳) *', isDense: true))),
                      _w(isMobile, DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: timeline,
                        decoration: const InputDecoration(labelText: 'ক্রয়ের সময়সীমা', isDense: true),
                        items: ['জরুরি (৭ দিন)', '১ মাসের মধ্যে', '৩ মাসের মধ্যে', 'বাজেট অনুকূলে এলে'].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setDialogState(() => timeline = v!),
                      )),
                      _w(isMobile, TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'ব্যবহারের উদ্দেশ্য', isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: reqsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'বিশেষ শর্তাবলী বা চাহিদা', isDense: true)),
                ],
              ),
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
                          'landType': landType,
                          'preferredDistrict': district,
                          'preferredUpazila': upazila,
                          'preferredArea': areaCtrl.text.trim(),
                          'minAreaDecimal': double.tryParse(minAreaCtrl.text.trim()) ?? 0,
                          'maxAreaDecimal': double.tryParse(maxAreaCtrl.text.trim()) ?? 0,
                          'minBudgetBdt': double.tryParse(minBudCtrl.text.trim()) ?? 0,
                          'maxBudgetBdt': double.tryParse(maxBudCtrl.text.trim()) ?? 0,
                          'purchaseTimeline': timeline,
                          'purpose': purposeCtrl.text.trim(),
                          'specialRequirements': reqsCtrl.text.trim(),
                        });
                        if (context.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      } finally {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: submitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('জমা দিন'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _w(bool isMobile, Widget child) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final width = isMobile ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;
      return SizedBox(width: width, child: child);
    });
  }
}
