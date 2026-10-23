import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/utils/location_hierarchy_helper.dart';

class RequirementFormDialog {
  static void show(
    BuildContext context, {
    Map<String, dynamic>? existing,
    required bool isMobile,
    required List<String> districts,
    required List<String> Function(String) getUpazilas,
    List<dynamic>? rawLocations,
    required Future<void> Function(Map<String, dynamic> payload) onSubmit,
  }) {
    String landType = existing?['landType'] ?? 'আবাসিক';
    String district = existing?['preferredDistrict'] ?? (districts.isNotEmpty ? districts.first : 'নোয়াখালী');

    final locs = rawLocations ?? [];
    List<String> areas = locs.isNotEmpty ? LocationHierarchyHelper.getAllAreaNames(locs, district: district) : getUpazilas(district);
    if (areas.isEmpty) areas = ['নোয়াখালী সদর'];
    String upazila = existing?['preferredUpazila'] ?? areas.first;
    if (!areas.contains(upazila)) upazila = areas.first;

    List<String> subAreas = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreas(locs, upazila) : [];
    String subArea = existing?['subArea'] ?? (subAreas.isNotEmpty ? subAreas.first : '');
    if (subArea.isNotEmpty && !subAreas.contains(subArea)) subAreas.insert(0, subArea);

    final bool isEdit = existing != null;
    final areaCtrl = TextEditingController(text: existing?['preferredArea'] ?? '');
    final minAreaCtrl = TextEditingController(text: existing?['minAreaDecimal']?.toString() ?? (isEdit ? '' : '5'));
    final maxAreaCtrl = TextEditingController(text: existing?['maxAreaDecimal']?.toString() ?? (isEdit ? '' : '15'));
    final minBudCtrl = TextEditingController(text: existing?['minBudgetBdt']?.toString() ?? (isEdit ? '' : '1000000'));
    final maxBudCtrl = TextEditingController(text: existing?['maxBudgetBdt']?.toString() ?? (isEdit ? '' : '3000000'));
    String timeline = existing?['purchaseTimeline'] ?? '১ মাসের মধ্যে';
    final purposeCtrl = TextEditingController(text: existing?['purpose'] ?? (isEdit ? '' : 'বাড়ি নির্মাণ'));
    final reqsCtrl = TextEditingController(text: existing?['specialRequirements'] ?? (isEdit ? '' : 'নিষ্কণ্টক কাগজপত্র ও পাকা রাস্তা সংলগ্ন'));
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final subAreaLabel = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreaLabel(locs, upazila) : 'ইউনিয়ন / ওয়ার্ড';

          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
            title: Text(existing != null ? 'চাহিদা সম্পাদনা' : 'নতুন জমি / ফ্ল্যাট ক্রয়ের চাহিদা নিবন্ধন', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: SizedBox(
              width: isMobile ? double.infinity : 620,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: [
                        _w(isMobile, DropdownButtonFormField<String>(
                          key: ValueKey('req_lt_$landType'), initialValue: landType, isExpanded: true,
                          decoration: const InputDecoration(labelText: 'প্রোপার্টির ধরন *', isDense: true),
                          items: ['আবাসিক', 'কৃষি', 'ফ্ল্যাট / অ্যাপার্টমেন্ট', 'বাণিজ্যিক', 'ভিটা জমি', 'বাগান বাড়ি'].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) => setDialogState(() => landType = v!),
                        )),
                        _w(isMobile, DropdownButtonFormField<String>(
                          key: ValueKey('req_dist_$district'), initialValue: district, isExpanded: true,
                          decoration: const InputDecoration(labelText: 'পছন্দের জেলা *', isDense: true),
                          items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) => setDialogState(() {
                            district = v!;
                            areas = locs.isNotEmpty ? LocationHierarchyHelper.getAllAreaNames(locs, district: district) : getUpazilas(district);
                            upazila = areas.first;
                            subAreas = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreas(locs, upazila) : [];
                            subArea = subAreas.isNotEmpty ? subAreas.first : '';
                          }),
                        )),
                        _w(isMobile, DropdownButtonFormField<String>(
                          key: ValueKey('req_upz_${district}_$upazila'), initialValue: upazila, isExpanded: true,
                          decoration: const InputDecoration(labelText: 'পছন্দের উপজেলা *', isDense: true),
                          items: areas.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) => setDialogState(() {
                            upazila = v!;
                            subAreas = locs.isNotEmpty ? LocationHierarchyHelper.getSubAreas(locs, upazila) : [];
                            subArea = subAreas.isNotEmpty ? subAreas.first : '';
                          }),
                        )),
                        if (subAreas.isNotEmpty)
                          _w(isMobile, DropdownButtonFormField<String>(
                            key: ValueKey('req_sub_${upazila}_$subArea'), initialValue: subArea.isNotEmpty ? subArea : subAreas.first, isExpanded: true,
                            decoration: InputDecoration(labelText: '$subAreaLabel (পছন্দের এলাকা)', isDense: true),
                            items: subAreas.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                            onChanged: (v) => setDialogState(() => subArea = v!),
                          ))
                        else
                          _w(isMobile, TextField(controller: areaCtrl, onChanged: (v) => subArea = v, decoration: InputDecoration(labelText: '$subAreaLabel (যদি নির্দিষ্ট থাকে)', isDense: true))),
                        _w(isMobile, TextField(controller: minAreaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন পরিমাণ (শতাংশ/স্কয়ার ফিট) *', isDense: true))),
                        _w(isMobile, TextField(controller: maxAreaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ পরিমাণ (শতাংশ/স্কয়ার ফিট) *', isDense: true))),
                        _w(isMobile, TextField(controller: minBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন বাজেট (৳) *', isDense: true))),
                        _w(isMobile, TextField(controller: maxBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (৳) *', isDense: true))),
                        _w(isMobile, DropdownButtonFormField<String>(
                          key: ValueKey('timeline_$timeline'), initialValue: timeline, isExpanded: true,
                          decoration: const InputDecoration(labelText: 'ক্রয়ের সময়সীমা', isDense: true),
                          items: ['জরুরি (৭ দিনের মধ্যে)', '১ মাসের মধ্যে', '৩ মাসের মধ্যে', '৬ মাসের মধ্যে'].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (v) => setDialogState(() => timeline = v!),
                        )),
                        _w(isMobile, TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'ব্যবহারের উদ্দেশ্য', isDense: true))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: reqsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'বিশেষ কোনো চাহিদা বা শর্ত', isDense: true)),
                  ],
                ),
              ),
            ),
            actions: [
              BouncingPressable(onTap: () => Navigator.pop(ctx), child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল'))),
              BouncingPressable(
                onTap: submitting ? null : () {},
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                  onPressed: submitting ? null : () async {
                    if (minBudCtrl.text.trim().isEmpty || maxBudCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বাজেটের তথ্য পূরণ করুন।')));
                      return;
                    }
                    setDialogState(() => submitting = true);
                    try {
                      await onSubmit({
                        'landType': landType,
                        'preferredDistrict': district,
                        'preferredUpazila': upazila,
                        'preferredArea': areaCtrl.text.trim().isNotEmpty ? (subArea.isNotEmpty ? '$subArea, ${areaCtrl.text.trim()}' : areaCtrl.text.trim()) : subArea,
                        'minAreaDecimal': double.tryParse(minAreaCtrl.text.trim()) ?? 1,
                        'maxAreaDecimal': double.tryParse(maxAreaCtrl.text.trim()) ?? 10,
                        'minBudgetBdt': double.tryParse(minBudCtrl.text.trim()) ?? 500000,
                        'maxBudgetBdt': double.tryParse(maxBudCtrl.text.trim()) ?? 2000000,
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
                  child: submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('নিবন্ধন করুন'),
                ),
              ),
            ],
          );
        },
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
