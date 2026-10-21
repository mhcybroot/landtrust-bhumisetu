import 'package:flutter/material.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import 'package:landtrust_app/core/widgets/account_status_lock_dialog.dart';
import '../../view_models/marketplace_view_model.dart';
import '../../widgets/seller_offer_dialog.dart';

class BuyerDemandsWebView extends StatelessWidget {
  final MarketplaceViewModel viewModel;
  final VoidCallback onNavigateToAuth;

  const BuyerDemandsWebView({
    super.key,
    required this.viewModel,
    required this.onNavigateToAuth,
  });

  void _handleOffer(BuildContext context, Map<String, dynamic> req) {
    final user = SessionManager.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('জমির প্রস্তাব পাঠাতে প্রথমে লগইন বা নিবন্ধন করুন।')),
      );
      onNavigateToAuth();
      return;
    }
    if ((user['accountStatus'] ?? 'PENDING') != 'ACTIVE') {
      AccountStatusLockDialog.show(context, user: user);
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
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“জমি কিনতে চাই” — ক্রেতাদের চাহিদা',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                      ),
                      SizedBox(height: 4),
                      Text('আপনার জমি ক্রেতার পছন্দের সাথে মিললে সরাসরি প্রস্তাব পাঠান।', style: TextStyle(color: Colors.black54, fontSize: 13)),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    onPressed: () {
                      final user = SessionManager.instance.currentUser;
                      if (user != null && (user['accountStatus'] ?? 'PENDING') != 'ACTIVE') {
                        AccountStatusLockDialog.show(context, user: user);
                      } else {
                        onNavigateToAuth();
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('চাহিদা নিবন্ধন করুন'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (reqs.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('বর্তমানে কোনো প্রকাশিত ক্রেতার চাহিদা নেই।')),
                  ),
                )
              else
                ...reqs.map((r) {
                  final map = r as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${map['preferredUpazila']}, ${map['preferredDistrict']} — ${map['landType']} জমি',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(12)),
                                child: Text(map['purchaseTimeline'] ?? 'জরুরি', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('এলাকা: ${map['preferredArea'] ?? 'উপজেলার যেকোনো এলাকা'} • ক্রেতা: ${map['buyerName']}'),
                          const SizedBox(height: 4),
                          Text('পরিমাণ: ${map['minAreaDecimal']}–${map['maxAreaDecimal']} শতাংশ • বাজেট: ৳${map['minBudgetBdt']}–৳${map['maxBudgetBdt']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('উদ্দেশ্য: ${map['purpose']} • শর্ত: ${map['specialRequirements'] ?? 'নিষ্কণ্টক কাগজপত্র'}'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                            onPressed: () => _handleOffer(context, map),
                            icon: const Icon(Icons.real_estate_agent_outlined, size: 16),
                            label: const Text('উপযুক্ত জমি আছে — প্রস্তাব পাঠান'),
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
