import 'package:flutter/material.dart';
import 'package:landtrust_app/core/utils/location_hierarchy_helper.dart';
import 'listing_payment_section.dart';

class ListingFormDialog {
  static void show(
    BuildContext context, {
    Map<String, dynamic>? existing,
    required bool isMobile,
    required List<String> districts,
    required List<String> Function(String) getUpazilas,
    List<dynamic>? rawLocations,
    Map<String, dynamic>? settings,
    List<dynamic>? paymentMethods,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    String landType = existing?['landType'] ?? 'আবাসিক';
    String district = existing?['district'] ?? (districts.isNotEmpty ? districts.first : 'নোয়াখালী');
    
    final locs = rawLocations ?? [];
    List<String> areas = locs.isNotEmpty ? LocationHierarchyHelper.getAllAreaNames(locs, district: district) : getUpazilas(district);
    if (areas.isEmpty) areas = ['নোয়াখালী সদর'];
    String upazila = existing?['upazila'] ?? areas.first;
    if (!areas.contains(upazila)) upazila = areas.first;

    List<String> subAreas = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreas(locs, upazila) : [];
    String subArea = existing?['subArea'] ?? (subAreas.isNotEmpty ? subAreas.first : '');
    if (subArea.isNotEmpty && !subAreas.contains(subArea)) subAreas.insert(0, subArea);

    final subAreaCtrl = TextEditingController(text: subArea);
    final areaNameCtrl = TextEditingController(text: existing?['areaName'] ?? '');
    final mouzaCtrl = TextEditingController(text: existing?['mouzaName'] ?? '');
    final areaDecCtrl = TextEditingController(text: existing?['areaDecimal']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: existing?['expectedPriceBdt']?.toString() ?? '');
    final roadCtrl = TextEditingController(text: existing?['roadAccessInfo'] ?? (existing != null ? '' : '১২ ফুট প্রশস্ত রাস্তা'));
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final imgCtrl = TextEditingController(text: existing?['imageUrl'] ?? '');
    final extraImgsCtrl = TextEditingController(text: existing?['additionalImageUrls'] ?? '');
    final videoCtrl = TextEditingController(text: existing?['videoUrl'] ?? '');
    final mapCtrl = TextEditingController(text: existing?['mapLink'] ?? '');
    final docCtrl = TextEditingController(text: existing?['privateDocumentUrl'] ?? '');

    bool isFeatured = existing?['isFeatured'] == true;
    final senderPhoneCtrl = TextEditingController(text: existing?['senderPhone'] ?? '');
    final trxIdCtrl = TextEditingController(text: existing?['transactionId'] ?? '');
    final methods = (paymentMethods != null && paymentMethods.isNotEmpty) ? paymentMethods : [{'providerName': 'বিকাশ (bKash)', 'accountNumber': '01711-889900'}];
    String selectedMethod = existing?['paymentMethod'] ?? methods.first['providerName'].toString();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final fee = LocationHierarchyHelper.calculateListingFee(settings: settings, landType: landType, isFeatured: isFeatured);
          final subAreaLabel = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreaLabel(locs, upazila) : 'ইউনিয়ন / ওয়ার্ড';

          final fields = <Widget>[
            DropdownButtonFormField<String>(
              key: ValueKey('lt_$landType'), initialValue: landType, isExpanded: true,
              decoration: const InputDecoration(labelText: 'প্রোপার্টির ধরন *', isDense: true),
              items: ['আবাসিক', 'কৃষি', 'ফ্ল্যাট / অ্যাপার্টমেন্ট', 'বাণিজ্যিক', 'ভিটা জমি', 'বাগান বাড়ি'].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setDialogState(() => landType = v!),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey('dist_$district'), initialValue: district, isExpanded: true,
              decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
              items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setDialogState(() {
                district = v!;
                areas = locs.isNotEmpty ? LocationHierarchyHelper.getAllAreaNames(locs, district: district) : getUpazilas(district);
                upazila = areas.first;
                subAreas = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreas(locs, upazila) : [];
                subArea = subAreas.isNotEmpty ? subAreas.first : '';
              }),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey('upz_${district}_$upazila'), initialValue: upazila, isExpanded: true,
              decoration: const InputDecoration(labelText: 'উপজেলা / পৌরসভা *', isDense: true),
              items: areas.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setDialogState(() {
                upazila = v!;
                subAreas = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreas(locs, upazila) : [];
                subArea = subAreas.isNotEmpty ? subAreas.first : '';
              }),
            ),
            if (subAreas.isNotEmpty)
              DropdownButtonFormField<String>(
                key: ValueKey('sub_${upazila}_$subArea'), initialValue: subArea.isNotEmpty ? subArea : subAreas.first, isExpanded: true,
                decoration: InputDecoration(labelText: '$subAreaLabel *', isDense: true),
                items: subAreas.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setDialogState(() => subArea = v!),
              )
            else
              TextField(controller: subAreaCtrl, onChanged: (v) => subArea = v, decoration: InputDecoration(labelText: '$subAreaLabel (যদি থাকে)', isDense: true)),
            TextField(controller: areaNameCtrl, decoration: const InputDecoration(labelText: 'গ্রাম / পাড়া / রোড নং *', isDense: true)),
            TextField(controller: mouzaCtrl, decoration: const InputDecoration(labelText: 'মৌজা ও জেএল নম্বর', isDense: true)),
            TextField(controller: areaDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পরিমাণ (শতাংশ বা স্কয়ার ফিট) *', isDense: true)),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রত্যাশিত মোট মূল্য (৳) *', isDense: true)),
            TextField(controller: roadCtrl, decoration: const InputDecoration(labelText: 'রাস্তার তথ্য', isDense: true)),
          ];

          final mediaFields = <Widget>[
            TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'মূল ছবির URL বা Base64', isDense: true)),
            TextField(controller: extraImgsCtrl, decoration: const InputDecoration(labelText: 'অতিরিক্ত ছবির URL (||| দিয়ে)', isDense: true)),
            TextField(controller: videoCtrl, decoration: const InputDecoration(labelText: 'ভিডিও লিংক (YouTube)', isDense: true)),
            TextField(controller: mapCtrl, decoration: const InputDecoration(labelText: 'Google Maps লিংক', isDense: true)),
          ];

          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: 12),
            title: Text(existing != null ? 'বিজ্ঞাপন সম্পাদনা' : 'নতুন জমি / ফ্ল্যাটের বিজ্ঞাপন জমা দিন', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SizedBox(
              width: isMobile ? double.infinity : 680,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'বিজ্ঞাপনের শিরোনাম *', isDense: true)),
                    const SizedBox(height: 10),
                    if (isMobile)
                      ...fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f))
                    else
                      Wrap(spacing: 10, runSpacing: 10, children: fields.map((f) => SizedBox(width: 325, child: f)).toList()),
                    const SizedBox(height: 10),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'বিস্তারিত বিবরণ', isDense: true)),
                    const SizedBox(height: 10),
                    if (isMobile)
                      ...mediaFields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 10), child: f))
                    else
                      Wrap(spacing: 10, runSpacing: 10, children: mediaFields.map((f) => SizedBox(width: 325, child: f)).toList()),
                    const SizedBox(height: 10),
                    TextField(controller: docCtrl, decoration: const InputDecoration(labelText: 'দলিলের লিংক (গোপন সংরক্ষিত)', isDense: true)),
                    const SizedBox(height: 14),
                    ListingPaymentSection(
                      feeAmount: fee, isFeatured: isFeatured,
                      onFeaturedChanged: (v) => setDialogState(() => isFeatured = v),
                      paymentMethods: methods, selectedMethod: selectedMethod,
                      onMethodChanged: (v) => setDialogState(() => selectedMethod = v),
                      senderPhoneCtrl: senderPhoneCtrl, trxIdCtrl: trxIdCtrl, isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actionsOverflowButtonSpacing: 8,
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                onPressed: submitting ? null : () async {
                  if (titleCtrl.text.trim().isEmpty || areaDecCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('শিরোনাম, পরিমাণ ও মূল্য পূরণ করুন।')));
                    return;
                  }
                  if (existing == null && (senderPhoneCtrl.text.trim().isEmpty || trxIdCtrl.text.trim().isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('লিস্টিং ফি প্রেরক নম্বর ও TrxID প্রদান করুন।')));
                    return;
                  }
                  setDialogState(() => submitting = true);
                  try {
                    await onSubmit({
                      'title': titleCtrl.text.trim(), 'landType': landType,
                      'district': district, 'upazila': upazila, 'subArea': subArea,
                      'areaName': areaNameCtrl.text.trim(), 'mouzaName': mouzaCtrl.text.trim(),
                      'areaDecimal': double.tryParse(areaDecCtrl.text.trim()) ?? 0,
                      'expectedPriceBdt': double.tryParse(priceCtrl.text.trim()) ?? 0,
                      'roadAccessInfo': roadCtrl.text.trim(), 'description': descCtrl.text.trim(),
                      'imageUrl': imgCtrl.text.trim(), 'additionalImageUrls': extraImgsCtrl.text.trim(),
                      'videoUrl': videoCtrl.text.trim(), 'mapLink': mapCtrl.text.trim(),
                      'privateDocumentUrl': docCtrl.text.trim(), 'isFeatured': isFeatured,
                      'listingFeeChargedBdt': fee, 'paymentMethod': selectedMethod,
                      'senderPhone': senderPhoneCtrl.text.trim(), 'transactionId': trxIdCtrl.text.trim(),
                    });
                    if (context.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  } finally {
                    setDialogState(() => submitting = false);
                  }
                },
                child: submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('জমা দিন'),
              ),
            ],
          );
        },
      ),
    );
  }
}
