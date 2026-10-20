import 'package:flutter/material.dart';

class ListingFormDialog {
  static void show(
    BuildContext context, {
    Map<String, dynamic>? existing,
    required bool isMobile,
    required List<String> districts,
    required List<String> Function(String) getUpazilas,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    String landType = existing?['landType'] ?? 'আবাসিক';
    String district = existing?['district'] ?? (districts.isNotEmpty ? districts.first : 'নোয়াখালী');
    if (!districts.contains(district) && districts.isNotEmpty) district = districts.first;

    List<String> upazilas = getUpazilas(district);
    String upazila = existing?['upazila'] ?? (upazilas.isNotEmpty ? upazilas.first : 'নোয়াখালী সদর');
    if (!upazilas.contains(upazila) && upazilas.isNotEmpty) upazila = upazilas.first;

    final areaNameCtrl = TextEditingController(text: existing?['areaName'] ?? '');
    final mouzaCtrl = TextEditingController(text: existing?['mouzaName'] ?? '');
    final areaDecCtrl = TextEditingController(text: existing?['areaDecimal']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: existing?['expectedPriceBdt']?.toString() ?? '');
    final roadCtrl = TextEditingController(text: existing?['roadAccessInfo'] ?? '১২ ফুট প্রশস্ত রাস্তা');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final imgCtrl = TextEditingController(text: existing?['imageUrl'] ?? '');
    final extraImgsCtrl = TextEditingController(text: existing?['additionalImageUrls'] ?? '');
    final videoCtrl = TextEditingController(text: existing?['videoUrl'] ?? '');
    final mapCtrl = TextEditingController(text: existing?['mapLink'] ?? '');
    final docCtrl = TextEditingController(text: existing?['privateDocumentUrl'] ?? '');
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: Text(
            existing != null ? 'বিজ্ঞাপন সম্পাদনা' : 'নতুন জমির বিজ্ঞাপন জমা দিন',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SizedBox(
            width: isMobile ? double.infinity : 680,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'বিজ্ঞাপনের শিরোনাম *', isDense: true)),
                  const SizedBox(height: 10),
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
                        decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
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
                        decoration: const InputDecoration(labelText: 'উপজেলা', isDense: true),
                        items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setDialogState(() => upazila = v!),
                      )),
                      _w(isMobile, TextField(controller: areaNameCtrl, decoration: const InputDecoration(labelText: 'গ্রাম / এলাকা *', isDense: true))),
                      _w(isMobile, TextField(controller: mouzaCtrl, decoration: const InputDecoration(labelText: 'মৌজা ও জেএল নম্বর', isDense: true))),
                      _w(isMobile, TextField(controller: areaDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'জমির পরিমাণ (শতাংশ) *', isDense: true))),
                      _w(isMobile, TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রত্যাশিত মোট মূল্য (৳) *', isDense: true))),
                      _w(isMobile, TextField(controller: roadCtrl, decoration: const InputDecoration(labelText: 'রাস্তার তথ্য', isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'বিস্তারিত বিবরণ', isDense: true)),
                  const SizedBox(height: 10),
                  TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'মূল ছবির URL বা Base64', isDense: true)),
                  const SizedBox(height: 10),
                  TextField(controller: extraImgsCtrl, decoration: const InputDecoration(labelText: 'অতিরিক্ত ছবির URL (||| দিয়ে আলাদা করুন)', isDense: true)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _w(isMobile, TextField(controller: videoCtrl, decoration: const InputDecoration(labelText: 'ভিডিও লিংক (YouTube)', isDense: true))),
                      _w(isMobile, TextField(controller: mapCtrl, decoration: const InputDecoration(labelText: 'Google Maps লিংক', isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: docCtrl, decoration: const InputDecoration(labelText: 'খতিয়ান / দলিলের লিংক (গোপন সংরক্ষিত)', isDense: true)),
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
                      if (titleCtrl.text.trim().isEmpty || areaDecCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('শিরোনাম, পরিমাণ ও মূল্য পূরণ করুন।')));
                        return;
                      }
                      setDialogState(() => submitting = true);
                      try {
                        await onSubmit({
                          'title': titleCtrl.text.trim(),
                          'landType': landType,
                          'district': district,
                          'upazila': upazila,
                          'areaName': areaNameCtrl.text.trim(),
                          'mouzaName': mouzaCtrl.text.trim(),
                          'areaDecimal': double.tryParse(areaDecCtrl.text.trim()) ?? 0,
                          'expectedPriceBdt': double.tryParse(priceCtrl.text.trim()) ?? 0,
                          'roadAccessInfo': roadCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'imageUrl': imgCtrl.text.trim(),
                          'additionalImageUrls': extraImgsCtrl.text.trim(),
                          'videoUrl': videoCtrl.text.trim(),
                          'mapLink': mapCtrl.text.trim(),
                          'privateDocumentUrl': docCtrl.text.trim(),
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
