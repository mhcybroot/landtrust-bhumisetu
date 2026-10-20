import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

class HomeStatsRow extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isMobile;

  const HomeStatsRow({
    super.key,
    required this.stats,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cardWidth = isMobile ? ((constraints.maxWidth - 10) / 2).floorToDouble() : ((constraints.maxWidth - 36) / 4).floorToDouble();
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          StatCardWidget(
            title: 'অনুমোদিত বিজ্ঞাপন',
            value: '${stats['publishedListings'] ?? 0} টি',
            subtitle: 'যাচাইকৃত জমির তালিকা',
            color: const Color(0xFF0B4F32),
            width: cardWidth,
          ),
          StatCardWidget(
            title: 'ক্রেতার চাহিদা',
            value: '${stats['activeBuyerRequirements'] ?? 0} টি',
            subtitle: 'সরাসরি জমি ক্রয়ের আগ্রহ',
            color: const Color(0xFF1B5E20),
            width: cardWidth,
          ),
          StatCardWidget(
            title: 'মার্কেটিং অফিসার',
            value: '${stats['marketingOfficers'] ?? 14} জন',
            subtitle: 'মাঠ পর্যায়ের প্রতিনিধি',
            color: const Color(0xFF1A237E),
            width: cardWidth,
          ),
          StatCardWidget(
            title: 'কভারকৃত উপজেলা',
            value: '${stats['coveredUpazilas'] ?? 9} টি',
            subtitle: 'নোয়াখালী ও পার্শ্ববর্তী',
            color: const Color(0xFFE65100),
            width: cardWidth,
          ),
        ],
      );
    });
  }
}
