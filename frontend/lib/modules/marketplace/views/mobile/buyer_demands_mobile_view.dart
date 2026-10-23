import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/bouncing_pressable.dart';
import 'package:landtrust_app/core/animations/staggered_slide_fade.dart';
import 'package:landtrust_app/core/network/api_client.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import 'package:landtrust_app/core/widgets/account_status_lock_dialog.dart';
import '../../../member_portal/widgets/requirement_form_dialog.dart';
import '../../view_models/marketplace_view_model.dart';
import '../../widgets/seller_offer_dialog.dart';

class BuyerDemandsMobileView extends StatelessWidget {
  final MarketplaceViewModel viewModel;
  final VoidCallback onNavigateToAuth;

  const BuyerDemandsMobileView({
    super.key,
    required this.viewModel,
    required this.onNavigateToAuth,
  });

  void _handleOffer(BuildContext context, Map<String, dynamic> req) {
    final user = SessionManager.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('প্রস্তাব পাঠাতে প্রথমে লগইন করুন।')));
      onNavigateToAuth();
      return;
    }
    if ((user['accountStatus'] ?? 'PENDING') != 'ACTIVE') {
      AccountStatusLockDialog.show(context, user: user);
      return;
    }
    SellerOfferDialog.show(context, requirement: req, onSubmit: (notes, price, fee) => viewModel.sendSellerOffer(req['id'] as int, notes, price, fee));
  }

  void _handlePostDemand(BuildContext context) {
    final user = SessionManager.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('চাহিদা পোস্ট করতে প্রথমে লগইন বা নিবন্ধন করুন।')));
      onNavigateToAuth();
      return;
    }
    if ((user['accountStatus'] ?? 'PENDING') != 'ACTIVE') {
      AccountStatusLockDialog.show(context, user: user);
      return;
    }
    if (user['role'] == 'SELLER') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('চাহিদা পোস্ট করার সুবিধা ক্রেতাদের জন্য। বিক্রেতা হিসেবে আপনি নিচে প্রস্তাব পাঠাতে পারেন।')));
      return;
    }
    final locations = (viewModel.config['locations'] as List<dynamic>?) ?? [];
    final districts = locations.map((l) => l['districtNameBn'].toString()).toSet().toList();
    List<String> getUpazilas(String dist) => locations.where((l) => l['districtNameBn'] == dist).map((l) => l['upazilaNameBn'].toString()).toSet().toList();

    RequirementFormDialog.show(
      context,
      isMobile: true,
      districts: districts,
      getUpazilas: getUpazilas,
      rawLocations: locations,
      onSubmit: (p) async {
        await ApiClient.post('/member/buyer/requirements', body: p);
        await viewModel.loadInitialData();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আপনার জমি কেনার চাহিদা সফলভাবে নিবন্ধিত হয়েছে!')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reqs = viewModel.requirements;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0B4F32),
        foregroundColor: Colors.white,
        onPressed: () => _handlePostDemand(context),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('চাহিদা পোস্ট করুন', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0B4F32),
        onRefresh: () async => viewModel.loadInitialData(),
        child: reqs.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('বর্তমানে কোনো ক্রেতার চাহিদা নেই।', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
                itemCount: reqs.length,
                itemBuilder: (context, index) {
                  final map = reqs[index] as Map<String, dynamic>;
                  return StaggeredSlideFade(
                    index: index,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${map['preferredUpazila']}, ${map['preferredDistrict']}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                                child: Text(map['purchaseTimeline'] ?? 'জরুরি', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${map['landType']} জমি • ক্রেতা: ${map['buyerName']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F3), borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('বাজেট: ৳${map['minBudgetBdt']}–৳${map['maxBudgetBdt']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B4F32))),
                                const SizedBox(height: 2),
                                Text('পরিমাণ: ${map['minAreaDecimal']}–${map['maxAreaDecimal']} শতাংশ', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          BouncingPressable(
                            onTap: () => _handleOffer(context, map),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text('জমির প্রস্তাব পাঠান', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
