import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

class BuyerWorkspaceView extends StatelessWidget {
  final List<dynamic> myRequirements;
  final List<dynamic> myInquiries;
  final bool isMobile;
  final VoidCallback onAddRequirement;
  final VoidCallback onAddProposal;
  final ValueChanged<Map<String, dynamic>> onEditRequirement;
  final ValueChanged<int> onFulfillRequirement;

  const BuyerWorkspaceView({
    super.key,
    required this.myRequirements,
    required this.myInquiries,
    required this.isMobile,
    required this.onAddRequirement,
    required this.onAddProposal,
    required this.onEditRequirement,
    required this.onFulfillRequirement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10, runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('আমার জমি কেনার চাহিদা (${myRequirements.length})', style: TextStyle(fontSize: isMobile ? 17 : 19, fontWeight: FontWeight.bold)),
            Wrap(spacing: 8, runSpacing: 8, children: [
              BouncingPressable(
                onTap: onAddRequirement,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  onPressed: onAddRequirement,
                  icon: const Icon(Icons.post_add, size: 16),
                  label: const Text('নতুন চাহিদা দিন', style: TextStyle(fontSize: 12)),
                ),
              ),
              BouncingPressable(
                onTap: onAddProposal,
                child: OutlinedButton.icon(
                  onPressed: onAddProposal,
                  icon: const Icon(Icons.handshake, size: 16),
                  label: const Text('বিশেষ সেবা প্রস্তাব', style: TextStyle(fontSize: 12)),
                ),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 12),
        if (myRequirements.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('আপনি এখনো কোনো জমির চাহিদা নিবন্ধন করেননি।')))
        else
          ...myRequirements.map((r) {
            final reqItem = r as Map<String, dynamic>;
            final isFulfilled = reqItem['status'] == 'FULFILLED';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ধরন: ${reqItem['landType']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        StatusBadge(status: reqItem['status'] ?? 'PENDING'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('এলাকা: ${reqItem['preferredArea'] ?? ''}, ${reqItem['preferredUpazila']}, ${reqItem['preferredDistrict']}', style: const TextStyle(fontSize: 12.5)),
                    const SizedBox(height: 4),
                    Text('পরিমাণ: ${reqItem['minAreaDecimal']} - ${reqItem['maxAreaDecimal']} শতাংশ • বাজেট: ৳${reqItem['minBudgetBdt']} - ৳${reqItem['maxBudgetBdt']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0B4F32))),
                    const SizedBox(height: 4),
                    Text('উদ্দেশ্য: ${reqItem['purpose'] ?? ''} • সময়সীমা: ${reqItem['purchaseTimeline'] ?? ''}', style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        BouncingPressable(
                          onTap: () => onEditRequirement(reqItem),
                          child: OutlinedButton.icon(
                            onPressed: () => onEditRequirement(reqItem),
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text('সম্পাদনা (Edit)', style: TextStyle(fontSize: 11)),
                          ),
                        ),
                        if (!isFulfilled)
                          BouncingPressable(
                            onTap: () => onFulfillRequirement(reqItem['id'] as int),
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.green.shade800),
                              onPressed: () => onFulfillRequirement(reqItem['id'] as int),
                              icon: const Icon(Icons.check_circle_outline, size: 15),
                              label: const Text('চাহিদা পূরণ হয়েছে', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 18),
        const Text('আমার আগ্রহ প্রকাশের তালিকা (Inquiries)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (myInquiries.isEmpty)
          const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('হোম পেজ থেকে কোনো জমিতে আগ্রহ প্রকাশ করলে তা এখানে দেখা যাবে।')))
        else
          ...myInquiries.map((inq) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.connect_without_contact, color: Color(0xFF0B4F32), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inq['listingTitle'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('বাজেট: ৳${inq['offeredBudgetBdt']} • বার্তা: ${inq['message']}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      StatusBadge(status: inq['status']),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
