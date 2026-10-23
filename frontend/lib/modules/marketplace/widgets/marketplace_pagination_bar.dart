import 'package:flutter/material.dart';
import '../../../../core/animations/bouncing_pressable.dart';
import '../../../../core/animations/transitions/transitions.dart';

String _toBn(int n) {
  var s = '$n';
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  for (int i = 0; i < 10; i++) {
    s = s.replaceAll(en[i], bn[i]);
  }
  return s;
}

/// মার্কেটপ্লেস পেজিনেশন এবং জাম্প-টু-টপ অ্যানিমেটেড কন্ট্রোল
class MarketplacePaginationBar extends StatelessWidget {
  final int totalItems;
  final int itemsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onScrollToTop;

  const MarketplacePaginationBar({
    super.key,
    required this.totalItems,
    required this.itemsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    this.onScrollToTop,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / itemsPerPage).ceil().clamp(1, 999);
    if (totalItems <= itemsPerPage) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Center(
        child: PaginationPageSlide(
          pageNumber: currentPage,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentPage > 1)
                BouncingPressable(
                  onTap: () => onPageChanged(currentPage - 1),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.chevron_left_rounded, size: 20, color: Color(0xFF0B4F32)),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4F32),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B4F32).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'পৃষ্ঠা ${_toBn(currentPage)} / ${_toBn(totalPages)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              if (currentPage < totalPages)
                BouncingPressable(
                  onTap: () => onPageChanged(currentPage + 1),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF0B4F32)),
                  ),
                ),
              if (onScrollToTop != null) ...[
                const SizedBox(width: 12),
                BouncingPressable(
                  onTap: onScrollToTop,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, size: 18, color: Color(0xFF0B4F32)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
