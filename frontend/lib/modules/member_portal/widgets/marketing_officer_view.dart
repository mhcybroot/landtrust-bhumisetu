import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:landtrust_app/core/network/api_client.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

class MarketingOfficerView extends StatelessWidget {
  final Map<String, dynamic> officerData;
  final bool isMobile;
  final VoidCallback onPayoutRequest;

  const MarketingOfficerView({
    super.key,
    required this.officerData,
    required this.isMobile,
    required this.onPayoutRequest,
  });

  @override
  Widget build(BuildContext context) {
    final code = officerData['referralCode'] ?? 'LT-NOA-XXXX';
    final shareLink = '${ApiClient.publicWebOrigin}/?ref=$code';
    final totalReferred = officerData['totalReferredCount'] ?? 0;
    final verifiedReferred = officerData['verifiedReferredCount'] ?? 0;
    final totalEarned = officerData['totalEarnedCommission'] ?? 0;
    final pendingPayable = officerData['pendingPayableCommission'] ?? 0;
    final referredUsers = (officerData['referredUsers'] as List<dynamic>?) ?? [];
    final commissions = (officerData['commissions'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReferralCard(context, code, shareLink),
        const SizedBox(height: 14),
        _buildOfficerStats(totalReferred, verifiedReferred, totalEarned, pendingPayable),
        const SizedBox(height: 18),
        _buildReferredUsers(referredUsers),
        const SizedBox(height: 18),
        _buildCommissionsLedger(commissions),
      ],
    );
  }

  Widget _buildReferralCard(BuildContext context, String code, String link) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('আপনার ইউনিক রেফারেল কোড ও লিংক', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4F32))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(child: SelectableText(link, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Color(0xFF0B4F32)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('রেফারেল লিংক ক্লিপবোর্ডে কপি হয়েছে!')));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerStats(dynamic totalRef, dynamic verRef, dynamic earned, dynamic pending) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cardWidth = isMobile ? (constraints.maxWidth - 10) / 2 : (constraints.maxWidth - 36) / 4;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          StatCardWidget(title: 'মোট রেফারেল', value: '$totalRef জন', subtitle: 'নিবন্ধনকারী সদস্য', color: const Color(0xFF0B4F32), width: cardWidth),
          StatCardWidget(title: 'যাচাইকৃত রেফারেল', value: '$verRef জন', subtitle: 'অ্যাক্টিভ সদস্য', color: const Color(0xFF1B5E20), width: cardWidth),
          StatCardWidget(title: 'মোট অর্জিত কমিশন', value: '৳$earned', subtitle: 'সর্বমোট পাওনা', color: const Color(0xFF1A237E), width: cardWidth),
          StatCardWidget(title: 'উইথড্রযোগ্য বকেয়া', value: '৳$pending', subtitle: 'তুলে নেওয়ার যোগ্য', color: const Color(0xFFE65100), width: cardWidth),
        ],
      );
    });
  }

  Widget _buildReferredUsers(List<dynamic> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('আমার রেফারেল সদস্যসমূহ (${users.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (users.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('এখনো আপনার কোড ব্যবহার করে কোনো সদস্য নিবন্ধন করেনি।')))
        else
          ...users.map((u) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.person, color: Color(0xFF0B4F32), size: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u['fullName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('${u['role']} • মোবাইল: ${u['phoneNumber']}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      StatusBadge(status: u['accountStatus']),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildCommissionsLedger(List<dynamic> commissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('কমিশন হিসেব ও লেজার (${commissions.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: onPayoutRequest,
              icon: const Icon(Icons.payments_outlined, size: 16),
              label: const Text('উইথড্র রিকোয়েস্ট', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (commissions.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('কোনো কমিশন এন্ট্রি পাওয়া যায়নি।')))
        else
          ...commissions.map((c) {
            final isPaid = c['status'] == 'PAID';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(isPaid ? Icons.check_circle : Icons.schedule, color: isPaid ? Colors.green : Colors.orange, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c['referredUserName']} — ${c['commissionType']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(c['note'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('৳${c['commissionAmountBdt']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                        Text(isPaid ? 'পরিশোধিত' : 'প্রাপ্য', style: TextStyle(fontSize: 10, color: isPaid ? Colors.green : Colors.deepOrange)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
