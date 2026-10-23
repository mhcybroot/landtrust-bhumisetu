import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

class MemberProposalsSection extends StatelessWidget {
  final List<dynamic> proposals;
  final bool isMobile;
  final Function(Map<String, dynamic>) onShowCertificate;
  final Function(int id, String action)? onRespondProposal;

  const MemberProposalsSection({
    super.key,
    required this.proposals,
    required this.isMobile,
    required this.onShowCertificate,
    this.onRespondProposal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('বিশেষ সেবা প্রস্তাবনা (Custom Proposals)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (proposals.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('জমি কেনা বা বিক্রির জন্য বিশেষ চুক্তি প্রস্তাব দিলে এখানে দেখা যাবে।')))
        else
          ...proposals.map((p) {
            final status = (p['status'] ?? '').toString().toUpperCase();
            final isAgreed = status == 'MUTUALLY_AGREED' || status == 'AGREE' || status == 'AGREED' || status == 'COMPLETED';
            final counterFee = p['adminCounterFeeBdt'];
            final hasCounter = counterFee != null && !isAgreed;

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
                        Expanded(child: Text(p['proposalTitle'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                        StatusBadge(status: p['status']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(p['scopeDescription'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(
                      'প্রস্তাবিত পারিশ্রমিক: ৳${p['customerProposedFeeBdt']}${p['finalAgreedFeeBdt'] != null ? ' | চূড়ান্ত: ৳${p['finalAgreedFeeBdt']}' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0B4F32)),
                    ),
                    if (hasCounter) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade300)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('অ্যাডমিনের পাল্টা প্রস্তাব: ৳$counterFee', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFB45309))),
                            if (p['adminNote'] != null && p['adminNote'].toString().isNotEmpty)
                              Text('মন্তব্য: ${p['adminNote']}', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                            if (onRespondProposal != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  BouncingPressable(
                                    onTap: () => onRespondProposal!(p['id'] as int, 'ACCEPT'),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                                      onPressed: () => onRespondProposal!(p['id'] as int, 'ACCEPT'),
                                      child: const Text('পাল্টা প্রস্তাবে সম্মত', style: TextStyle(fontSize: 11)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BouncingPressable(
                                    onTap: () => onRespondProposal!(p['id'] as int, 'REJECT'),
                                    child: OutlinedButton(
                                      onPressed: () => onRespondProposal!(p['id'] as int, 'REJECT'),
                                      child: const Text('প্রত্যাখ্যান', style: TextStyle(fontSize: 11)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (isAgreed) ...[
                      const SizedBox(height: 8),
                      BouncingPressable(
                        onTap: () => onShowCertificate(p as Map<String, dynamic>),
                        child: OutlinedButton.icon(
                          onPressed: () => onShowCertificate(p as Map<String, dynamic>),
                          icon: const Icon(Icons.verified_outlined, size: 15),
                          label: const Text('চুক্তিপত্র সনদ দেখুন', style: TextStyle(fontSize: 11)),
                        ),
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
