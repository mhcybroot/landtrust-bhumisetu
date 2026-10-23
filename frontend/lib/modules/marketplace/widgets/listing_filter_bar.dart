import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/transitions/transition_aliases.dart';
import 'package:landtrust_app/core/widgets/horizontal_scroll_fade_view.dart';
import 'advanced_filters_panel.dart';

class ListingFilterBar extends StatelessWidget {
  final bool isMobile;
  final List<String> districts;
  final List<String> upazilas;
  final String selectedDistrict;
  final String selectedUpazila;
  final String selectedLandType;
  final String selectedVerification;
  final bool filtersExpanded;
  final TextEditingController searchCtrl;
  final TextEditingController maxBudgetCtrl;
  final TextEditingController minAreaCtrl;
  final TextEditingController maxAreaCtrl;
  final Function(String) onDistrictChanged;
  final Function(String) onUpazilaChanged;
  final Function(String) onLandTypeSelected;
  final Function(String) onVerificationSelected;
  final VoidCallback onToggleExpanded;
  final VoidCallback onSearch;
  final VoidCallback onReset;

  const ListingFilterBar({
    super.key,
    required this.isMobile,
    required this.districts,
    required this.upazilas,
    required this.selectedDistrict,
    required this.selectedUpazila,
    required this.selectedLandType,
    required this.selectedVerification,
    required this.filtersExpanded,
    required this.searchCtrl,
    required this.maxBudgetCtrl,
    required this.minAreaCtrl,
    required this.maxAreaCtrl,
    required this.onDistrictChanged,
    required this.onUpazilaChanged,
    required this.onLandTypeSelected,
    required this.onVerificationSelected,
    required this.onToggleExpanded,
    required this.onSearch,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'মৌজা / এলাকা / দাগ নং / বিবরণ...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0B4F32)),
                      isDense: true,
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                searchCtrl.clear();
                                onSearch();
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 14 : 20,
                      vertical: isMobile ? 12 : 14,
                    ),
                  ),
                  onPressed: onSearch,
                  child: const Text('খুঁজুন'),
                ),
              ],
            ),
            if (districts.length > 1) ...[
              const SizedBox(height: 10),
              HorizontalScrollFadeView(
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF0B4F32)),
                    const SizedBox(width: 6),
                    _chip('সকল জেলা', selectedDistrict.isEmpty, () => onDistrictChanged('')),
                    ...districts.map((d) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _chip(d, selectedDistrict == d, () => onDistrictChanged(d)),
                        )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            HorizontalScrollFadeView(
              child: Row(
                children: [
                  _chip('সকল প্রোপার্টি', selectedLandType.isEmpty && selectedVerification.isEmpty, () => onLandTypeSelected('')),
                  const SizedBox(width: 6),
                  _chip('🟢 সরেজমিনে যাচাইকৃত', selectedVerification == 'FIELD_VERIFIED', () => onVerificationSelected('FIELD_VERIFIED')),
                  const SizedBox(width: 6),
                  _chip('আবাসিক', selectedLandType == 'আবাসিক', () => onLandTypeSelected('আবাসিক')),
                  const SizedBox(width: 6),
                  _chip('🏢 ফ্ল্যাট', selectedLandType == 'ফ্ল্যাট', () => onLandTypeSelected('ফ্ল্যাট')),
                  const SizedBox(width: 6),
                  _chip('বাণিজ্যিক', selectedLandType == 'বাণিজ্যিক', () => onLandTypeSelected('বাণিজ্যিক')),
                  const SizedBox(width: 6),
                  _chip('কৃষি', selectedLandType == 'কৃষি', () => onLandTypeSelected('কৃষি')),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF0B4F32), padding: const EdgeInsets.symmetric(horizontal: 8)),
                    onPressed: onToggleExpanded,
                    icon: Icon(filtersExpanded ? Icons.tune : Icons.filter_alt_outlined, size: 16),
                    label: Text(
                      filtersExpanded ? 'ফিল্টার লুকান' : 'আরও ফিল্টার (জেলা/বাজেট)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            if (filtersExpanded) ...[
              const Divider(height: 18),
              AdvancedFiltersPanel(
                isMobile: isMobile,
                districts: districts,
                upazilas: upazilas,
                selectedDistrict: selectedDistrict,
                selectedUpazila: selectedUpazila,
                maxBudgetCtrl: maxBudgetCtrl,
                minAreaCtrl: minAreaCtrl,
                maxAreaCtrl: maxAreaCtrl,
                onDistrictChanged: onDistrictChanged,
                onUpazilaChanged: onUpazilaChanged,
                onSearch: onSearch,
                onReset: onReset,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return SearchFilterTagSlide(
      isSelected: sel,
      child: ChoiceChip(
        label: Text(label),
        selected: sel,
        selectedColor: const Color(0xFF0B4F32),
        labelStyle: TextStyle(
          color: sel ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
