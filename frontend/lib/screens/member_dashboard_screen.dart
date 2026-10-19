import 'dart:convert';
import 'package:file_picker/file_picker.dart';
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
  String _activePortalMode = '';
  Map<String, dynamic> _publicConfig = {};
  Map<String, dynamic> _notificationsData = {'unreadCount': 0, 'notifications': []};
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
      _publicConfig = await ApiService.getPublicConfig();
      _notificationsData = await ApiService.getMyNotifications();
      final role = ApiService.currentUser?['role']?.toString() ?? 'BUYER';
      if (_activePortalMode.isEmpty) {
        _activePortalMode = role == 'ADMIN' ? 'SELLER' : role;
      }
      if (role == 'MARKETING_OFFICER') {
        _officerDashboard = await ApiService.getOfficerDashboard();
      }
      // Load both Seller & Buyer data so any member can use Dual Buyer-Seller Mode
      _myListings = await ApiService.getMyListings();
      _myRequirements = await ApiService.getMyRequirements();
      _myInquiries = await ApiService.getMyInquiries();
      _myProposals = await ApiService.getMyProposals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> _getDistricts() {
    final locs = (_publicConfig['locations'] as List<dynamic>?) ?? [];
    if (locs.isEmpty) return ['নোয়াখালী'];
    return locs.map((l) => l['districtNameBn'].toString()).toSet().toList();
  }

  List<String> _getUpazilasForDistrict(String district) {
    final locs = (_publicConfig['locations'] as List<dynamic>?) ?? [];
    final list = locs
        .where((l) => l['districtNameBn'] == district)
        .map((l) => l['upazilaNameBn'].toString())
        .toSet()
        .toList();
    if (list.isEmpty) {
      return [
        'নোয়াখালী সদর', 'বেগমগঞ্জ', 'চাটখিল', 'কোম্পানীগঞ্জ',
        'সেনবাগ', 'সোনাইমুড়ী', 'কবিরহাট', 'সুবর্ণচর', 'হাতিয়া'
      ];
    }
    return list;
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
    final unreadCount = (_notificationsData['unreadCount'] as num?)?.toInt() ?? 0;
    final currentMode = _activePortalMode.isEmpty ? role : _activePortalMode;

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
                          'নিবন্ধিত ভূমিকা: ${_roleBangla(role)}  •  মোবাইল: ${user['phoneNumber']}  •  উপজেলা: ${user['upazila'] ?? 'নোয়াখালী সদর'}',
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _statusChip(status),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _showProfileAndPasswordDialog,
                          icon: const Icon(Icons.manage_accounts_outlined, size: 18),
                          label: const Text('প্রোফাইল ও পাসওয়ার্ড'),
                        ),
                        // Notification Bell Button with Badge
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: unreadCount > 0 ? Colors.amber.shade600 : Colors.white24,
                            foregroundColor: unreadCount > 0 ? Colors.black : Colors.white,
                          ),
                          onPressed: _showNotificationsDialog,
                          icon: Badge(
                            isLabelVisible: unreadCount > 0,
                            label: Text('$unreadCount'),
                            child: const Icon(Icons.notifications_active_outlined, size: 18),
                          ),
                          label: Text('নোটিফিকেশন ($unreadCount)'),
                        ),
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

              // Payment Verification / Resubmit Banner for PAYMENT_SUBMITTED or REJECTED
              if (status != 'ACTIVE') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: status == 'REJECTED' ? Colors.red.shade50 : Colors.amber.shade50,
                    border: Border.all(color: status == 'REJECTED' ? Colors.red.shade400 : Colors.amber.shade600),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status == 'REJECTED' ? Icons.error_outline : Icons.info_outline,
                            color: status == 'REJECTED' ? Colors.red.shade700 : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status == 'REJECTED'
                                      ? 'আপনার প্রদত্ত পেমেন্ট তথ্য (TrxID: ${user['transactionId']}) যাচাইয়ে মেলেনি বা বাতিল হয়েছে।'
                                      : 'আপনার নিবন্ধন ফি (৳${user['registrationFeeAmount']}) এবং TrxID (${user['transactionId']}) বর্তমানে অ্যাডমিন যাচাই করছেন।',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (user['adminNote'] != null && user['adminNote'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'অ্যাডমিন নোট: ${user['adminNote']}',
                                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B4F32),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _showResubmitPaymentDialog,
                        icon: const Icon(Icons.edit_note, size: 18),
                        label: const Text('সঠিক TrxID পুনরায় জমা দিন'),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Dual Buyer-Seller & Officer Mode Switcher Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'ড্যাশবোর্ড মোড পরিবর্তন করুন (একই অ্যাকাউন্টে ক্রয় ও বিক্রয় সুবিধা):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B4F32)),
                    ),
                    if (role == 'MARKETING_OFFICER')
                      ChoiceChip(
                        selected: currentMode == 'MARKETING_OFFICER',
                        selectedColor: const Color(0xFF0B4F32),
                        labelStyle: TextStyle(
                          color: currentMode == 'MARKETING_OFFICER' ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        label: const Text('📊 মার্কেটিং অফিসার পোর্টাল'),
                        onSelected: (_) => setState(() => _activePortalMode = 'MARKETING_OFFICER'),
                      ),
                    ChoiceChip(
                      selected: currentMode == 'BUYER',
                      selectedColor: const Color(0xFF0B4F32),
                      labelStyle: TextStyle(
                        color: currentMode == 'BUYER' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      label: Text('🛒 ক্রেতা মোড (${_myRequirements.length} চাহিদা)'),
                      onSelected: (_) => setState(() => _activePortalMode = 'BUYER'),
                    ),
                    ChoiceChip(
                      selected: currentMode == 'SELLER',
                      selectedColor: const Color(0xFF0B4F32),
                      labelStyle: TextStyle(
                        color: currentMode == 'SELLER' ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      label: Text('🏞️ বিক্রেতা মোড (${_myListings.length} বিজ্ঞাপন)'),
                      onSelected: (_) => setState(() => _activePortalMode = 'SELLER'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (currentMode == 'MARKETING_OFFICER') _buildMarketingOfficerView(),
              if (currentMode == 'SELLER') _buildSellerView(),
              if (currentMode == 'BUYER') _buildBuyerView(),
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
    final shareLink = '${ApiService.publicWebOrigin}/?ref=$code';
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
        // Referral Code & Shareable Link Banner
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আপনার ইউনিক রেফারেল কোড ও শেয়ারযোগ্য রেফারেল লিংক',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'গ্রাহক এই লিংকে ক্লিক করে নিবন্ধন করলে রেফারেল কোড স্বয়ংক্রিয়ভাবে বসে যাবে এবং আপনার পোর্টালে যুক্ত হবে।',
                          style: TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF0B4F32), width: 1.5),
                          ),
                          child: SelectableText(
                            code.toString(),
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFF0B4F32),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4F32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code.toString()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('রেফারেল কোড ($code) কপি করা হয়েছে!')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 17),
                          label: const Text('কোড কপি'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: shareLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('রেফারেল লিংক কপি করা হয়েছে: $shareLink')),
                            );
                          },
                          icon: const Icon(Icons.link, size: 18),
                          label: const Text('রেফারেল লিংক কপি করুন'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          onPressed: () => _showOfficerPayoutRequestDialog(pendingPayable),
                          icon: const Icon(Icons.payments_outlined, size: 18),
                          label: Text('সম্মানী উত্তোলনের অনুরোধ (৳$pendingPayable)'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    'শেয়ার লিংক: $shareLink',
                    style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
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

        // Referred Users List
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
        // Training Guidelines & Code of Conduct for Marketing Officers
        const Text(
          '৩. মার্কেটিং অফিসারদের কাজের নির্দেশিকা ও আচরণবিধি (Training & Guidelines)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Card(
          color: const Color(0xFFF3F8F5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ ১. সত্য ও নির্ভুল তথ্য সংগ্রহ: বিক্রেতার জমির খতিয়ান, দাগ নম্বর ও মালিকানা কাগজপত্র প্রাথমিকভাবে দেখে নিবন্ধনে সহায়তা করুন।\n'
                  '✅ ২. রেফারেল লিংক ও কোড ব্যবহার: গ্রাহক নিবন্ধনের সময় আপনার ইউনিক রেফারেল কোড বা শেয়ার লিংক ব্যবহার করলে অ্যাডমিন পেমেন্ট অনুমোদনের সাথে সাথেই আপনার নির্ধারিত নিবন্ধন বোনাস লেজারে জমা হবে।\n'
                  '✅ ৩. লেনদেন সম্পন্ন হলে বিশেষ কমিশন: আপনার রেফারকৃত ক্রেতা বা বিক্রেতার জমি ক্রয়-বিক্রয় সফলভাবে সম্পন্ন হলে নির্ধারিত হারে (%) অথবা এককালীন ডিল ক্লোজার কমিশন পাবেন।\n'
                  '✅ ৪. গোপনীয়তা ও সততা রক্ষা: প্রতিষ্ঠানের অনুমোদন ছাড়া ক্রেতা বা বিক্রেতার ব্যক্তিগত নম্বর বা গোপন দলিল বাইরে প্রকাশ করা সম্পূর্ণ নিষিদ্ধ।\n'
                  '✅ ৫. সম্মানী উত্তোলন: বকেয়া সম্মানী (Payable) জমা হলে উপরের "সম্মানী উত্তোলনের অনুরোধ" বাটনে ক্লিক করে আপনার বিকাশ/নগদ নম্বর পাঠালে অ্যাডমিন দ্রুত পরিশোধ করবেন।',
                  style: TextStyle(fontSize: 13.5, height: 1.6, color: Colors.black87),
                ),
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showListingFormDialog(),
                  icon: const Icon(Icons.add_home_work),
                  label: const Text('নতুন জমির বিজ্ঞাপন জমা দিন'),
                ),
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
              child: Text('আপনি এখনো কোনো জমির বিজ্ঞাপন জমা দেননি। উপরের বাটনে ক্লিক করে জমির তথ্য ও ছবি জমা দিন।'),
            ),
          )
        else
          ..._myListings.map((l) {
            final mapItem = l as Map<String, dynamic>;
            final hasPrivateDoc = mapItem['privateDocumentUrl'] != null && mapItem['privateDocumentUrl'].toString().isNotEmpty;
            final isSold = mapItem['listingStatus'] == 'SOLD';
            return Card(
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ApiService.buildSmartImage(
                                mapItem['imageUrl'] as String?,
                                height: 54,
                                width: 72,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                mapItem['title'] ?? '',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            _verificationBadge(mapItem['verificationStatus']),
                            _statusChip(mapItem['listingStatus']),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'অবস্থান: ${mapItem['areaName']}, ${mapItem['upazila']}, ${mapItem['district']} • মৌজা: ${mapItem['mouzaName'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'পরিমাণ: ${mapItem['areaDecimal']} শতাংশ (${mapItem['landType']}) • প্রত্যাশিত মূল্য: ৳${mapItem['expectedPriceBdt']} • প্রস্তাবিত পারিশ্রমিক: ৳${mapItem['proposedServiceFeeBdt']}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B4F32)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'গোপনীয় দলিল তথ্য (শুধু অ্যাডমিন দেখবেন): খতিয়ান: ${mapItem['khatianNo']} | দাগ: ${mapItem['dagNo']} | নামজারি: ${mapItem['mutationInfo']}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    if (mapItem['adminRemark'] != null && mapItem['adminRemark'].toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'অ্যাডমিন মন্তব্য: ${mapItem['adminRemark']}',
                        style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showListingFormDialog(existing: mapItem),
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text('বিজ্ঞাপন সম্পাদনা (Edit)'),
                        ),
                        if (hasPrivateDoc)
                          OutlinedButton.icon(
                            onPressed: () => _showPrivateDocumentPreviewDialog(mapItem),
                            icon: const Icon(Icons.description_outlined, size: 17),
                            label: Text('সংযুক্ত দলিল দেখুন (${mapItem['privateDocumentName'] ?? 'Deed'})'),
                          ),
                        if (!isSold)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                            onPressed: () async {
                              await ApiService.closeListing(mapItem['id'] as int);
                              await _loadData();
                              widget.onRefreshParent();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('বিজ্ঞাপনটি বিক্রি সম্পন্ন (SOLD) হিসেবে বন্ধ করা হয়েছে।')),
                                );
                              }
                            },
                            icon: const Icon(Icons.lock_outline, size: 17),
                            label: const Text('বিক্রি সম্পন্ন (SOLD) হিসেবে বন্ধ করুন'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showRequirementFormDialog(),
                  icon: const Icon(Icons.post_add),
                  label: const Text('নতুন চাহিদা নিবন্ধন করুন'),
                ),
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
          ..._myRequirements.map((r) {
            final reqItem = r as Map<String, dynamic>;
            final isFulfilled = reqItem['status'] == 'FULFILLED';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
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
                            'পছন্দের এলাকা: ${reqItem['preferredUpazila']}, ${reqItem['preferredDistrict']} (${reqItem['preferredArea'] ?? ''}) — ${reqItem['landType']} জমি',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        _statusChip(reqItem['status']),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'পরিমাণ: ${reqItem['minAreaDecimal']}–${reqItem['maxAreaDecimal']} শতাংশ • বাজেট: ৳${reqItem['minBudgetBdt']}–৳${reqItem['maxBudgetBdt']} • উদ্দেশ্য: ${reqItem['purpose']} • প্রস্তাবিত পারিশ্রমিক: ৳${reqItem['proposedServiceFeeBdt']}'
                      '${reqItem['adminRemark'] != null && reqItem['adminRemark'].toString().isNotEmpty ? '\nঅ্যাডমিন নোট: ${reqItem['adminRemark']}' : ''}',
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showRequirementFormDialog(existing: reqItem),
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          label: const Text('চাহিদা সম্পাদনা (Edit)'),
                        ),
                        if (!isFulfilled)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.green.shade800),
                            onPressed: () async {
                              await ApiService.fulfillMyRequirement(reqItem['id'] as int);
                              await _loadData();
                              widget.onRefreshParent();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('চাহিদাটি পূরণ হয়েছে (FULFILLED) হিসেবে চিহ্নিত করা হয়েছে।')),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 17),
                            label: const Text('চাহিদা পূরণ হয়েছে (FULFILLED)'),
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
                  subtitle: Text(
                    'প্রস্তাবিত বাজেট: ৳${inq['offeredBudgetBdt']} • বার্তা: ${inq['message']}'
                    '${inq['adminNote'] != null && inq['adminNote'].toString().isNotEmpty ? '\nঅ্যাডমিন আপডেট: ${inq['adminNote']}' : ''}',
                  ),
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
              child: Text('জমি কেনা বা বিক্রির জন্য নির্দিষ্ট পারিশ্রমিকের প্রস্তাব দিলে তা এখানে দেখা যাবে।'),
            ),
          )
        else
          ..._myProposals.map((p) {
            final isAgreed = p['status'] == 'MUTUALLY_AGREED' || p['status'] == 'COMPLETED';
            return Card(
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (p['status'] == 'ADMIN_COUNTER_OFFER')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white),
                            onPressed: () async {
                              await ApiService.acceptCounterOffer(p['id'] as int);
                              _loadData();
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('অ্যাডমিনের পাল্টা প্রস্তাব গ্রহণ করুন'),
                          ),
                        if (isAgreed)
                          OutlinedButton.icon(
                            onPressed: () => _showAgreementCertificateDialog(p as Map<String, dynamic>),
                            icon: const Icon(Icons.verified_outlined, size: 18),
                            label: const Text('📜 লিখিত চুক্তিপত্র দেখুন ও কপি করুন'),
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

  // ==================== DIALOGS ====================

  void _showProfileAndPasswordDialog() {
    final user = ApiService.currentUser ?? {};
    final districts = _getDistricts();
    String district = user['district']?.toString() ?? districts.first;
    if (!districts.contains(district)) district = districts.first;
    List<String> upazilas = _getUpazilasForDistrict(district);
    String upazila = user['upazila']?.toString() ?? upazilas.first;
    if (!upazilas.contains(upazila)) upazila = upazilas.first;

    final nameCtrl = TextEditingController(text: user['fullName']?.toString() ?? '');
    final addressCtrl = TextEditingController(text: user['address']?.toString() ?? '');
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          upazilas = _getUpazilasForDistrict(district);
          if (!upazilas.contains(upazila)) upazila = upazilas.first;

          return AlertDialog(
            title: const Text('⚙️ প্রোফাইল তথ্য ও পাসওয়ার্ড পরিবর্তন'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('১. ব্যক্তিগত প্রোফাইল আপডেট করুন:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                    const SizedBox(height: 10),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'পূর্ণ নাম *')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: district,
                            decoration: const InputDecoration(labelText: 'জেলা'),
                            items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setDialogState(() {
                              district = v!;
                              upazilas = _getUpazilasForDistrict(district);
                              upazila = upazilas.first;
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: upazila,
                            decoration: const InputDecoration(labelText: 'উপজেলা'),
                            items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) => setDialogState(() => upazila = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'বিস্তারিত ঠিকানা')),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                        onPressed: () async {
                          try {
                            await ApiService.updateMyProfile({
                              'fullName': nameCtrl.text.trim(),
                              'district': district,
                              'upazila': upazila,
                              'address': addressCtrl.text.trim(),
                            });
                            if (!ctx.mounted) return;
                            await _loadData();
                            widget.onRefreshParent();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('প্রোফাইল তথ্য সফলভাবে আপডেট হয়েছে!')),
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }
                        },
                        icon: const Icon(Icons.save, size: 17),
                        label: const Text('প্রোফাইল সংরক্ষণ করুন'),
                      ),
                    ),
                    const Divider(height: 28),
                    const Text('২. পাসওয়ার্ড পরিবর্তন করুন:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                    const SizedBox(height: 10),
                    TextField(
                      controller: currentPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'বর্তমান পাসওয়ার্ড *'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: newPassCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'নতুন পাসওয়ার্ড (কমপক্ষে ৪ অক্ষর) *'),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade700, foregroundColor: Colors.white),
                        onPressed: () async {
                          try {
                            await ApiService.changeMyPassword({
                              'currentPassword': currentPassCtrl.text.trim(),
                              'newPassword': newPassCtrl.text.trim(),
                            });
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে!')),
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }
                        },
                        icon: const Icon(Icons.lock_reset, size: 18),
                        label: const Text('পাসওয়ার্ড পরিবর্তন করুন'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
            ],
          );
        },
      ),
    );
  }

  void _showOfficerPayoutRequestDialog(dynamic pendingPayable) {
    final user = ApiService.currentUser ?? {};
    String method = 'বিকাশ (bKash)';
    final numberCtrl = TextEditingController(text: user['phoneNumber']?.toString() ?? '');
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('💸 বকেয়া সম্মানী উত্তোলনের অনুরোধ (Payout Request)'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আপনার বর্তমান প্রাপ্য বকেয়া সম্মানী: ৳$pendingPayable',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0B4F32)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'টাকা গ্রহণের মাধ্যম'),
                  items: const ['বিকাশ (bKash)', 'নগদ (Nagad)', 'রকেট (Rocket)', 'ব্যাংক অ্যাকাউন্ট']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => method = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: numberCtrl,
                  decoration: const InputDecoration(labelText: 'বিকাশ/নগদ বা অ্যাকাউন্ট নম্বর *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'অতিরিক্ত নোট (ঐচ্ছিক)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  final res = await ApiService.requestOfficerPayout({
                    'paymentMethod': method,
                    'accountNumber': numberCtrl.text.trim(),
                    'note': noteCtrl.text.trim(),
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message']?.toString() ?? 'উত্তোলনের অনুরোধ জমা হয়েছে!')),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              },
              icon: const Icon(Icons.send, size: 17),
              label: const Text('অনুরোধ পাঠান'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog() {
    final list = (_notificationsData['notifications'] as List<dynamic>?) ?? [];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('🔔 আমার নোটিফিকেশনসমূহ'),
            if (list.isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  await ApiService.markNotificationsRead();
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _loadData();
                },
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('সব পঠিত করুন'),
              ),
          ],
        ),
        content: SizedBox(
          width: 520,
          height: 380,
          child: list.isEmpty
              ? const Center(child: Text('কোনো নোটিফিকেশন নেই।'))
              : ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = list[i] as Map<String, dynamic>;
                    final isRead = n['readStatus'] == true;
                    return ListTile(
                      leading: Icon(
                        isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: isRead ? Colors.grey : const Color(0xFF0B4F32),
                      ),
                      title: Text(
                        n['title'] ?? '',
                        style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                      ),
                      subtitle: Text(n['message'] ?? ''),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
        ],
      ),
    );
  }

  void _showResubmitPaymentDialog() {
    final user = ApiService.currentUser ?? {};
    final paymentMethods = (_publicConfig['paymentMethods'] as List<dynamic>?) ?? [];
    final options = paymentMethods.isNotEmpty
        ? paymentMethods.map((pm) => pm['providerName'].toString()).toSet().toList()
        : ['বিকাশ (bKash)', 'নগদ (Nagad)', 'ইসলামী ব্যাংক পিএলসি'];

    String selectedMethod = user['paymentMethod']?.toString() ?? options.first;
    if (!options.contains(selectedMethod)) selectedMethod = options.first;

    final senderCtrl = TextEditingController(text: user['senderPhone']?.toString() ?? user['phoneNumber']?.toString() ?? '');
    final trxCtrl = TextEditingController(text: user['transactionId']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('সংশোধিত পেমেন্ট তথ্য (TrxID) জমা দিন'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod,
                  decoration: const InputDecoration(labelText: 'পেমেন্টের মাধ্যম'),
                  items: options.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setDialogState(() => selectedMethod = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: senderCtrl,
                  decoration: const InputDecoration(labelText: 'প্রেরক মোবাইল নম্বর *'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: trxCtrl,
                  decoration: const InputDecoration(labelText: 'সঠিক ট্রানজ্যাকশন আইডি (TrxID) *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
              onPressed: () async {
                try {
                  await ApiService.resubmitPayment({
                    'paymentMethod': selectedMethod,
                    'senderPhone': senderCtrl.text.trim(),
                    'transactionId': trxCtrl.text.trim(),
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  await _loadData();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('সংশোধিত TrxID সফলভাবে জমা হয়েছে!')),
                  );
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              },
              child: const Text('পুনরায় জমা দিন'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivateDocumentPreviewDialog(Map<String, dynamic> listing) {
    final docUrl = listing['privateDocumentUrl']?.toString() ?? '';
    final docName = listing['privateDocumentName']?.toString() ?? 'গোপনীয় দলিল';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('গোপনীয় দলিল/খতিয়ান: $docName'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (docUrl.startsWith('data:image/') || docUrl.startsWith('http'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ApiService.buildSmartImage(docUrl, height: 340, width: double.infinity, fit: BoxFit.contain),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Text('সংযুক্ত ফাইল: $docName (ডকুমেন্ট ডেটা সংরক্ষিত আছে)'),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
        ],
      ),
    );
  }

  void _showAgreementCertificateDialog(Map<String, dynamic> p) {
    final agreedFee = p['finalAgreedFeeBdt'] ?? p['adminCounterFeeBdt'] ?? p['customerProposedFeeBdt'];
    final certText = '''
===================================================
ভূমি সেতু (Bhumi Setu — LandTrust)
বিশেষ সেবা ও পারিশ্রমিক চুক্তিপত্র (Service Agreement)
===================================================
চুক্তি নম্বর: PROPOSAL-#${p['id']}
তারিখ: ${p['createdAt'] ?? ''}
অবস্থা: ${p['status']}

১ম পক্ষ (গ্রাহক): ${p['userName']} (${p['userRole']})
মোবাইল: ${p['userPhone']}

২য় পক্ষ: ভূমি সেতু (LandTrust) কর্তৃপক্ষ, নোয়াখালী

প্রস্তাবের শিরোনাম: ${p['proposalTitle']}
কাজের পরিধি: ${p['scopeDescription']}
চূড়ান্ত সম্মত পারিশ্রমিক: ৳$agreedFee (টাকা)
সময়সীমা: ${p['timelineTerms'] ?? 'আলোচনা সাপেক্ষে'}
পরিশোধের শর্ত: ${p['paymentTerms'] ?? 'চুক্তি অনুযায়ী'}
অ্যাডমিন নোট: ${p['adminNote'] ?? 'প্রযোজ্য নয়'}
===================================================
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📜 ডিজিটাল সেবা চুক্তিপত্র (Service Agreement)'),
        content: SizedBox(
          width: 540,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0B4F32)),
              ),
              child: SelectableText(
                certText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: certText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('চুক্তিপত্রটি ক্লিপবোর্ডে কপি করা হয়েছে!')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('চুক্তিপত্র কপি করুন'),
          ),
        ],
      ),
    );
  }

  void _showListingFormDialog({Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final districts = _getDistricts();
    String district = existing?['district']?.toString() ?? districts.first;
    if (!districts.contains(district)) district = districts.first;
    List<String> upazilas = _getUpazilasForDistrict(district);
    String upazila = existing?['upazila']?.toString() ?? upazilas.first;
    if (!upazilas.contains(upazila)) upazila = upazilas.first;

    final titleCtrl = TextEditingController(text: existing?['title']?.toString() ?? '');
    final areaNameCtrl = TextEditingController(text: existing?['areaName']?.toString() ?? '');
    final mouzaCtrl = TextEditingController(text: existing?['mouzaName']?.toString() ?? '');
    final khatianCtrl = TextEditingController(text: existing?['khatianNo']?.toString() ?? '');
    final dagCtrl = TextEditingController(text: existing?['dagNo']?.toString() ?? '');
    final mutationCtrl = TextEditingController(text: existing?['mutationInfo']?.toString() ?? 'নামজারি ও খাজনা হালনাগাদ');
    String landType = existing?['landType']?.toString() ?? 'আবাসিক';
    if (!const ['আবাসিক', 'বাণিজ্যিক', 'কৃষি', 'বাগান/খামার'].contains(landType)) {
      landType = 'আবাসিক';
    }
    final decimalCtrl = TextEditingController(text: existing?['areaDecimal']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: existing?['expectedPriceBdt']?.toString() ?? '');
    final feeCtrl = TextEditingController(text: existing?['proposedServiceFeeBdt']?.toString() ?? '');
    final roadCtrl = TextEditingController(text: existing?['roadAccessInfo']?.toString() ?? '');
    final videoCtrl = TextEditingController(text: existing?['videoUrl']?.toString() ?? '');
    final mapLinkCtrl = TextEditingController(text: existing?['mapLink']?.toString() ?? '');
    final descCtrl = TextEditingController(text: existing?['description']?.toString() ?? '');

    String uploadedImageDataUrl = existing?['imageUrl']?.toString() ?? '';
    String uploadedImageName = uploadedImageDataUrl.isNotEmpty ? 'সংরক্ষিত মূল ছবি' : '';
    String additionalImagesJoined = existing?['additionalImageUrls']?.toString() ?? '';
    int extraPhotoCount = additionalImagesJoined.isEmpty ? 0 : additionalImagesJoined.split('|||').where((s) => s.isNotEmpty).length;
    String uploadedDeedDataUrl = existing?['privateDocumentUrl']?.toString() ?? '';
    String uploadedDeedName = existing?['privateDocumentName']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          upazilas = _getUpazilasForDistrict(district);
          if (!upazilas.contains(upazila)) upazila = upazilas.first;

          return AlertDialog(
            title: Text(isEdit ? 'জমির বিজ্ঞাপন সম্পাদনা করুন' : 'নতুন জমির বিজ্ঞাপন ও দলিল জমা দিন'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'বিজ্ঞাপনের শিরোনাম *')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: district,
                            decoration: const InputDecoration(labelText: 'জেলা'),
                            items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setDialogState(() {
                              district = v!;
                              upazilas = _getUpazilasForDistrict(district);
                              upazila = upazilas.first;
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: upazila,
                            decoration: const InputDecoration(labelText: 'উপজেলা'),
                            items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) => setDialogState(() => upazila = v!),
                          ),
                        ),
                      ],
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
                        Expanded(child: TextField(controller: decimalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পরিমাণ (শতাংশ) *', hintText: 'যেমন: 10'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রত্যাশিত মোট মূল্য (৳) *', hintText: 'যেমন: 3500000'))),
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
                    TextField(controller: roadCtrl, decoration: const InputDecoration(labelText: 'রাস্তার তথ্য (যেমন: ১২ ফুট পাকা রাস্তা সংলগ্ন)')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: videoCtrl,
                            decoration: const InputDecoration(labelText: 'ভিডিও ট্যুর লিংক (YouTube/Drive)'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: mapLinkCtrl,
                            decoration: const InputDecoration(labelText: 'Google Maps লোকেশন লিংক'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'অতিরিক্ত বিবরণ')),
                    const SizedBox(height: 14),

                    // Device Photo, Gallery & Private Deed File Picker
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F8F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ছবি গ্যালারি ও গোপনীয় দলিল আপলোড:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final f = await FilePicker.pickFile(
                                    type: FileType.image,
                                  );
                                  if (f != null) {
                                    final bytes = await f.readAsBytes();
                                    final ext = (f.extension ?? 'jpg').toLowerCase();
                                    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
                                    setDialogState(() {
                                      uploadedImageName = f.name;
                                      uploadedImageDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
                                    });
                                  }
                                },
                                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                                label: Text(uploadedImageName.isEmpty ? 'মূল ছবি নির্বাচন করুন' : 'মূল ছবি: $uploadedImageName'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final files = await FilePicker.pickFiles(
                                    type: FileType.image,
                                  );
                                  if (files.isNotEmpty) {
                                    final List<String> dataUrls = [];
                                    for (final f in files) {
                                      final bytes = await f.readAsBytes();
                                      final ext = (f.extension ?? 'jpg').toLowerCase();
                                      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
                                      dataUrls.add('data:$mime;base64,${base64Encode(bytes)}');
                                    }
                                    setDialogState(() {
                                      additionalImagesJoined = dataUrls.join('|||');
                                      extraPhotoCount = dataUrls.length;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.collections_outlined, size: 18),
                                label: Text(
                                  extraPhotoCount == 0
                                      ? 'অতিরিক্ত একাধিক ছবি (Gallery)'
                                      : 'গ্যালারি ছবি: $extraPhotoCountটি যুক্ত',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final f = await FilePicker.pickFile(
                                    type: FileType.custom,
                                    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
                                  );
                                  if (f != null) {
                                    final bytes = await f.readAsBytes();
                                    final ext = (f.extension ?? 'jpg').toLowerCase();
                                    final mime = ext == 'pdf'
                                        ? 'application/pdf'
                                        : (ext == 'png' ? 'image/png' : 'image/jpeg');
                                    setDialogState(() {
                                      uploadedDeedName = f.name;
                                      uploadedDeedDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
                                    });
                                  }
                                },
                                icon: const Icon(Icons.upload_file_outlined, size: 18),
                                label: Text(
                                  uploadedDeedName.isEmpty
                                      ? 'গোপনীয় দলিল/খতিয়ান সংযুক্ত করুন'
                                      : 'দলিল: $uploadedDeedName',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                  final decText = decimalCtrl.text.trim().isEmpty ? '10' : decimalCtrl.text.trim();
                  final prText = priceCtrl.text.trim().isEmpty ? '1000000' : priceCtrl.text.trim();
                  final payload = {
                    'title': titleCtrl.text.trim().isEmpty ? '$upazila-এ $decText শতাংশ $landType জমি বিক্রি' : titleCtrl.text.trim(),
                    'district': district,
                    'upazila': upazila,
                    'areaName': areaNameCtrl.text.trim(),
                    'mouzaName': mouzaCtrl.text.trim(),
                    'khatianNo': khatianCtrl.text.trim(),
                    'dagNo': dagCtrl.text.trim(),
                    'mutationInfo': mutationCtrl.text.trim(),
                    'landType': landType,
                    'areaDecimal': decText,
                    'expectedPriceBdt': prText,
                    'proposedServiceFeeBdt': feeCtrl.text.trim().isEmpty ? '0' : feeCtrl.text.trim(),
                    'roadAccessInfo': roadCtrl.text.trim().isEmpty ? 'পাকা রাস্তা সংলগ্ন' : roadCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'imageUrl': uploadedImageDataUrl,
                    'additionalImageUrls': additionalImagesJoined,
                    'videoUrl': videoCtrl.text.trim(),
                    'mapLink': mapLinkCtrl.text.trim(),
                    'privateDocumentUrl': uploadedDeedDataUrl,
                    'privateDocumentName': uploadedDeedName,
                  };
                  if (isEdit) {
                    await ApiService.updateMyListing(existing['id'] as int, payload);
                  } else {
                    await ApiService.createListing(payload);
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _loadData();
                  widget.onRefreshParent();
                },
                child: Text(isEdit ? 'আপডেট সংরক্ষণ করুন' : 'জমা দিন'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRequirementFormDialog({Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final districts = _getDistricts();
    String district = existing?['preferredDistrict']?.toString() ?? districts.first;
    if (!districts.contains(district)) district = districts.first;
    List<String> upazilas = _getUpazilasForDistrict(district);
    String upazila = existing?['preferredUpazila']?.toString() ?? upazilas.first;
    if (!upazilas.contains(upazila)) upazila = upazilas.first;

    String landType = existing?['landType']?.toString() ?? 'আবাসিক';
    if (!const ['আবাসিক', 'বাণিজ্যিক', 'কৃষি', 'বাগান/খামার'].contains(landType)) {
      landType = 'আবাসিক';
    }
    final areaCtrl = TextEditingController(text: existing?['preferredArea']?.toString() ?? '');
    final minDecCtrl = TextEditingController(text: existing?['minAreaDecimal']?.toString() ?? '');
    final maxDecCtrl = TextEditingController(text: existing?['maxAreaDecimal']?.toString() ?? '');
    final minBudCtrl = TextEditingController(text: existing?['minBudgetBdt']?.toString() ?? '');
    final maxBudCtrl = TextEditingController(text: existing?['maxBudgetBdt']?.toString() ?? '');
    final purposeCtrl = TextEditingController(text: existing?['purpose']?.toString() ?? 'আবাসিক বাড়ি নির্মাণ');
    final timelineCtrl = TextEditingController(text: existing?['purchaseTimeline']?.toString() ?? '১-৩ মাসের মধ্যে');
    final feeCtrl = TextEditingController(text: existing?['proposedServiceFeeBdt']?.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?['specialRequirements']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          upazilas = _getUpazilasForDistrict(district);
          if (!upazilas.contains(upazila)) upazila = upazilas.first;

          return AlertDialog(
            title: Text(isEdit ? 'জমির চাহিদা সম্পাদনা করুন' : 'জমি কেনার চাহিদা নিবন্ধন করুন'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: district,
                            decoration: const InputDecoration(labelText: 'পছন্দের জেলা'),
                            items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                            onChanged: (v) => setDialogState(() {
                              district = v!;
                              upazilas = _getUpazilasForDistrict(district);
                              upazila = upazilas.first;
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: upazila,
                            decoration: const InputDecoration(labelText: 'পছন্দের উপজেলা'),
                            items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) => setDialogState(() => upazila = v!),
                          ),
                        ),
                      ],
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
                        Expanded(child: TextField(controller: minDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন পরিমাণ (শতাংশ)', hintText: 'যেমন: 5'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: maxDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ পরিমাণ (শতাংশ)', hintText: 'যেমন: 15'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: minBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন বাজেট (৳)', hintText: 'যেমন: 1500000'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: maxBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (৳)', hintText: 'যেমন: 3500000'))),
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
                  final payload = {
                    'preferredDistrict': district,
                    'preferredUpazila': upazila,
                    'preferredArea': areaCtrl.text.trim(),
                    'landType': landType,
                    'minAreaDecimal': minDecCtrl.text.trim().isEmpty ? '5' : minDecCtrl.text.trim(),
                    'maxAreaDecimal': maxDecCtrl.text.trim().isEmpty ? '15' : maxDecCtrl.text.trim(),
                    'minBudgetBdt': minBudCtrl.text.trim().isEmpty ? '1000000' : minBudCtrl.text.trim(),
                    'maxBudgetBdt': maxBudCtrl.text.trim().isEmpty ? '3000000' : maxBudCtrl.text.trim(),
                    'purpose': purposeCtrl.text.trim(),
                    'purchaseTimeline': timelineCtrl.text.trim(),
                    'proposedServiceFeeBdt': feeCtrl.text.trim().isEmpty ? '0' : feeCtrl.text.trim(),
                    'specialRequirements': notesCtrl.text.trim(),
                  };
                  if (isEdit) {
                    await ApiService.updateMyRequirement(existing['id'] as int, payload);
                  } else {
                    await ApiService.createRequirement(payload);
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _loadData();
                  widget.onRefreshParent();
                },
                child: Text(isEdit ? 'আপডেট সংরক্ষণ করুন' : 'চাহিদা জমা দিন'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddProposalDialog() {
    final titleCtrl = TextEditingController();
    final scopeCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
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
                TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'আপনার প্রস্তাবিত নির্দিষ্ট পারিশ্রমিক (৳) *', hintText: 'যেমন: 100000')),
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
                'proposalTitle': titleCtrl.text.trim().isEmpty ? 'বিশেষ ক্রয়/বিক্রয় সহায়তা চুক্তি' : titleCtrl.text.trim(),
                'scopeDescription': scopeCtrl.text.trim(),
                'customerProposedFeeBdt': feeCtrl.text.trim().isEmpty ? '50000' : feeCtrl.text.trim(),
                'timelineTerms': timelineCtrl.text.trim(),
                'paymentTerms': termsCtrl.text.trim(),
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
      'ACTIVE' || 'APPROVED_PUBLISHED' || 'MUTUALLY_AGREED' || 'COMPLETED' || 'FULFILLED' => (status!, Colors.green.shade700),
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
