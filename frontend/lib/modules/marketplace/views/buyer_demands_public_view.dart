import 'package:flutter/material.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import '../view_models/marketplace_view_model.dart';
import '../widgets/seller_offer_dialog.dart';

class BuyerDemandsPublicView extends StatelessWidget {
  final MarketplaceViewModel viewModel;
  final bool isMobile;
  final VoidCallback onNavigateToAuth;

  const BuyerDemandsPublicView({
    super.key,
    required this.viewModel,
    required this.isMobile,
    required this.onNavigateToAuth,
  });

  void _handleOffer(BuildContext context, Map<String, dynamic> req) {
    if (SessionManager.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('জমির প্রস্তাব পাঠাতে প্রথমে লগইন বা নিবন্ধন করুন।')),
      );
      onNavigateToAuth();
      return;
    }
    SellerOfferDialog.show(
      context,
      requirement: req,
      onSubmit: (notes, price, fee) => viewModel.sendSellerOffer(req['id'] as int, notes, price, fee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reqs = viewModel.requirements;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“জমি কিনতে চাই” — ক্রেতাদের চাহিদা',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0B4F32),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'আপনার জমি ক্রেতার পছন্দের সাথে মিললে সরাসরি প্রস্তাব পাঠান।',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4F32),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 10),
                    ),
                    onPressed: onNavigateToAuth,
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('চাহিদা নিবন্ধন করুন', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (reqs.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text('বর্তমানে কোনো প্রকাশিত ক্রেতার চাহিদা নেই।'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: onNavigateToAuth,
                            child: const Text('প্রথম চাহিদাটি নিবন্ধন করুন'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...reqs.map((r) {
                  final map = r as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 14 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${map['preferredUpazila']}, ${map['preferredDistrict']} — ${map['landType']} জমি',
                                  style: TextStyle(
                                    fontSize: isMobile ? 15 : 17,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0B4F32),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  map['purchaseTimeline'] ?? 'জরুরি',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('এলাকা: ${map['preferredArea'] ?? 'উপজেলার যেকোনো এলাকা'} • ক্রেতা: ${map['buyerName']}'),
                          const SizedBox(height: 4),
                          Text(
                            'পরিমাণ: ${map['minAreaDecimal']}–${map['maxAreaDecimal']} শতাংশ • বাজেট: ৳${map['minBudgetBdt']}–৳${map['maxBudgetBdt']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('উদ্দেশ্য: ${map['purpose']} • শর্ত: ${map['specialRequirements'] ?? 'নিষ্কণ্টক কাগজপত্র'}'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: isMobile ? double.infinity : null,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B4F32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              ),
                              onPressed: () => _handleOffer(context, map),
                              icon: const Icon(Icons.real_estate_agent_outlined, size: 16),
                              label: const Text('উপযুক্ত জমি আছে — প্রস্তাব পাঠান', style: TextStyle(fontSize: 12.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
