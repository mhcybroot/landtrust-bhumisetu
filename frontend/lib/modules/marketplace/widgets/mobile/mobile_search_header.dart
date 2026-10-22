import 'package:flutter/material.dart';
import '../../../../core/animations/bouncing_pressable.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/horizontal_scroll_fade_view.dart';

class MobileSearchHeader extends StatelessWidget {
  final TextEditingController searchCtrl;
  final VoidCallback onSearch;
  final VoidCallback onFilterClick;
  final List<String> districts;
  final String selectedDistrict;
  final ValueChanged<String> onDistrictSelected;
  final List<String> upazilas;
  final String selectedUpazila;
  final ValueChanged<String> onUpazilaSelected;

  const MobileSearchHeader({
    super.key,
    required this.searchCtrl,
    required this.onSearch,
    required this.onFilterClick,
    this.districts = const [],
    this.selectedDistrict = '',
    required this.onDistrictSelected,
    required this.upazilas,
    required this.selectedUpazila,
    required this.onUpazilaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    decoration: InputDecoration(
                      hintText: context.tr('search_hint'),
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF0B4F32)),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                searchCtrl.clear();
                                onSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BouncingPressable(
                onTap: onFilterClick,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4F32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          if (districts.isNotEmpty && districts.length > 1) ...[
            const SizedBox(height: 8),
            HorizontalScrollFadeView(
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF0B4F32)),
                  const SizedBox(width: 4),
                  _chip('সকল জেলা', selectedDistrict.isEmpty, () => onDistrictSelected('')),
                  ...districts.map((d) => _chip(d, selectedDistrict == d, () => onDistrictSelected(d))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          HorizontalScrollFadeView(
            child: Row(
              children: [
                _chip(context.tr('all_locations'), selectedUpazila.isEmpty, () => onUpazilaSelected('')),
                ...upazilas.map((u) => _chip(u, selectedUpazila == u, () => onUpazilaSelected(u))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: BouncingPressable(
        onTap: onTap,
        scaleFactor: 0.95,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0B4F32) : const Color(0xFFF1F5F3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? const Color(0xFF0B4F32) : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

