import 'package:flutter/material.dart';

class AdvancedFiltersPanel extends StatelessWidget {
  final bool isMobile;
  final List<String> districts;
  final List<String> upazilas;
  final String selectedDistrict;
  final String selectedUpazila;
  final TextEditingController maxBudgetCtrl;
  final TextEditingController minAreaCtrl;
  final TextEditingController maxAreaCtrl;
  final Function(String) onDistrictChanged;
  final Function(String) onUpazilaChanged;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const AdvancedFiltersPanel({
    super.key,
    required this.isMobile,
    required this.districts,
    required this.upazilas,
    required this.selectedDistrict,
    required this.selectedUpazila,
    required this.maxBudgetCtrl,
    required this.minAreaCtrl,
    required this.maxAreaCtrl,
    required this.onDistrictChanged,
    required this.onUpazilaChanged,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final colWidth = isMobile ? (constraints.maxWidth - 10) / 2 : (constraints.maxWidth - 36) / 4;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          SizedBox(
            width: colWidth,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: selectedDistrict.isEmpty ? null : selectedDistrict,
              decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
              items: [
                const DropdownMenuItem(value: '', child: Text('সকল জেলা', overflow: TextOverflow.ellipsis)),
                ...districts.map((d) => DropdownMenuItem(value: d, child: Text(d, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => onDistrictChanged(v ?? ''),
            ),
          ),
          SizedBox(
            width: colWidth,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: upazilas.contains(selectedUpazila) && selectedUpazila.isNotEmpty ? selectedUpazila : null,
              decoration: const InputDecoration(labelText: 'উপজেলা', isDense: true),
              items: [
                const DropdownMenuItem(value: '', child: Text('সকল উপজেলা', overflow: TextOverflow.ellipsis)),
                ...upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => onUpazilaChanged(v ?? ''),
            ),
          ),
          SizedBox(
            width: colWidth,
            child: TextField(
              controller: maxBudgetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (৳)', isDense: true),
            ),
          ),
          SizedBox(
            width: colWidth,
            child: TextField(
              controller: minAreaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ন্যূনতম শতাংশ', isDense: true),
            ),
          ),
          SizedBox(
            width: colWidth,
            child: TextField(
              controller: maxAreaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'সর্বোচ্চ শতাংশ', isDense: true),
            ),
          ),
          SizedBox(
            width: colWidth,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4F32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: onSearch,
                    child: const Text('প্রয়োগ করুন'),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'রিসেট',
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  onPressed: onReset,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
