import 'package:flutter/material.dart';

/// ক্যাটাগরি ও ফিল্টার নির্বাচনের জন্য মসৃণ স্লাইডিং পিল ট্রানজিশন বার।
class SlidingPillBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color activeColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final double height;

  const SlidingPillBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.activeColor = const Color(0xFF0B4F32),
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = Colors.black87,
    this.height = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final tabWidth = totalWidth / tabs.length;
        final safeIndex = selectedIndex.clamp(0, tabs.length - 1);

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Stack(
            children: [
              // স্লাইডিং পিল ব্যাকগ্রাউন্ড
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: safeIndex * tabWidth,
                top: 3,
                bottom: 3,
                width: tabWidth,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // ট্যাব টেক্সট লেবেলসমূহ
              Row(
                children: List.generate(tabs.length, (idx) {
                  final isSelected = idx == safeIndex;
                  return Expanded(
                    child: InkWell(
                      onTap: () => onTabSelected(idx),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? activeTextColor : inactiveTextColor,
                          ),
                          child: Text(tabs[idx], maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
