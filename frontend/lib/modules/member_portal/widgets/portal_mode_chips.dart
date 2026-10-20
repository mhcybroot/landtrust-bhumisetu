import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/horizontal_scroll_fade_view.dart';

class PortalModeChips extends StatelessWidget {
  final String currentMode;
  final String userRole;
  final int listingsCount;
  final int requirementsCount;
  final ValueChanged<String> onModeChanged;

  const PortalModeChips({
    super.key,
    required this.currentMode,
    required this.userRole,
    required this.listingsCount,
    required this.requirementsCount,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: HorizontalScrollFadeView(
        child: Row(
          children: [
            const Text(
              'মোড: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF0B4F32),
              ),
            ),
            if (userRole == 'MARKETING_OFFICER') ...[
              _chip('MARKETING_OFFICER', '📊 মার্কেটিং অফিসার'),
              const SizedBox(width: 6),
            ],
            _chip('BUYER', '🛒 ক্রেতা ($requirementsCount)'),
            const SizedBox(width: 6),
            _chip('SELLER', '🏞️ বিক্রেতা ($listingsCount)'),
          ],
        ),
      ),
    );
  }

  Widget _chip(String mode, String label) {
    final sel = currentMode == mode;
    return ChoiceChip(
      selected: sel,
      selectedColor: const Color(0xFF0B4F32),
      labelStyle: TextStyle(
        color: sel ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      label: Text(label),
      onSelected: (_) => onModeChanged(mode),
    );
  }
}
