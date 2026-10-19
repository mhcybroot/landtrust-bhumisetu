import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPanelScreen extends StatefulWidget {
  final VoidCallback onConfigChanged;

  const AdminPanelScreen({super.key, required this.onConfigChanged});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _subTabIndex = 0;
  bool _loading = true;

  Map<String, dynamic> _dashboard = {};
  List<dynamic> _users = [];
  List<dynamic> _listings = [];
  List<dynamic> _requirements = [];
  List<dynamic> _commissions = [];
  List<dynamic> _proposals = [];
  List<dynamic> _transactions = [];
  List<dynamic> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadAllAdminData();
  }

  Future<void> _loadAllAdminData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getAdminDashboard(),
        ApiService.getAdminUsers(),
        ApiService.getAdminListings(),
        ApiService.getAdminRequirements(),
        ApiService.getAdminCommissions(),
        ApiService.getAdminProposals(),
        ApiService.getAdminTransactions(),
        ApiService.getAdminPaymentMethods(),
      ]);
      _dashboard = results[0] as Map<String, dynamic>;
      _users = results[1] as List<dynamic>;
      _listings = results[2] as List<dynamic>;
      _requirements = results[3] as List<dynamic>;
      _commissions = results[4] as List<dynamic>;
      _proposals = results[5] as List<dynamic>;
      _transactions = results[6] as List<dynamic>;
      _paymentMethods = results[7] as List<dynamic>;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('অ্যাডমিন ডেটা লোড ত্রুটি: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
    }

    final tabs = [
      (Icons.dashboard, 'ড্যাশবোর্ড ও ম্যাচিং'),
      (Icons.people, 'সদস্য ও TrxID যাচাই (${_users.length})'),
      (Icons.landscape, 'জমি ও চাহিদা (Suspend/Reject)'),
      (Icons.share, 'রেফারেল ও কমিশন (${_commissions.length})'),
      (Icons.account_balance, 'বিশেষ প্রস্তাব ও আর্থিক লেজার'),
      (Icons.settings, 'ফি, পেমেন্ট নম্বর ও সেটিংস'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Top Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2E1F),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'কেন্দ্রীয় অ্যাডমিন প্যানেল — ভূমি সেতু (LandTrust)',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'সদস্য অনুমোদন, যেকোনো পর্যায়ে বিজ্ঞাপন স্থগিত/বাতিল, রেফারেল কমিশন নির্ধারণ ও ৩-খাত আর্থিক ব্যবস্থাপনা',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _loadAllAdminData,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('ডেটা রিফ্রেশ'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sub-navigation Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final selected = _subTabIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ChoiceChip(
                        avatar: Icon(
                          tabs[i].$1,
                          size: 18,
                          color: selected ? Colors.white : const Color(0xFF0B4F32),
                        ),
                        label: Text(tabs[i].$2),
                        selected: selected,
                        selectedColor: const Color(0xFF0B4F32),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _subTabIndex = i),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              if (_subTabIndex == 0) _buildDashboardAndMatchingTab(),
              if (_subTabIndex == 1) _buildUsersManagementTab(),
              if (_subTabIndex == 2) _buildListingsAndRequirementsTab(),
              if (_subTabIndex == 3) _buildReferralAndCommissionTab(),
              if (_subTabIndex == 4) _buildProposalsAndLedgerTab(),
              if (_subTabIndex == 5) _buildDynamicSettingsTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 0: DASHBOARD, 3-FUND SUMMARY & AUTO-MATCHING ====================
  Widget _buildDashboardAndMatchingTab() {
    final fin = (_dashboard['finance'] as Map<String, dynamic>?) ?? {};
    final matches = (_dashboard['autoMatches'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Member & Listing Counts
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _statCard('মোট সদস্য', '${_dashboard['totalMembers'] ?? 0} জন', 'অপেক্ষমাণ: ${_dashboard['pendingUsers'] ?? 0}', Colors.indigo),
            _statCard('জমির বিজ্ঞাপন', '${_dashboard['totalListings'] ?? 0} টি', 'প্রকাশিত: ${_dashboard['publishedListings'] ?? 0}', Colors.green.shade700),
            _statCard('ক্রেতার চাহিদা', '${_dashboard['totalRequirements'] ?? 0} টি', 'আগ্রহ প্রকাশ: ${_dashboard['totalInquiries'] ?? 0}', Colors.teal.shade700),
            _statCard('মার্কেটিং অফিসার', '${_dashboard['totalOfficers'] ?? 0} জন', 'বিশেষ প্রস্তাব: ${_dashboard['totalProposals'] ?? 0}', Colors.deepPurple),
          ],
        ),
        const SizedBox(height: 24),

        // 3-Fund Financial Ledger Summary (With Advisory-Only Reserve Note — NO LOCK!)
        const Text(
          'পৃথক ৩-খাত আর্থিক তহবিল ও পরিচালন ফলাফল (কোনো ফান্ড লক নেই)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _statCard(
              '১. নিবন্ধন ফি তহবিল (Approved)',
              '৳${fin['regFeeCollected'] ?? 0}',
              'যাচাই অপেক্ষমাণ: ৳${fin['regFeePending'] ?? 0}',
              const Color(0xFF0B4F32),
            ),
            _statCard(
              '২. বিশেষ সেবার পারিশ্রমিক আয়',
              '৳${fin['serviceRevenue'] ?? 0}',
              'চুক্তিবদ্ধ লেনদেন খাত',
              Colors.blue.shade800,
            ),
            _statCard(
              '৩. অফিসার সম্মানী খাত (Payable)',
              '৳${fin['pendingCommissionPayable'] ?? 0}',
              'মোট অর্জিত: ৳${fin['totalCommissionEarned'] ?? 0} | পরিশোধিত: ৳${fin['totalCommissionPaid'] ?? 0}',
              Colors.orange.shade800,
            ),
            _statCard(
              'পরিচালন ব্যয় ও নিট তহবিল',
              '৳${fin['netOperatingBalance'] ?? 0}',
              'মোট ব্যয়: ৳${fin['operationalExpenses'] ?? 0}',
              Colors.purple.shade800,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Advisory Reserve Banner (No Lock!)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade800),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fin['advisoryNote'] ??
                      'পরামর্শ: তহবিলে কোনো লক (Lock) নেই। তবে সম্ভাব্য রিফান্ড ও জরুরি ব্যয়ের জন্য পরামর্শমূলক রিজার্ভ: ৳${fin['advisoryReserveRecommendation'] ?? 0}',
                  style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Automated Buyer-Seller Matching Engine
        const Text(
          'স্বয়ংক্রিয় ক্রেতার চাহিদা ও উপযুক্ত জমির মিল (Auto-Matching Engine)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (matches.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('বর্তমানে কোনো স্বয়ংক্রিয় ম্যাচিং পাওয়া যায়নি।'),
            ),
          )
        else
          ...matches.map((m) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF0B4F32),
                    child: Text(
                      '${m['matchScore']}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  title: Text(
                    'জমি: ${m['listingTitle']} (৳${m['expectedPriceBdt']})  ⟷  ক্রেতা: ${m['buyerName']} (বাজেট: ৳${m['buyerMaxBudgetBdt']})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'মিলের কারণ: ${m['reasons']}\nবিক্রেতা: ${m['sellerName']} (${m['sellerPhone']})  |  ক্রেতার মোবাইল: ${m['buyerPhone']}',
                  ),
                  isThreeLine: true,
                ),
              )),
      ],
    );
  }

  // ==================== TAB 1: USER & MANUAL TRXID VERIFICATION ====================
  Widget _buildUsersManagementTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'সকল সদস্য, নিবন্ধন ফি (TrxID) যাচাই এবং অ্যাকাউন্ট নিয়ন্ত্রণ (যেকোনো সময় সক্রিয়/স্থগিত/বাতিল)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._users.map((u) {
          final id = u['id'] as int;
          final role = u['role'] as String? ?? 'BUYER';
          final status = u['accountStatus'] as String? ?? 'PAYMENT_SUBMITTED';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${u['fullName']} (${u['role']}) — মোবাইল: ${u['phoneNumber']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'উপজেলা: ${u['upazila'] ?? 'N/A'} • নিবন্ধন ফি: ৳${u['registrationFeeAmount']} • পেমেন্ট: ${u['paymentMethod'] ?? 'N/A'} (প্রেরক: ${u['senderPhone'] ?? 'N/A'}, TrxID: ${u['transactionId'] ?? 'N/A'})',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      if (u['referredByCode'] != null)
                        Text(
                          'রেফারেল কোড ব্যবহৃত: ${u['referredByCode']} (অফিসার: ${u['referredByOfficerName']})',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF0B4F32), fontWeight: FontWeight.w600),
                        ),
                      if (role == 'MARKETING_OFFICER')
                        Text(
                          'অফিসারের নিজস্ব রেফারেল কোড: ${u['myReferralCode']} • মোট অর্জিত কমিশন: ৳${u['totalEarnedCommission']} • পরিশোধিত: ৳${u['totalPaidCommission']}',
                          style: TextStyle(fontSize: 13, color: Colors.indigo.shade800, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _badge(status),
                      if (role != 'ADMIN') ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                          onPressed: () async {
                            await ApiService.updateUserStatus(id, 'ACTIVE', 'অ্যাডমিন কর্তৃক TrxID যাচাইকৃত ও অনুমোদিত');
                            _loadAllAdminData();
                          },
                          child: const Text('অনুমোদন (ACTIVE)'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade800),
                          onPressed: () async {
                            await ApiService.updateUserStatus(id, 'SUSPENDED', 'অ্যাডমিন কর্তৃক স্থগিত');
                            _loadAllAdminData();
                          },
                          child: const Text('স্থগিত (Suspend)'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                          onPressed: () async {
                            await ApiService.updateUserStatus(id, 'REJECTED', 'অ্যাডমিন কর্তৃক বাতিল');
                            _loadAllAdminData();
                          },
                          child: const Text('বাতিল (Reject)'),
                        ),
                      ],
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

  // ==================== TAB 2: LISTINGS & REQUIREMENTS (ANYTIME SUSPEND / REJECT) ====================
  Widget _buildListingsAndRequirementsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '১. সকল জমির বিজ্ঞাপন (অ্যাডমিন যেকোনো পর্যায়ে অনুমোদন, Suspend বা Reject করতে পারবেন)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._listings.map((l) {
          final id = l['id'] as int;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l['title']} (বিক্রেতা: ${l['sellerName']} - ${l['sellerPhone']})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          _badge(l['verificationStatus']),
                          _badge(l['listingStatus']),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'অবস্থান: ${l['areaName']}, ${l['upazila']} • মৌজা: ${l['mouzaName']} • পরিমাণ: ${l['areaDecimal']} শতাংশ (${l['landType']}) • মূল্য: ৳${l['expectedPriceBdt']} • প্রস্তাবিত পারিশ্রমিক: ৳${l['proposedServiceFeeBdt']}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'গোপনীয় দলিল ও খতিয়ান তথ্য: খতিয়ান: ${l['khatianNo']} | দাগ: ${l['dagNo']} | নামজারি: ${l['mutationInfo']}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B4F32)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Verification Badges
                      ActionChip(
                        label: const Text('🔵 কাগজপত্র যাচাইকৃত'),
                        onPressed: () async {
                          await ApiService.updateListingStatus(id, verificationStatus: 'DOC_CHECKED');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                      ),
                      ActionChip(
                        label: const Text('🟢 সরেজমিনে ও নথি যাচাইকৃত'),
                        onPressed: () async {
                          await ApiService.updateListingStatus(id, verificationStatus: 'FIELD_VERIFIED');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                      ),
                      // Lifecycle Statuses + Anytime Suspend/Reject
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: () async {
                          await ApiService.updateListingStatus(id, listingStatus: 'APPROVED_PUBLISHED');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                        child: const Text('প্রকাশ করুন (Publish)'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await ApiService.updateListingStatus(id, listingStatus: 'SOLD');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                        child: const Text('বিক্রি সম্পন্ন (SOLD)'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade900),
                        onPressed: () async {
                          await ApiService.updateListingStatus(id, listingStatus: 'SUSPENDED', adminRemark: 'অ্যাডমিন কর্তৃক স্থগিত (Suspended)');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                        child: const Text('স্থগিত (Suspend)'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                        onPressed: () async {
                          await ApiService.updateListingStatus(id, listingStatus: 'REJECTED', adminRemark: 'অ্যাডমিন কর্তৃক বাতিল (Rejected)');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                        child: const Text('বাতিল (Reject)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 24),
        const Text(
          '২. ক্রেতার চাহিদা তালিকা (যেকোনো পর্যায়ে অনুমোদন, Suspend বা Reject)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._requirements.map((r) {
          final id = r['id'] as int;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Wrap(
                spacing: 14,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ক্রেতা: ${r['buyerName']} (${r['buyerPhone']}) — ${r['preferredUpazila']} (${r['landType']})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'পরিমাণ: ${r['minAreaDecimal']}–${r['maxAreaDecimal']} শতাংশ • বাজেট: ৳${r['minBudgetBdt']}–৳${r['maxBudgetBdt']} • প্রস্তাবিত পারিশ্রমিক: ৳${r['proposedServiceFeeBdt']}',
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _badge(r['status']),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: () async {
                          await ApiService.updateRequirementStatus(id, 'ACTIVE', 'অনুমোদিত');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                        child: const Text('সক্রিয় (ACTIVE)'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade900),
                        onPressed: () async {
                          await ApiService.updateRequirementStatus(id, 'SUSPENDED', 'স্থগিত');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                        child: const Text('Suspend'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                        onPressed: () async {
                          await ApiService.updateRequirementStatus(id, 'REJECTED', 'বাতিল');
                          _loadAllAdminData();
                          widget.onConfigChanged();
                        },
                        child: const Text('Reject'),
                      ),
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

  // ==================== TAB 3: REFERRAL & DUAL COMMISSION MANAGEMENT ====================
  Widget _buildReferralAndCommissionTab() {
    final referredMembers = _users.where((u) => u['referredByOfficerId'] != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              'মার্কেটিং অফিসারদের রেফারেল ও কমিশন ব্যবস্থাপনা (Fixed ও Percentage % উভয়ই)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F32),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showAwardCommissionDialog(referredMembers),
              icon: const Icon(Icons.add_card),
              label: const Text('নতুন কমিশন প্রদান করুন (নির্দিষ্ট টাকা বা %)'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ..._commissions.map((c) {
          final id = c['id'] as int;
          final isPaid = c['status'] == 'PAID';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.pending_actions,
                  color: isPaid ? Colors.green.shade700 : Colors.orange.shade800,
                ),
              ),
              title: Text(
                'অফিসার: ${c['officerName']} (${c['referralCode']}) ➔ রেফারকৃত সদস্য: ${c['referredUserName']} (${c['referredUserRole']})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'ধরন: ${c['commissionType']} • মূল অঙ্ক: ৳${c['baseDealAmountBdt']} • হার: ${c['percentageRate']}% • নোট: ${c['note'] ?? ''}',
              ),
              trailing: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '৳${c['commissionAmountBdt']}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                  ),
                  if (isPaid)
                    _badge('PAID (${c['paymentReference'] ?? ''})')
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                      onPressed: () async {
                        await ApiService.payCommission(id, 'BKASH-PAID-${DateTime.now().millisecondsSinceEpoch % 10000}');
                        _loadAllAdminData();
                      },
                      child: const Text('পরিশোধ করুন (Pay)'),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAwardCommissionDialog(List<dynamic> referredMembers) {
    if (referredMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এখনো কোনো রেফারকৃত সদস্য পাওয়া যায়নি।')),
      );
      return;
    }

    int selectedUserId = referredMembers.first['id'] as int;
    String commissionType = 'DEAL_CLOSURE_FIXED';
    final fixedAmountCtrl = TextEditingController(text: '5000');
    final baseDealCtrl = TextEditingController(text: '150000');
    final percentCtrl = TextEditingController(text: '10');
    final noteCtrl = TextEditingController(text: 'জমি ক্রয়-বিক্রয় সম্পন্ন হওয়ায় অ্যাডমিন কর্তৃক অনুমোদিত কমিশন');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('মার্কেটিং অফিসারকে কমিশন প্রদান করুন (নির্দিষ্ট টাকা বা %)'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedUserId,
                    decoration: const InputDecoration(labelText: 'রেফারকৃত ক্রেতা/বিক্রেতা নির্বাচন করুন'),
                    items: referredMembers.map((u) {
                      return DropdownMenuItem<int>(
                        value: u['id'] as int,
                        child: Text('${u['fullName']} (${u['role']}) - কোড: ${u['referredByCode']}'),
                      );
                    }).toList(),
                    onChanged: (v) => setDialogState(() => selectedUserId = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: commissionType,
                    decoration: const InputDecoration(labelText: 'কমিশনের ধরন নির্বাচন করুন'),
                    items: const [
                      DropdownMenuItem(value: 'REFERRAL_VERIFIED_FIXED', child: Text('১. যাচাইকৃত সন্ধান/নিবন্ধন সম্মানী (নির্দিষ্ট টাকা)')),
                      DropdownMenuItem(value: 'DEAL_CLOSURE_FIXED', child: Text('২. সফল লেনদেন কমিশন (নির্দিষ্ট টাকা - Fixed)')),
                      DropdownMenuItem(value: 'DEAL_CLOSURE_PERCENT', child: Text('৩. সফল লেনদেন কমিশন (শতকরা হার - Percentage %)')),
                    ],
                    onChanged: (v) => setDialogState(() => commissionType = v!),
                  ),
                  const SizedBox(height: 12),
                  if (commissionType == 'DEAL_CLOSURE_PERCENT') ...[
                    TextField(
                      controller: baseDealCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'মোট লেনদেন বা পারিশ্রমিকের পরিমাণ (৳)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: percentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'কমিশনের শতকরা হার (%) — অ্যাডমিন নির্ধারিত'),
                    ),
                  ] else ...[
                    TextField(
                      controller: fixedAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'কমিশনের নির্দিষ্ট পরিমাণ (৳) — অ্যাডমিন নির্ধারিত'),
                    ),
                  ],
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'বিবরণ / নোট'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () async {
                await ApiService.awardCommission({
                  'referredUserId': selectedUserId,
                  'commissionType': commissionType,
                  'commissionAmountBdt': fixedAmountCtrl.text,
                  'baseDealAmountBdt': baseDealCtrl.text,
                  'percentageRate': percentCtrl.text,
                  'note': noteCtrl.text,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadAllAdminData();
              },
              child: const Text('কমিশন অনুমোদন করুন'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 4: SPECIAL PROPOSALS & 3-FUND LEDGER ====================
  Widget _buildProposalsAndLedgerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '১. বিশেষ সেবা ও নির্দিষ্ট পারিশ্রমিকের প্রস্তাবনা (গ্রহণ / পাল্টা প্রস্তাব / সম্পন্ন)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._proposals.map((p) {
          final id = p['id'] as int;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${p['proposalTitle']} — ${p['userName']} (${p['userRole']}, ${p['userPhone']})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      _badge(p['status']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(p['scopeDescription'] ?? ''),
                  const SizedBox(height: 4),
                  Text(
                    'গ্রাহকের প্রস্তাব: ৳${p['customerProposedFeeBdt']}  |  পাল্টা প্রস্তাব: ৳${p['adminCounterFeeBdt'] ?? '-'}  |  চূড়ান্ত সম্মত: ৳${p['finalAgreedFeeBdt'] ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                        onPressed: () async {
                          await ApiService.updateAdminProposal(id, {
                            'status': 'MUTUALLY_AGREED',
                            'finalAgreedFeeBdt': p['customerProposedFeeBdt'],
                            'adminNote': 'অ্যাডমিন প্রস্তাবটি গ্রহণ করেছেন।',
                          });
                          _loadAllAdminData();
                        },
                        child: const Text('প্রস্তাব গ্রহণ করুন'),
                      ),
                      OutlinedButton(
                        onPressed: () => _showCounterOfferDialog(p),
                        child: const Text('পাল্টা প্রস্তাব দিন (Counter Offer)'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await ApiService.updateAdminProposal(id, {'status': 'COMPLETED'});
                          _loadAllAdminData();
                        },
                        child: const Text('কাজ সম্পন্ন ও আয় যুক্ত (COMPLETED)'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                        onPressed: () async {
                          await ApiService.updateAdminProposal(id, {'status': 'REJECTED'});
                          _loadAllAdminData();
                        },
                        child: const Text('বাতিল (Reject)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              '২. সকল আর্থিক লেনদেন ও লেজার রেকর্ড (Financial Transactions)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _showAddExpenseDialog,
              icon: const Icon(Icons.add),
              label: const Text('নতুন পরিচালন ব্যয় / আয় যুক্ত করুন'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._transactions.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  t['txnType'] == 'CREDIT' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: t['txnType'] == 'CREDIT' ? Colors.green.shade700 : Colors.red.shade700,
                ),
                title: Text(
                  '${t['description']} — খাত: ${t['fundBucket']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'গ্রাহক/সদস্য: ${t['userName'] ?? 'N/A'} • মাধ্যম: ${t['paymentMethod']} • TrxID: ${t['transactionId'] ?? 'N/A'}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${t['txnType'] == 'CREDIT' ? '+' : '-'}৳${t['amountBdt']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: t['txnType'] == 'CREDIT' ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                    Text(t['status'] ?? '', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void _showCounterOfferDialog(Map<String, dynamic> proposal) {
    final counterCtrl = TextEditingController(text: '${proposal['customerProposedFeeBdt']}');
    final noteCtrl = TextEditingController(text: 'কাজের পরিধি বিবেচনায় আমাদের পাল্টা প্রস্তাব');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('পাল্টা পারিশ্রমিক প্রস্তাব দিন'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: counterCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'পাল্টা প্রস্তাবিত পারিশ্রমিক (৳)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'অ্যাডমিন নোট'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateAdminProposal(proposal['id'] as int, {
                'status': 'ADMIN_COUNTER_OFFER',
                'adminCounterFeeBdt': counterCtrl.text,
                'adminNote': noteCtrl.text,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _loadAllAdminData();
            },
            child: const Text('পাঠান'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    String bucket = 'OPERATIONAL_EXPENSE';
    String txnType = 'DEBIT';
    final amountCtrl = TextEditingController(text: '2000');
    final descCtrl = TextEditingController(text: 'বিজ্ঞাপন ও জমি যাচাই যাতায়াত ব্যয়');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('নতুন আর্থিক এন্ট্রি যোগ করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: bucket,
                decoration: const InputDecoration(labelText: 'হিসাবখাত'),
                items: const [
                  DropdownMenuItem(value: 'OPERATIONAL_EXPENSE', child: Text('পরিচালন ব্যয় (OPERATIONAL_EXPENSE)')),
                  DropdownMenuItem(value: 'SERVICE_REVENUE', child: Text('বিশেষ সেবার পারিশ্রমিক (SERVICE_REVENUE)')),
                  DropdownMenuItem(value: 'REG_FEE_FUND', child: Text('নিবন্ধন তহবিল (REG_FEE_FUND)')),
                ],
                onChanged: (v) => setDialogState(() {
                  bucket = v!;
                  txnType = bucket == 'OPERATIONAL_EXPENSE' ? 'DEBIT' : 'CREDIT';
                }),
              ),
              const SizedBox(height: 10),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পরিমাণ (৳)')),
              const SizedBox(height: 10),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'বিবরণ')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () async {
                await ApiService.createAdminTransaction({
                  'fundBucket': bucket,
                  'txnType': txnType,
                  'amountBdt': amountCtrl.text,
                  'description': descCtrl.text,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadAllAdminData();
              },
              child: const Text('সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 5: DYNAMIC SETTINGS (FEES, PAYMENT ACCOUNTS, COMMISSIONS) ====================
  Widget _buildDynamicSettingsTab() {
    final s = (_dashboard['settings'] as Map<String, dynamic>?) ?? {};
    final buyerFeeCtrl = TextEditingController(text: '${s['buyerRegistrationFee'] ?? 500}');
    final sellerFeeCtrl = TextEditingController(text: '${s['sellerRegistrationFee'] ?? 500}');
    final officerFeeCtrl = TextEditingController(text: '${s['officerRegistrationFee'] ?? 300}');
    final refBonusCtrl = TextEditingController(text: '${s['referralVerifiedBonusFixed'] ?? 100}');
    final dealFixedCtrl = TextEditingController(text: '${s['dealClosureFixedCommission'] ?? 5000}');
    final dealPctCtrl = TextEditingController(text: '${s['dealClosurePercentCommission'] ?? 10}');
    final reservePctCtrl = TextEditingController(text: '${s['advisoryReservePercent'] ?? 25}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '১. নিবন্ধন ফি এবং মার্কেটিং অফিসার কমিশন নির্ধারণ (অ্যাডমিন যেকোনো সময় পরিবর্তন করতে পারবেন)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: buyerFeeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'ক্রেতা নিবন্ধন ফি (৳)', border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: sellerFeeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'বিক্রেতা নিবন্ধন ফি (৳)', border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: officerFeeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'মার্কেটিং অফিসার নিবন্ধন ফি (৳)', border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: refBonusCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'যাচাইকৃত রেফারেল সম্মানী (Fixed ৳)', border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: dealFixedCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'ডিফল্ট ডিল ক্লোজার কমিশন (Fixed ৳)', border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: dealPctCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'ডিফল্ট ডিল ক্লোজার কমিশন (%)', border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: reservePctCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'পরামর্শমূলক রিজার্ভ হার (%)',
                          helperText: 'কোনো লক নেই, শুধু পরামর্শ দেখানোর জন্য',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  ),
                  onPressed: () async {
                    await ApiService.updateAdminSettings({
                      'buyerRegistrationFee': buyerFeeCtrl.text,
                      'sellerRegistrationFee': sellerFeeCtrl.text,
                      'officerRegistrationFee': officerFeeCtrl.text,
                      'referralVerifiedBonusFixed': refBonusCtrl.text,
                      'dealClosureFixedCommission': dealFixedCtrl.text,
                      'dealClosurePercentCommission': dealPctCtrl.text,
                      'advisoryReservePercent': reservePctCtrl.text,
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('সিস্টেম ফি ও কমিশন সেটিংস সফলভাবে আপডেট হয়েছে!')),
                      );
                    }
                    _loadAllAdminData();
                    widget.onConfigChanged();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('সেটিংস সংরক্ষণ করুন'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Payment Receiving Accounts (Where users send money)
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              '২. গ্রাহকরা কোথায় পেমেন্ট করবেন (বিকাশ / নগদ / ব্যাংক নম্বর সেটিংস)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: _showAddPaymentMethodDialog,
              icon: const Icon(Icons.add),
              label: const Text('নতুন পেমেন্ট নম্বর যোগ করুন'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._paymentMethods.map((pm) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF0B4F32)),
                title: Text(
                  '${pm['providerName']} — নম্বর: ${pm['accountNumber']} (${pm['accountType']})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(pm['instructions'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await ApiService.deletePaymentMethod(pm['id'] as int);
                    _loadAllAdminData();
                    widget.onConfigChanged();
                  },
                ),
              ),
            )),
      ],
    );
  }

  void _showAddPaymentMethodDialog() {
    final providerCtrl = TextEditingController(text: 'বিকাশ (bKash)');
    final numberCtrl = TextEditingController(text: '01700-000000');
    final typeCtrl = TextEditingController(text: 'Personal (Send Money)');
    final instCtrl = TextEditingController(text: 'Send Money করে নিচের ফর্মে আপনার নম্বর ও TrxID দিন।');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন পেমেন্ট মাধ্যম ও নম্বর যোগ করুন'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: providerCtrl, decoration: const InputDecoration(labelText: 'মাধ্যমের নাম (যেমন: বিকাশ / নগদ / রকেট / ব্যাংক)')),
              const SizedBox(height: 10),
              TextField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'অ্যাকাউন্ট / মোবাইল নম্বর')),
              const SizedBox(height: 10),
              TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'ধরন (Personal / Merchant / Bank)')),
              const SizedBox(height: 10),
              TextField(controller: instCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'গ্রাহকের জন্য নির্দেশনা')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.addPaymentMethod({
                'providerName': providerCtrl.text,
                'accountNumber': numberCtrl.text,
                'accountType': typeCtrl.text,
                'instructions': instCtrl.text,
                'active': true,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              _loadAllAdminData();
              widget.onConfigChanged();
            },
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, String subtitle, Color color) {
    return Container(
      width: 285,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _badge(String? text) {
    final t = text ?? 'PENDING';
    final color = (t.contains('ACTIVE') || t.contains('APPROVED') || t.contains('VERIFIED') || t.contains('PAID') || t.contains('AGREED'))
        ? Colors.green.shade700
        : (t.contains('SUSPENDED') || t.contains('REJECTED'))
            ? Colors.red.shade700
            : Colors.orange.shade800;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
