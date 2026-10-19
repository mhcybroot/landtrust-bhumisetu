import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class MemberDashboardScreen extends StatefulWidget {
  final VoidCallback onRefreshParent;

  const MemberDashboardScreen({super.key, required this.onRefreshParent});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  bool _loading = true;
  Map<String, dynamic>? _officerDashboard;
  List<dynamic> _myListings = [];
  List<dynamic> _myRequirements = [];
  List<dynamic> _myInquiries = [];
  List<dynamic> _myProposals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      await ApiService.refreshMe();
      final role = ApiService.currentUser?['role'] ?? 'BUYER';
      if (role == 'MARKETING_OFFICER') {
        _officerDashboard = await ApiService.getOfficerDashboard();
      } else if (role == 'SELLER') {
        _myListings = await ApiService.getMyListings();
        _myProposals = await ApiService.getMyProposals();
      } else if (role == 'BUYER') {
        _myRequirements = await ApiService.getMyRequirements();
        _myInquiries = await ApiService.getMyInquiries();
        _myProposals = await ApiService.getMyProposals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    if (user == null) {
      return const Center(child: Text('দয়া করে প্রথমে লগইন করুন।'));
    }

    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
    }

    final role = user['role'] as String? ?? 'BUYER';
    final status = user['accountStatus'] as String? ?? 'PAYMENT_SUBMITTED';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B4F32), Color(0xFF146C43)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user, color: Colors.amberAccent, size: 26),
                            const SizedBox(width: 8),
                            Text(
                              user['fullName'] ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ভূমিকা: ${_roleBangla(role)}  •  মোবাইল: ${user['phoneNumber']}  •  উপজেলা: ${user['upazila'] ?? 'নোয়াখালী সদর'}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        if (user['referredByCode'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'রেফারেল কোড ব্যবহৃত: ${user['referredByCode']} (${user['referredByOfficerName'] ?? ''})',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _statusChip(status),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B4F32),
                          ),
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('রিফ্রেশ'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (status != 'ACTIVE') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade600),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'আপনার নিবন্ধন ফি (৳${user['registrationFeeAmount']}) এবং TrxID (${user['transactionId']}) বর্তমানে অ্যাডমিন যাচাই করছেন। অনুমোদনের পর আপনার অ্যাকাউন্ট সম্পূর্ণ সক্রিয় (ACTIVE) হবে।',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              if (role == 'MARKETING_OFFICER') _buildMarketingOfficerView(),
              if (role == 'SELLER') _buildSellerView(),
              if (role == 'BUYER') _buildBuyerView(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MARKETING OFFICER VIEW ====================
  Widget _buildMarketingOfficerView() {
    final data = _officerDashboard ?? {};
    final code = data['referralCode'] ?? ApiService.currentUser?['myReferralCode'] ?? 'LT-NOA-XXXX';
    final totalReferred = data['totalReferredCount'] ?? 0;
    final verifiedReferred = data['verifiedReferredCount'] ?? 0;
    final totalEarned = data['totalEarnedCommission'] ?? 0;
    final totalPaid = data['totalPaidCommission'] ?? 0;
    final pendingPayable = data['pendingPayableCommission'] ?? 0;
    final referredUsers = (data['referredUsers'] as List<dynamic>?) ?? [];
    final commissions = (data['commissions'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Referral Code Banner
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'আপনার ইউনিক রেফারেল কোড (Referral Code)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'জমির ক্রেতা বা বিক্রেতা নিবন্ধনের সময় এই রেফারেল কোডটি ব্যবহার করলে স্বয়ংক্রিয়ভাবে আপনার তালিকায় নাম ও কমিশন যুক্ত হবে।',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF0B4F32), width: 1.5),
                      ),
                      child: SelectableText(
                        code.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Color(0xFF0B4F32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4F32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code.toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('রেফারেল কোড ($code) কপি করা হয়েছে!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('কোড কপি করুন'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 4 KPI Cards
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _kpiCard('মোট রেফারকৃত সদস্য', '$totalReferred জন', Icons.people_alt, Colors.blue.shade700),
            _kpiCard('যাচাইকৃত সক্রিয় সদস্য', '$verifiedReferred জন', Icons.verified, Colors.green.shade700),
            _kpiCard('মোট অর্জিত সম্মানী', '৳$totalEarned', Icons.account_balance_wallet, Colors.teal.shade800),
            _kpiCard('বকেয়া প্রাপ্য সম্মানী (Payable)', '৳$pendingPayable (পরিশোধিত: ৳$totalPaid)', Icons.payments, Colors.deepOrange.shade700),
          ],
        ),
        const SizedBox(height: 24),

        // Referred Users List (Name, Role, Status, Commission earned from them)
        const Text(
          '১. আপনার রেফারেল কোড ব্যবহার করে নিবন্ধনকারী ক্রেতা ও বিক্রেতাদের তালিকা',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (referredUsers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('এখনো আপনার রেফারেল কোড ব্যবহার করে কেউ নিবন্ধন করেননি।'),
            ),
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: referredUsers.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = referredUsers[i] as Map<String, dynamic>;
                final uStatus = u['accountStatus'] ?? 'PAYMENT_SUBMITTED';
                final earned = u['commissionEarnedFromUser'] ?? 0;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Icon(
                      u['role'] == 'SELLER' ? Icons.landscape : Icons.person_search,
                      color: const Color(0xFF0B4F32),
                    ),
                  ),
                  title: Text(
                    '${u['fullName']} (${_roleBangla(u['role'])})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('উপজেলা: ${u['upazila'] ?? 'নোয়াখালী'} • মোবাইল: ${u['phoneNumber']}'),
                  trailing: Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _statusChip(uStatus),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade300),
                        ),
                        child: Text(
                          'অর্জিত কমিশন: ৳$earned',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 24),
        // Commission Ledger History
        const Text(
          '২. আপনার সম্মানী ও কমিশনের বিস্তারিত হিসাব (নিবন্ধন বোনাস ও ডিল কমিশন)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (commissions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('এখনো কোনো কমিশন রেকর্ড জমা হয়নি।'),
            ),
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commissions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = commissions[i] as Map<String, dynamic>;
                final isPaid = c['status'] == 'PAID';
                final cType = c['commissionType'] == 'REFERRAL_VERIFIED_FIXED'
                    ? 'যাচাইকৃত নিবন্ধন সম্মানী (Fixed)'
                    : c['commissionType'] == 'DEAL_CLOSURE_PERCENT'
                        ? 'সফল লেনদেন কমিশন (${c['percentageRate']}%)'
                        : 'সফল লেনদেন কমিশন (Fixed)';
                return ListTile(
                  leading: Icon(
                    isPaid ? Icons.check_circle : Icons.schedule,
                    color: isPaid ? Colors.green : Colors.orange,
                    size: 30,
                  ),
                  title: Text(
                    'গ্রাহক: ${c['referredUserName']} (${_roleBangla(c['referredUserRole'])}) — $cType',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${c['note'] ?? ''}${c['paymentReference'] != null ? ' • পেমেন্ট রেফারেন্স: ${c['paymentReference']}' : ''}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳${c['commissionAmountBdt']}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                      ),
                      Text(
                        isPaid ? 'পরিশোধিত (PAID)' : 'প্রাপ্য (PAYABLE)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? Colors.green.shade700 : Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 24),
        // Training & Guidelines Card
        Card(
          color: const Color(0xFFF4FBF7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '৩. মার্কেটিং অফিসার নির্দেশনা ও সম্মানীর নীতিমালা',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                ),
                SizedBox(height: 8),
                Text('• জমির মালিক (বিক্রেতা) এবং ক্রেতাকে নিবন্ধনের সময় আপনার রেফারেল কোডটি দিতে বলুন।'),
                Text('• গ্রাহক নিবন্ধন ফি পরিশোধ করে অ্যাডমিন কর্তৃক যাচাইকৃত (ACTIVE) হলে আপনার নিবন্ধন সম্মানী স্বয়ংক্রিয়ভাবে যুক্ত হবে।'),
                Text('• আপনার রেফারকৃত গ্রাহকের জমি কেনাবেচা বা বিশেষ সেবার চুক্তি সম্পন্ন হলে অ্যাডমিন নির্ধারিত নির্দিষ্ট অঙ্ক বা শতকরা (%) কমিশন আপনার হিসাবে যুক্ত হবে।'),
                Text('• কোনো ভুল তথ্য বা ভুয়া প্রতিশ্রুতি দিয়ে গ্রাহক নিবন্ধন করানো সম্পূর্ণ নিষিদ্ধ।'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SELLER VIEW ====================
  Widget _buildSellerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            const Text(
              'আমার জমির বিজ্ঞাপনসমূহ (Seller Property Listings)',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _showAddListingDialog,
                  icon: const Icon(Icons.add_home_work),
                  label: const Text('নতুন জমির বিজ্ঞাপন জমা দিন'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _showAddProposalDialog,
                  icon: const Icon(Icons.handshake),
                  label: const Text('বিশেষ সেবার পারিশ্রমিক প্রস্তাব'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_myListings.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('আপনি এখনো কোনো জমির বিজ্ঞাপন জমা দেননি। উপরের বাটনে ক্লিক করে জমির তথ্য জমা দিন।'),
            ),
          )
        else
          ..._myListings.map((l) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            l['title'] ?? '',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              _verificationBadge(l['verificationStatus']),
                              _statusChip(l['listingStatus']),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'অবস্থান: ${l['areaName']}, ${l['upazila']}, ${l['district']} • মৌজা: ${l['mouzaName'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'পরিমাণ: ${l['areaDecimal']} শতাংশ (${l['landType']}) • প্রত্যাশিত মূল্য: ৳${l['expectedPriceBdt']} • প্রস্তাবিত পারিশ্রমিক: ৳${l['proposedServiceFeeBdt']}',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B4F32)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'গোপনীয় দলিল তথ্য (শুধু অ্যাডমিন দেখবেন): খতিয়ান: ${l['khatianNo']} | দাগ: ${l['dagNo']} | নামজারি: ${l['mutationInfo']}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      if (l['adminRemark'] != null && l['adminRemark'].toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'অ্যাডমিন মন্তব্য: ${l['adminRemark']}',
                          style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
        const SizedBox(height: 24),
        _buildMyProposalsSection(),
      ],
    );
  }

  // ==================== BUYER VIEW ====================
  Widget _buildBuyerView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            const Text(
              'আমার জমি কেনার চাহিদাসমূহ (Buyer Requirements)',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _showAddRequirementDialog,
                  icon: const Icon(Icons.post_add),
                  label: const Text('নতুন চাহিদা নিবন্ধন করুন'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _showAddProposalDialog,
                  icon: const Icon(Icons.handshake),
                  label: const Text('বিশেষ সেবার পারিশ্রমিক প্রস্তাব'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_myRequirements.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('আপনি এখনো কোনো জমির চাহিদা নিবন্ধন করেননি।'),
            ),
          )
        else
          ..._myRequirements.map((r) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    'পছন্দের এলাকা: ${r['preferredUpazila']} (${r['preferredArea'] ?? ''}) — ${r['landType']} জমি',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'পরিমাণ: ${r['minAreaDecimal']}–${r['maxAreaDecimal']} শতাংশ • বাজেট: ৳${r['minBudgetBdt']}–৳${r['maxBudgetBdt']} • উদ্দেশ্য: ${r['purpose']} • প্রস্তাবিত পারিশ্রমিক: ৳${r['proposedServiceFeeBdt']}',
                  ),
                  trailing: _statusChip(r['status']),
                ),
              )),
        const SizedBox(height: 24),
        const Text(
          'পছন্দের জমিতে আমার আগ্রহ প্রকাশের তালিকা (My Inquiries)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_myInquiries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('হোম পেজ থেকে কোনো জমিতে "আগ্রহ প্রকাশ" করলে তা এখানে দেখা যাবে।'),
            ),
          )
        else
          ..._myInquiries.map((inq) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.connect_without_contact, color: Color(0xFF0B4F32)),
                  title: Text(inq['listingTitle'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('প্রস্তাবিত বাজেট: ৳${inq['offeredBudgetBdt']} • বার্তা: ${inq['message']}'),
                  trailing: _statusChip(inq['status']),
                ),
              )),
        const SizedBox(height: 24),
        _buildMyProposalsSection(),
      ],
    );
  }

  Widget _buildMyProposalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'বিশেষ সেবা ও নির্দিষ্ট পারিশ্রমিকের প্রস্তাবনা (Custom Service Fee Proposals)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_myProposals.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('জমি কেনা বা বিক্রির জন্য নির্দিষ্ট পারিশ্রমিকের (যেমন ২ লাখ বা ৫ লাখ টাকা) প্রস্তাব দিলে তা এখানে দেখা যাবে।'),
            ),
          )
        else
          ..._myProposals.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p['proposalTitle'] ?? '',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _statusChip(p['status']),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(p['scopeDescription'] ?? ''),
                      const SizedBox(height: 6),
                      Text(
                        'আপনার প্রস্তাবিত পারিশ্রমিক: ৳${p['customerProposedFeeBdt']}'
                        '${p['adminCounterFeeBdt'] != null ? '  |  অ্যাডমিনের পাল্টা প্রস্তাব: ৳${p['adminCounterFeeBdt']}' : ''}'
                        '${p['finalAgreedFeeBdt'] != null ? '  |  চূড়ান্ত সম্মত পারিশ্রমিক: ৳${p['finalAgreedFeeBdt']}' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                      ),
                      if (p['adminNote'] != null) ...[
                        const SizedBox(height: 4),
                        Text('অ্যাডমিন নোট: ${p['adminNote']}', style: const TextStyle(color: Colors.deepOrange)),
                      ],
                      if (p['status'] == 'ADMIN_COUNTER_OFFER') ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                          onPressed: () async {
                            await ApiService.acceptCounterOffer(p['id'] as int);
                            _loadData();
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('অ্যাডমিনের পাল্টা প্রস্তাব গ্রহণ করুন'),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  // ==================== DIALOGS ====================

  void _showAddListingDialog() {
    final titleCtrl = TextEditingController();
    String upazila = 'নোয়াখালী সদর';
    final areaNameCtrl = TextEditingController();
    final mouzaCtrl = TextEditingController();
    final khatianCtrl = TextEditingController();
    final dagCtrl = TextEditingController();
    final mutationCtrl = TextEditingController(text: 'নামজারি ও খাজনা হালনাগাদ');
    String landType = 'আবাসিক';
    final decimalCtrl = TextEditingController(text: '10');
    final priceCtrl = TextEditingController(text: '3500000');
    final feeCtrl = TextEditingController(text: '100000');
    final roadCtrl = TextEditingController(text: '১২ ফুট পাকা রাস্তা সংলগ্ন');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('নতুন জমির বিজ্ঞাপন জমা দিন'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'বিজ্ঞাপনের শিরোনাম *')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: upazila,
                    decoration: const InputDecoration(labelText: 'উপজেলা (নোয়াখালী)'),
                    items: const [
                      'নোয়াখালী সদর', 'বেগমগঞ্জ', 'চাটখিল', 'কোম্পানীগঞ্জ',
                      'সেনবাগ', 'সোনাইমুড়ী', 'কবিরহাট', 'সুবর্ণচর', 'হাতিয়া'
                    ].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setDialogState(() => upazila = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: areaNameCtrl, decoration: const InputDecoration(labelText: 'এলাকা / ইউনিয়ন / রোড *')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: mouzaCtrl, decoration: const InputDecoration(labelText: 'মৌজার নাম'))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: landType,
                          decoration: const InputDecoration(labelText: 'জমির ধরন'),
                          items: const ['আবাসিক', 'বাণিজ্যিক', 'কৃষি', 'বাগান/খামার']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) => setDialogState(() => landType = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: decimalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পরিমাণ (শতাংশ) *'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রত্যাশিত মোট মূল্য (৳) *'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: feeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ভূমি সেতুকে প্রস্তাবিত নির্দিষ্ট পারিশ্রমিক (৳)',
                      helperText: 'জমি বিক্রিতে সহায়তা করলে আপনি কত টাকা পারিশ্রমিক দেবেন',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: khatianCtrl, decoration: const InputDecoration(labelText: 'খতিয়ান নং (গোপনীয়)'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: dagCtrl, decoration: const InputDecoration(labelText: 'দাগ নং (গোপনীয়)'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: mutationCtrl, decoration: const InputDecoration(labelText: 'দলিল ও নামজারির অবস্থা (শুধু অ্যাডমিন যাচাইয়ের জন্য)')),
                  const SizedBox(height: 10),
                  TextField(controller: roadCtrl, decoration: const InputDecoration(labelText: 'রাস্তার তথ্য')),
                  const SizedBox(height: 10),
                  TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'অতিরিক্ত বিবরণ')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () async {
                await ApiService.createListing({
                  'title': titleCtrl.text.isEmpty ? '$upazila-এ $decimalCtrl শতাংশ $landType জমি বিক্রি' : titleCtrl.text,
                  'district': 'নোয়াখালী',
                  'upazila': upazila,
                  'areaName': areaNameCtrl.text,
                  'mouzaName': mouzaCtrl.text,
                  'khatianNo': khatianCtrl.text,
                  'dagNo': dagCtrl.text,
                  'mutationInfo': mutationCtrl.text,
                  'landType': landType,
                  'areaDecimal': decimalCtrl.text,
                  'expectedPriceBdt': priceCtrl.text,
                  'proposedServiceFeeBdt': feeCtrl.text,
                  'roadAccessInfo': roadCtrl.text,
                  'description': descCtrl.text,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadData();
                widget.onRefreshParent();
              },
              child: const Text('জমা দিন'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRequirementDialog() {
    String upazila = 'নোয়াখালী সদর';
    String landType = 'আবাসিক';
    final areaCtrl = TextEditingController();
    final minDecCtrl = TextEditingController(text: '5');
    final maxDecCtrl = TextEditingController(text: '15');
    final minBudCtrl = TextEditingController(text: '2000000');
    final maxBudCtrl = TextEditingController(text: '4500000');
    final purposeCtrl = TextEditingController(text: 'আবাসিক বাড়ি নির্মাণ');
    final timelineCtrl = TextEditingController(text: '১-৩ মাসের মধ্যে');
    final feeCtrl = TextEditingController(text: '100000');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('জমি কেনার চাহিদা নিবন্ধন করুন'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: upazila,
                    decoration: const InputDecoration(labelText: 'পছন্দের উপজেলা'),
                    items: const [
                      'নোয়াখালী সদর', 'বেগমগঞ্জ', 'চাটখিল', 'কোম্পানীগঞ্জ',
                      'সেনবাগ', 'সোনাইমুড়ী', 'কবিরহাট', 'সুবর্ণচর', 'হাতিয়া'
                    ].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setDialogState(() => upazila = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'পছন্দের এলাকা / ইউনিয়ন')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: landType,
                    decoration: const InputDecoration(labelText: 'জমির ধরন'),
                    items: const ['আবাসিক', 'বাণিজ্যিক', 'কৃষি', 'বাগান/খামার']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => landType = v!),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: minDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন পরিমাণ (শতাংশ)'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: maxDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ পরিমাণ (শতাংশ)'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: minBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন বাজেট (৳)'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: maxBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (৳)'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'কেনার উদ্দেশ্য')),
                  const SizedBox(height: 10),
                  TextField(controller: timelineCtrl, decoration: const InputDecoration(labelText: 'সম্ভাব্য সময়সীমা')),
                  const SizedBox(height: 10),
                  TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রস্তাবিত নির্দিষ্ট পারিশ্রমিক (৳)')),
                  const SizedBox(height: 10),
                  TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'অন্যান্য বিশেষ চাহিদা')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () async {
                await ApiService.createRequirement({
                  'preferredDistrict': 'নোয়াখালী',
                  'preferredUpazila': upazila,
                  'preferredArea': areaCtrl.text,
                  'landType': landType,
                  'minAreaDecimal': minDecCtrl.text,
                  'maxAreaDecimal': maxDecCtrl.text,
                  'minBudgetBdt': minBudCtrl.text,
                  'maxBudgetBdt': maxBudCtrl.text,
                  'purpose': purposeCtrl.text,
                  'purchaseTimeline': timelineCtrl.text,
                  'proposedServiceFeeBdt': feeCtrl.text,
                  'specialRequirements': notesCtrl.text,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadData();
                widget.onRefreshParent();
              },
              child: const Text('চাহিদা জমা দিন'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProposalDialog() {
    final titleCtrl = TextEditingController();
    final scopeCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: '200000');
    final timelineCtrl = TextEditingController(text: '২ মাসের মধ্যে');
    final termsCtrl = TextEditingController(text: 'বায়না চুক্তির সময় ৫০% এবং রেজিস্ট্রেশনের দিন ৫০%');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('বিশেষ সেবা ও নির্দিষ্ট পারিশ্রমিকের প্রস্তাব দিন'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'প্রস্তাবের শিরোনাম *')),
                const SizedBox(height: 10),
                TextField(controller: scopeCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'কাজের পরিধি ও শর্তাবলি *')),
                const SizedBox(height: 10),
                TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'আপনার প্রস্তাবিত নির্দিষ্ট পারিশ্রমিক (৳) *')),
                const SizedBox(height: 10),
                TextField(controller: timelineCtrl, decoration: const InputDecoration(labelText: 'সময়সীমা')),
                const SizedBox(height: 10),
                TextField(controller: termsCtrl, decoration: const InputDecoration(labelText: 'অর্থ পরিশোধের শর্ত')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
            onPressed: () async {
              await ApiService.createProposal({
                'proposalTitle': titleCtrl.text.isEmpty ? 'বিশেষ ক্রয়/বিক্রয় সহায়তা চুক্তি' : titleCtrl.text,
                'scopeDescription': scopeCtrl.text,
                'customerProposedFeeBdt': feeCtrl.text,
                'timelineTerms': timelineCtrl.text,
                'paymentTerms': termsCtrl.text,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('প্রস্তাব জমা দিন'),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 265,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleBangla(String? role) {
    return switch (role) {
      'SELLER' => 'বিক্রেতা (Seller)',
      'MARKETING_OFFICER' => 'মার্কেটিং অফিসার',
      'ADMIN' => 'অ্যাডমিন',
      _ => 'ক্রেতা (Buyer)',
    };
  }

  Widget _verificationBadge(String? status) {
    final (label, color) = switch (status) {
      'FIELD_VERIFIED' => ('🟢 সরেজমিনে ও নথি যাচাইকৃত', Colors.green.shade800),
      'DOC_CHECKED' => ('🔵 কাগজপত্র প্রাথমিক যাচাইকৃত', Colors.blue.shade800),
      _ => ('⚪ প্রাথমিক তথ্য প্রাপ্ত', Colors.grey.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _statusChip(String? status) {
    final (label, color) = switch (status) {
      'ACTIVE' || 'APPROVED_PUBLISHED' || 'MUTUALLY_AGREED' || 'COMPLETED' => (status!, Colors.green.shade700),
      'SUSPENDED' || 'REJECTED' => (status!, Colors.red.shade700),
      _ => (status ?? 'PENDING', Colors.orange.shade800),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
