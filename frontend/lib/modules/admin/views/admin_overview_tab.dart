import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';
import '../view_models/admin_view_model.dart';

class AdminOverviewTab extends StatelessWidget {
  final AdminViewModel viewModel;
  final bool isMobile;

  const AdminOverviewTab({
    super.key,
    required this.viewModel,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final dash = viewModel.dashboard;
    final totalFunds = dash['totalFundsCollected'] ?? 0;
    final revFund = dash['platformRevenueFund'] ?? 0;
    final fieldFund = dash['fieldVerificationFund'] ?? 0;
    final reserveFund = dash['disputeReserveFund'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFundBuckets(totalFunds, revFund, fieldFund, reserveFund),
        const SizedBox(height: 20),
        _buildMetricsGrid(dash),
      ],
    );
  }

  Widget _buildFundBuckets(dynamic total, dynamic rev, dynamic field, dynamic reserve) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('৩-খাত প্রাতিষ্ঠানিক আর্থিক রিজার্ভ মডেল', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A2E1F))),
                Text('সর্বমোট সংগ্রহ: ৳$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B4F32))),
              ],
            ),
            const SizedBox(height: 4),
            const Text('স্বচ্ছতা ও দীর্ঘমেয়াদী স্থায়িত্বের জন্য প্রতিটি ফি এই অনুপাতে সংরক্ষিত থাকে।', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const Divider(height: 20),
            LayoutBuilder(builder: (ctx, constraints) {
              final cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  StatCardWidget(title: '১. প্ল্যাটফর্ম পরিচালনা আয় (৬০%)', value: '৳$rev', subtitle: 'সার্ভার ও অফিস পরিচালনা', color: const Color(0xFF0B4F32), width: cardWidth),
                  StatCardWidget(title: '২. সরজমিন যাচাই তহবিল (২৫%)', value: '৳$field', subtitle: 'মাঠ পরিদর্শন ও আমিন সার্ভে', color: const Color(0xFF1E88E5), width: cardWidth),
                  StatCardWidget(title: '৩. বিরোধ নিষ্পত্তি রিজার্ভ (১৫%)', value: '৳$reserve', subtitle: 'জরুরি আইনগত সুরক্ষা ও রিফান্ড', color: const Color(0xFFE65100), width: cardWidth),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> dash) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cardWidth = isMobile ? (constraints.maxWidth - 10) / 2 : (constraints.maxWidth - 36) / 4;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          StatCardWidget(title: 'মোট নিবন্ধিত সদস্য', value: '${dash['totalUsers'] ?? 0} জন', subtitle: 'ক্রেতা, বিক্রেতা ও অফিসার', color: const Color(0xFF0B4F32), width: cardWidth),
          StatCardWidget(title: 'যাচাইকৃত সক্রিয় সদস্য', value: '${dash['activeUsers'] ?? 0} জন', subtitle: 'অনুমোদিত একাউন্ট', color: const Color(0xFF1B5E20), width: cardWidth),
          StatCardWidget(title: 'মোট জমির বিজ্ঞাপন', value: '${dash['totalListings'] ?? 0} টি', subtitle: 'যাচাই ও প্রকাশিত', color: const Color(0xFF1565C0), width: cardWidth),
          StatCardWidget(title: 'সরাসরি ক্রেতার চাহিদা', value: '${dash['totalRequirements'] ?? 0} টি', subtitle: 'জমির ক্রয়ের আগ্রহ', color: const Color(0xFF6A1B9A), width: cardWidth),
          StatCardWidget(title: 'আগ্রহ প্রকাশ (Inquiries)', value: '${dash['totalInquiries'] ?? 0} টি', subtitle: 'ক্রেতা-বিক্রেতা সংযোগ', color: const Color(0xFF00695C), width: cardWidth),
          StatCardWidget(title: 'মোট কমিশন পরিশোধিত', value: '৳${dash['totalCommissionsPaid'] ?? 0}', subtitle: 'অফিসারদের বিতরণকৃত', color: const Color(0xFFAD1457), width: cardWidth),
        ],
      );
    });
  }
}
