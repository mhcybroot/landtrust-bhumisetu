import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

class MemberProposalsSection extends StatelessWidget {
  final List<dynamic> proposals;
  final bool isMobile;
  final Function(Map<String, dynamic>) onShowCertificate;

  const MemberProposalsSection({
    super.key,
    required this.proposals,
    required this.isMobile,
    required this.onShowCertificate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'বিশেষ সেবা প্রস্তাবনা (Custom Proposals)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (proposals.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('জমি কেনা বা বিক্রির জন্য বিশেষ চুক্তি প্রস্তাব দিলে এখানে দেখা যাবে।'),
            ),
          )
        else
          ...proposals.map((p) {
            final isAgreed = p['status'] == 'MUTUALLY_AGREED' || p['status'] == 'COMPLETED';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            p['proposalTitle'] ?? '',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        StatusBadge(status: p['status']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p['scopeDescription'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'প্রস্তাবিত পারিশ্রমিক: ৳${p['customerProposedFeeBdt']}${p['finalAgreedFeeBdt'] != null ? ' | চূড়ান্ত: ৳${p['finalAgreedFeeBdt']}' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0B4F32)),
                    ),
                    if (isAgreed) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => onShowCertificate(p as Map<String, dynamic>),
                        icon: const Icon(Icons.verified_outlined, size: 15),
                        label: const Text('চুক্তিপত্র সনদ দেখুন', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
