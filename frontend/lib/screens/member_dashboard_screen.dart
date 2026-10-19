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
    final isMobile = MediaQuery.of(context).size.width < 768;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Header Card
                Container(
                  padding: EdgeInsets.all(isMobile ? 14 : 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0B4F32), Color(0xFF146C43)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_user, color: Colors.amberAccent, size: 24),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    user['fullName'] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _statusChip(status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ভূমিকা: ${_roleBangla(role)} • মোবাইল: ${user['phoneNumber']} • ${user['upazila'] ?? 'নোয়াখালী সদর'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      if (user['referredByCode'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'রেফারেল কোড: ${user['referredByCode']} (${user['referredByOfficerName'] ?? ''})',
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Action Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () => _showProfileAndPasswordDialog(isMobile),
                            icon: const Icon(Icons.manage_accounts_outlined, size: 16),
                            label: const Text('প্রোফাইল ও পাসওয়ার্ড', style: TextStyle(fontSize: 12)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: unreadCount > 0 ? Colors.amber.shade600 : Colors.white24,
                              foregroundColor: unreadCount > 0 ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: _showNotificationsDialog,
                            icon: Badge(
                              isLabelVisible: unreadCount > 0,
                              label: Text('$unreadCount'),
                              child: const Icon(Icons.notifications_active_outlined, size: 16),
                            ),
                            label: Text('নোটিফিকেশন ($unreadCount)', style: const TextStyle(fontSize: 12)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0B4F32),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('রিফ্রেশ', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Payment Verification / Resubmit Banner
                if (status != 'ACTIVE') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: status == 'REJECTED' ? Colors.red.shade50 : Colors.amber.shade50,
                      border: Border.all(color: status == 'REJECTED' ? Colors.red.shade400 : Colors.amber.shade600),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              status == 'REJECTED' ? Icons.error_outline : Icons.info_outline,
                              color: status == 'REJECTED' ? Colors.red.shade700 : Colors.orange.shade800,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                status == 'REJECTED'
                                    ? 'পেমেন্ট তথ্য (TrxID: ${user['transactionId']}) মেলেনি বা বাতিল হয়েছে।'
                                    : 'নিবন্ধন ফি (৳${user['registrationFeeAmount']}) ও TrxID (${user['transactionId']}) যাচাই চলছে।',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        if (user['adminNote'] != null && user['adminNote'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('নোট: ${user['adminNote']}', style: TextStyle(color: Colors.red.shade900, fontSize: 12)),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () => _showResubmitPaymentDialog(isMobile),
                            icon: const Icon(Icons.edit_note, size: 16),
                            label: const Text('সঠিক TrxID পুনরায় জমা দিন', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Dual Buyer-Seller & Officer Mode Switcher Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('মোড: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0B4F32))),
                        if (role == 'MARKETING_OFFICER') ...[
                          ChoiceChip(
                            selected: currentMode == 'MARKETING_OFFICER',
                            selectedColor: const Color(0xFF0B4F32),
                            labelStyle: TextStyle(
                              color: currentMode == 'MARKETING_OFFICER' ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            label: const Text('📊 মার্কেটিং অফিসার'),
                            onSelected: (_) => setState(() => _activePortalMode = 'MARKETING_OFFICER'),
                          ),
                          const SizedBox(width: 6),
                        ],
                        ChoiceChip(
                          selected: currentMode == 'BUYER',
                          selectedColor: const Color(0xFF0B4F32),
                          labelStyle: TextStyle(
                            color: currentMode == 'BUYER' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          label: Text('🛒 ক্রেতা (${_myRequirements.length})'),
                          onSelected: (_) => setState(() => _activePortalMode = 'BUYER'),
                        ),
                        const SizedBox(width: 6),
                        ChoiceChip(
                          selected: currentMode == 'SELLER',
                          selectedColor: const Color(0xFF0B4F32),
                          labelStyle: TextStyle(
                            color: currentMode == 'SELLER' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          label: Text('🏞️ বিক্রেতা (${_myListings.length})'),
                          onSelected: (_) => setState(() => _activePortalMode = 'SELLER'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (currentMode == 'MARKETING_OFFICER') _buildMarketingOfficerView(isMobile),
                if (currentMode == 'SELLER') _buildSellerView(isMobile),
                if (currentMode == 'BUYER') _buildBuyerView(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MARKETING OFFICER VIEW ====================
  Widget _buildMarketingOfficerView(bool isMobile) {
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
        // Referral Code Banner
        Card(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'আপনার রেফারেল কোড ও লিংক',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                ),
                const SizedBox(height: 4),
                Text(
                  'এই লিংক বা কোড দিয়ে নিবন্ধন করলে কমিশন যুক্ত হবে (পরিশোধিত: ৳$totalPaid)।',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0B4F32), width: 1.2),
                      ),
                      child: SelectableText(
                        code.toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B4F32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code.toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('রেফারেল কোড ($code) কপি করা হয়েছে!')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 15),
                      label: const Text('কোড কপি', style: TextStyle(fontSize: 11)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('শেয়ার লিংক কপি হয়েছে: $shareLink')),
                        );
                      },
                      icon: const Icon(Icons.link, size: 16),
                      label: const Text('লিংক কপি', style: TextStyle(fontSize: 11)),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () => _showOfficerPayoutRequestDialog(pendingPayable, isMobile),
                      icon: const Icon(Icons.payments_outlined, size: 16),
                      label: Text('উত্তোলন (৳$pendingPayable)', style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 4 Responsive KPI Cards
        LayoutBuilder(
          builder: (ctx, constraints) {
            final cardWidth = isMobile
                ? (constraints.maxWidth - 10) / 2
                : (constraints.maxWidth - 36) / 4;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _kpiCard('মোট রেফারকৃত', '$totalReferred জন', Icons.people_alt, Colors.blue.shade700, cardWidth),
                _kpiCard('যাচাইকৃত সক্রিয়', '$verifiedReferred জন', Icons.verified, Colors.green.shade700, cardWidth),
                _kpiCard('অর্জিত সম্মানী', '৳$totalEarned', Icons.account_balance_wallet, Colors.teal.shade800, cardWidth),
                _kpiCard('বকেয়া প্রাপ্য', '৳$pendingPayable', Icons.payments, Colors.deepOrange.shade700, cardWidth),
              ],
            );
          },
        ),
        const SizedBox(height: 18),

        // Referred Users List
        const Text(
          '১. আপনার রেফারেল কোড ব্যবহারকারী সদস্যগণ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (referredUsers.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('এখনো আপনার রেফারেল কোড ব্যবহার করে কেউ নিবন্ধন করেননি।'),
            ),
          )
        else
          ...referredUsers.map((u) {
            final uStatus = u['accountStatus'] ?? 'PAYMENT_SUBMITTED';
            final earned = u['commissionEarnedFromUser'] ?? 0;
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
                        Text(
                          '${u['fullName']} (${_roleBangla(u['role'])})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        _statusChip(uStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('উপজেলা: ${u['upazila'] ?? 'নোয়াখালী'} • মোবাইল: ${u['phoneNumber']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.teal.shade300),
                      ),
                      child: Text('অর্জিত কমিশন: ৳$earned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.teal.shade900)),
                    ),
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 18),
        // Commission Ledger
        const Text(
          '২. সম্মানী ও কমিশনের হিসাব বিবরণী',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (commissions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('এখনো কোনো কমিশন রেকর্ড জমা হয়নি।'),
            ),
          )
        else
          ...commissions.map((c) {
            final isPaid = c['status'] == 'PAID';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle : Icons.schedule,
                      color: isPaid ? Colors.green : Colors.orange,
                      size: 24,
                    ),
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

        const SizedBox(height: 18),
        // Training Guidelines
        Card(
          color: const Color(0xFFF3F8F5),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('📘 মার্কেটিং অফিসার কাজের নির্দেশিকা:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0B4F32))),
                SizedBox(height: 6),
                Text(
                  '• গ্রাহককে আপনার রেফারেল লিংক বা কোড ব্যবহারে উৎসাহিত করুন।\n'
                  '• গ্রাহকের TrxID অ্যাডমিন কর্তৃক যাচাই হলেই স্বয়ংক্রিয়ভাবে আপনার বোনাস যুক্ত হবে।\n'
                  '• লেনদেন সফল হলে ডিল ক্লোজার কমিশন পাবেন এবং বকেয়া জমা হলে উইথড্র রিকোয়েস্ট পাঠান।',
                  style: TextStyle(fontSize: 12, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== SELLER VIEW ====================
  Widget _buildSellerView(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'আমার জমির বিজ্ঞাপন (${_myListings.length})',
              style: TextStyle(fontSize: isMobile ? 17 : 19, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onPressed: () => _showListingFormDialog(isMobile: isMobile),
                  icon: const Icon(Icons.add_home_work, size: 16),
                  label: const Text('নতুন বিজ্ঞাপন জমা দিন', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAddProposalDialog(isMobile),
                  icon: const Icon(Icons.handshake, size: 16),
                  label: const Text('বিশেষ সেবা প্রস্তাব', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_myListings.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('আপনি এখনো কোনো জমির বিজ্ঞাপন জমা দেননি। উপরের বাটনে ক্লিক করে তথ্য জমা দিন।'),
            ),
          )
        else
          ..._myListings.map((l) {
            final mapItem = l as Map<String, dynamic>;
            final hasPrivateDoc = mapItem['privateDocumentUrl'] != null && mapItem['privateDocumentUrl'].toString().isNotEmpty;
            final isSold = mapItem['listingStatus'] == 'SOLD';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ApiService.buildSmartImage(
                            mapItem['imageUrl'] as String?,
                            height: isMobile ? 60 : 70,
                            width: isMobile ? 80 : 95,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mapItem['title'] ?? '',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _verificationBadge(mapItem['verificationStatus']),
                                  _statusChip(mapItem['listingStatus']),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'অবস্থান: ${mapItem['areaName']}, ${mapItem['upazila']}, ${mapItem['district']} • মৌজা: ${mapItem['mouzaName'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'পরিমাণ: ${mapItem['areaDecimal']} শতাংশ • মূল্য: ৳${mapItem['expectedPriceBdt']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B4F32)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showListingFormDialog(existing: mapItem, isMobile: isMobile),
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('সম্পাদনা (Edit)', style: TextStyle(fontSize: 11)),
                        ),
                        if (hasPrivateDoc)
                          OutlinedButton.icon(
                            onPressed: () => _showPrivateDocumentPreviewDialog(mapItem, isMobile),
                            icon: const Icon(Icons.description_outlined, size: 15),
                            label: const Text('সংযুক্ত দলিল দেখুন', style: TextStyle(fontSize: 11)),
                          ),
                        if (!isSold)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700),
                            onPressed: () async {
                              await ApiService.closeListing(mapItem['id'] as int);
                              await _loadData();
                              widget.onRefreshParent();
                            },
                            icon: const Icon(Icons.lock_outline, size: 15),
                            label: const Text('বিক্রি সম্পন্ন (SOLD)', style: TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 18),
        _buildMyProposalsSection(isMobile),
      ],
    );
  }

  // ==================== BUYER VIEW ====================
  Widget _buildBuyerView(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'আমার জমি কেনার চাহিদা (${_myRequirements.length})',
              style: TextStyle(fontSize: isMobile ? 17 : 19, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B4F32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onPressed: () => _showRequirementFormDialog(isMobile: isMobile),
                  icon: const Icon(Icons.post_add, size: 16),
                  label: const Text('নতুন চাহিদা দিন', style: TextStyle(fontSize: 12)),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showAddProposalDialog(isMobile),
                  icon: const Icon(Icons.handshake, size: 16),
                  label: const Text('বিশেষ সেবা প্রস্তাব', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${reqItem['preferredUpazila']}, ${reqItem['preferredDistrict']} (${reqItem['landType']})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                        ),
                        _statusChip(reqItem['status']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'পরিমাণ: ${reqItem['minAreaDecimal']}–${reqItem['maxAreaDecimal']} শতাংশ • বাজেট: ৳${reqItem['minBudgetBdt']}–৳${reqItem['maxBudgetBdt']}',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showRequirementFormDialog(existing: reqItem, isMobile: isMobile),
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('সম্পাদনা (Edit)', style: TextStyle(fontSize: 11)),
                        ),
                        if (!isFulfilled)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.green.shade800),
                            onPressed: () async {
                              await ApiService.fulfillMyRequirement(reqItem['id'] as int);
                              await _loadData();
                              widget.onRefreshParent();
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 15),
                            label: const Text('চাহিদা পূরণ হয়েছে', style: TextStyle(fontSize: 11)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 18),
        const Text(
          'আমার আগ্রহ প্রকাশের তালিকা (Inquiries)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_myInquiries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('হোম পেজ থেকে কোনো জমিতে আগ্রহ প্রকাশ করলে তা এখানে দেখা যাবে।'),
            ),
          )
        else
          ..._myInquiries.map((inq) => Card(
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
                      _statusChip(inq['status']),
                    ],
                  ),
                ),
              )),
        const SizedBox(height: 18),
        _buildMyProposalsSection(isMobile),
      ],
    );
  }

  Widget _buildMyProposalsSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'বিশেষ সেবা প্রস্তাবনা (Custom Proposals)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_myProposals.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('জমি কেনা বা বিক্রির জন্য বিশেষ চুক্তি প্রস্তাব দিলে এখানে দেখা যাবে।'),
            ),
          )
        else
          ..._myProposals.map((p) {
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
                          child: Text(p['proposalTitle'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                        _statusChip(p['status']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(p['scopeDescription'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(
                      'প্রস্তাবিত পারিশ্রমিক: ৳${p['customerProposedFeeBdt']}${p['finalAgreedFeeBdt'] != null ? ' | চূড়ান্ত: ৳${p['finalAgreedFeeBdt']}' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0B4F32)),
                    ),
                    if (isAgreed) ...[
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _showAgreementCertificateDialog(p as Map<String, dynamic>, isMobile),
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

  // ==================== DIALOGS ====================

  void _showProfileAndPasswordDialog(bool isMobile) {
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
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
            title: const Text('⚙️ প্রোফাইল ও পাসওয়ার্ড', style: TextStyle(fontSize: 16)),
            content: SizedBox(
              width: isMobile ? double.infinity : 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('১. ব্যক্তিগত তথ্য:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'পূর্ণ নাম *', isDense: true)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: district,
                      decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
                      items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setDialogState(() {
                        district = v!;
                        upazilas = _getUpazilasForDistrict(district);
                        upazila = upazilas.first;
                      }),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: upazila,
                      decoration: const InputDecoration(labelText: 'উপজেলা', isDense: true),
                      items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setDialogState(() => upazila = v!),
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'বিস্তারিত ঠিকানা', isDense: true)),
                    const SizedBox(height: 8),
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
                              const SnackBar(content: Text('প্রোফাইল আপডেট হয়েছে!')),
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                            }
                          }
                        },
                        icon: const Icon(Icons.save, size: 15),
                        label: const Text('সংরক্ষণ করুন', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const Divider(height: 22),
                    const Text('২. পাসওয়ার্ড পরিবর্তন:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(controller: currentPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'বর্তমান পাসওয়ার্ড *', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'নতুন পাসওয়ার্ড *', isDense: true)),
                    const SizedBox(height: 8),
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
                        icon: const Icon(Icons.lock_reset, size: 15),
                        label: const Text('পাসওয়ার্ড পরিবর্তন', style: TextStyle(fontSize: 12)),
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

  void _showOfficerPayoutRequestDialog(dynamic pendingPayable, bool isMobile) {
    final user = ApiService.currentUser ?? {};
    String method = 'বিকাশ (bKash)';
    final numberCtrl = TextEditingController(text: user['phoneNumber']?.toString() ?? '');
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('💸 সম্মানী উত্তোলনের অনুরোধ', style: TextStyle(fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('বর্তমান বকেয়া সম্মানী: ৳$pendingPayable', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: method,
                  decoration: const InputDecoration(labelText: 'মাধ্যম', isDense: true),
                  items: const ['বিকাশ (bKash)', 'নগদ (Nagad)', 'রকেট (Rocket)', 'ব্যাংক অ্যাকাউন্ট']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => method = v!),
                ),
                const SizedBox(height: 8),
                TextField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'বিকাশ/নগদ নম্বর *', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: noteCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'নোট (ঐচ্ছিক)', isDense: true)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
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
                    SnackBar(content: Text(res['message']?.toString() ?? 'অনুরোধ জমা হয়েছে!')),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                }
              },
              child: const Text('অনুরোধ পাঠান'),
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
            const Text('🔔 নোটিফিকেশন', style: TextStyle(fontSize: 16)),
            if (list.isNotEmpty)
              TextButton.icon(
                onPressed: () async {
                  await ApiService.markNotificationsRead();
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _loadData();
                },
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('সব পঠিত', style: TextStyle(fontSize: 11)),
              ),
          ],
        ),
        content: SizedBox(
          width: 480,
          height: 350,
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
                        size: 20,
                      ),
                      title: Text(n['title'] ?? '', style: TextStyle(fontSize: 13, fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(n['message'] ?? '', style: const TextStyle(fontSize: 11)),
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

  void _showResubmitPaymentDialog(bool isMobile) {
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
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
          title: const Text('সঠিক TrxID পুনরায় জমা দিন', style: TextStyle(fontSize: 16)),
          content: SizedBox(
            width: isMobile ? double.infinity : 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedMethod,
                  decoration: const InputDecoration(labelText: 'পেমেন্টের মাধ্যম', isDense: true),
                  items: options.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setDialogState(() => selectedMethod = v!),
                ),
                const SizedBox(height: 8),
                TextField(controller: senderCtrl, decoration: const InputDecoration(labelText: 'প্রেরক মোবাইল নম্বর *', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: trxCtrl, decoration: const InputDecoration(labelText: 'সঠিক TrxID *', isDense: true)),
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
                  if (mounted) {
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

  void _showPrivateDocumentPreviewDialog(Map<String, dynamic> listing, bool isMobile) {
    final docUrl = listing['privateDocumentUrl']?.toString() ?? '';
    final docName = listing['privateDocumentName']?.toString() ?? 'গোপনীয় দলিল';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
        title: Text('দলিল/খতিয়ান: $docName', style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: isMobile ? double.infinity : 540,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (docUrl.startsWith('data:image/') || docUrl.startsWith('http'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ApiService.buildSmartImage(
                      docUrl,
                      height: isMobile ? 260 : 340,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      enableZoom: true,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                    child: Text('সংযুক্ত ফাইল: $docName'),
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

  void _showAgreementCertificateDialog(Map<String, dynamic> p, bool isMobile) {
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
===================================================
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
        title: const Text('📜 ডিজিটাল চুক্তিপত্র', style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: isMobile ? double.infinity : 520,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBF7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0B4F32)),
              ),
              child: SelectableText(
                certText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
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
                const SnackBar(content: Text('চুক্তিপত্রটি কপি করা হয়েছে!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('কপি করুন'),
          ),
        ],
      ),
    );
  }

  void _showListingFormDialog({Map<String, dynamic>? existing, bool isMobile = false}) {
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
    String uploadedImageName = uploadedImageDataUrl.isNotEmpty ? 'সংরক্ষিত ছবি' : '';
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
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
            title: Text(isEdit ? 'বিজ্ঞাপন সম্পাদনা' : 'নতুন জমির বিজ্ঞাপন জমা দিন', style: const TextStyle(fontSize: 16)),
            content: SizedBox(
              width: isMobile ? double.infinity : 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'বিজ্ঞাপনের শিরোনাম *', isDense: true)),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (c, cs) {
                        final half = isMobile ? cs.maxWidth : (cs.maxWidth - 8) / 2;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SizedBox(
                              width: half,
                              child: DropdownButtonFormField<String>(
                                value: district,
                                decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
                                items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                onChanged: (v) => setDialogState(() {
                                  district = v!;
                                  upazilas = _getUpazilasForDistrict(district);
                                  upazila = upazilas.first;
                                }),
                              ),
                            ),
                            SizedBox(
                              width: half,
                              child: DropdownButtonFormField<String>(
                                value: upazila,
                                decoration: const InputDecoration(labelText: 'উপজেলা', isDense: true),
                                items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) => setDialogState(() => upazila = v!),
                              ),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: areaNameCtrl, decoration: const InputDecoration(labelText: 'এলাকা / ইউনিয়ন *', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: mouzaCtrl, decoration: const InputDecoration(labelText: 'মৌজার নাম', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: DropdownButtonFormField<String>(
                                value: landType,
                                decoration: const InputDecoration(labelText: 'জমির ধরন', isDense: true),
                                items: const ['আবাসিক', 'বাণিজ্যিক', 'কৃষি', 'বাগান/খামার']
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (v) => setDialogState(() => landType = v!),
                              ),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: decimalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'পরিমাণ (শতাংশ) *', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রত্যাশিত মোট মূল্য (৳) *', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রস্তাবিত পারিশ্রমিক (৳)', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: khatianCtrl, decoration: const InputDecoration(labelText: 'খতিয়ান নং (গোপনীয়)', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: dagCtrl, decoration: const InputDecoration(labelText: 'দাগ নং (গোপনীয়)', isDense: true)),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: mutationCtrl, decoration: const InputDecoration(labelText: 'নামজারি ও খাজনার অবস্থা', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: roadCtrl, decoration: const InputDecoration(labelText: 'রাস্তার বিবরণ (যেমন: ১২ ফুট পাকা রাস্তা)', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: videoCtrl, decoration: const InputDecoration(labelText: 'ভিডিও ট্যুর লিংক (ঐচ্ছিক)', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: mapLinkCtrl, decoration: const InputDecoration(labelText: 'Google Maps লিংক (ঐচ্ছিক)', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'অতিরিক্ত বিবরণ', isDense: true)),
                    const SizedBox(height: 12),

                    // File Pickers
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F8F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ছবি ও গোপনীয় দলিল আপলোড:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final f = await FilePicker.pickFile(type: FileType.image);
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
                                icon: const Icon(Icons.photo_camera, size: 16),
                                label: Text(uploadedImageName.isEmpty ? 'মূল ছবি নির্বাচন' : uploadedImageName, style: const TextStyle(fontSize: 11)),
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final files = await FilePicker.pickFiles(type: FileType.image);
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
                                icon: const Icon(Icons.collections, size: 16),
                                label: Text(extraPhotoCount == 0 ? 'গ্যালারি ছবি (+)' : 'গ্যালারি ($extraPhotoCount)', style: const TextStyle(fontSize: 11)),
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
                                    final mime = ext == 'pdf' ? 'application/pdf' : (ext == 'png' ? 'image/png' : 'image/jpeg');
                                    setDialogState(() {
                                      uploadedDeedName = f.name;
                                      uploadedDeedDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
                                    });
                                  }
                                },
                                icon: const Icon(Icons.upload_file, size: 16),
                                label: Text(uploadedDeedName.isEmpty ? 'দলিল/খতিয়ান সংযুক্ত' : uploadedDeedName, style: const TextStyle(fontSize: 11)),
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
                    'title': titleCtrl.text.trim().isEmpty ? '$upazila-এ $decText শতাংশ $landType জমি' : titleCtrl.text.trim(),
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
                child: Text(isEdit ? 'আপডেট' : 'জমা দিন'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRequirementFormDialog({Map<String, dynamic>? existing, bool isMobile = false}) {
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
    final purposeCtrl = TextEditingController(text: existing?['purpose']?.toString() ?? 'বাড়ি নির্মাণ');
    final timelineCtrl = TextEditingController(text: existing?['purchaseTimeline']?.toString() ?? '১-৩ মাস');
    final feeCtrl = TextEditingController(text: existing?['proposedServiceFeeBdt']?.toString() ?? '');
    final notesCtrl = TextEditingController(text: existing?['specialRequirements']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          upazilas = _getUpazilasForDistrict(district);
          if (!upazilas.contains(upazila)) upazila = upazilas.first;

          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
            title: Text(isEdit ? 'চাহিদা সম্পাদনা' : 'জমি কেনার চাহিদা দিন', style: const TextStyle(fontSize: 16)),
            content: SizedBox(
              width: isMobile ? double.infinity : 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LayoutBuilder(
                      builder: (c, cs) {
                        final half = isMobile ? cs.maxWidth : (cs.maxWidth - 8) / 2;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SizedBox(
                              width: half,
                              child: DropdownButtonFormField<String>(
                                value: district,
                                decoration: const InputDecoration(labelText: 'পছন্দের জেলা', isDense: true),
                                items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                onChanged: (v) => setDialogState(() {
                                  district = v!;
                                  upazilas = _getUpazilasForDistrict(district);
                                  upazila = upazilas.first;
                                }),
                              ),
                            ),
                            SizedBox(
                              width: half,
                              child: DropdownButtonFormField<String>(
                                value: upazila,
                                decoration: const InputDecoration(labelText: 'পছন্দের উপজেলা', isDense: true),
                                items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) => setDialogState(() => upazila = v!),
                              ),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'পছন্দের এলাকা', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: DropdownButtonFormField<String>(
                                value: landType,
                                decoration: const InputDecoration(labelText: 'জমির ধরন', isDense: true),
                                items: const ['আবাসিক', 'বাণিজ্যিক', 'কৃষি', 'বাগান/খামার']
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (v) => setDialogState(() => landType = v!),
                              ),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: minDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন শতাংশ', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: maxDecCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ শতাংশ', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: minBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বনিম্ন বাজেট (৳)', isDense: true)),
                            ),
                            SizedBox(
                              width: half,
                              child: TextField(controller: maxBudCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (৳)', isDense: true)),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: purposeCtrl, decoration: const InputDecoration(labelText: 'কেনার উদ্দেশ্য', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: timelineCtrl, decoration: const InputDecoration(labelText: 'সময়সীমা', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রস্তাবিত পারিশ্রমিক (৳)', isDense: true)),
                    const SizedBox(height: 8),
                    TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'অন্যান্য বিশেষ শর্ত', isDense: true)),
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
                child: Text(isEdit ? 'আপডেট' : 'চাহিদা জমা দিন'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddProposalDialog(bool isMobile) {
    final titleCtrl = TextEditingController();
    final scopeCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    final timelineCtrl = TextEditingController(text: '২ মাসের মধ্যে');
    final termsCtrl = TextEditingController(text: 'বায়না চুক্তির সময় ৫০% এবং রেজিস্ট্রেশনের দিন ৫০%');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 16),
        title: const Text('বিশেষ সেবা প্রস্তাব', style: TextStyle(fontSize: 16)),
        content: SizedBox(
          width: isMobile ? double.infinity : 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'প্রস্তাবের শিরোনাম *', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: scopeCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'কাজের পরিধি ও শর্তাবলি *', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রস্তাবিত পারিশ্রমিক (৳) *', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: timelineCtrl, decoration: const InputDecoration(labelText: 'সময়সীমা', isDense: true)),
                const SizedBox(height: 8),
                TextField(controller: termsCtrl, decoration: const InputDecoration(labelText: 'অর্থ পরিশোধের শর্ত', isDense: true)),
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
                'proposalTitle': titleCtrl.text.trim().isEmpty ? 'বিশেষ ক্রয়/বিক্রয় চুক্তি' : titleCtrl.text.trim(),
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

  Widget _kpiCard(String title, String value, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54), overflow: TextOverflow.ellipsis),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleBangla(String? role) {
    return switch (role) {
      'SELLER' => 'বিক্রেতা',
      'MARKETING_OFFICER' => 'মার্কেটিং অফিসার',
      'ADMIN' => 'অ্যাডমিন',
      _ => 'ক্রেতা',
    };
  }

  Widget _verificationBadge(String? status) {
    final (label, color) = switch (status) {
      'FIELD_VERIFIED' => ('🟢 যাচাইকৃত', Colors.green.shade800),
      'DOC_CHECKED' => ('🔵 প্রাথমিক যাচাই', Colors.blue.shade800),
      _ => ('⚪ অনির্দিষ্ট', Colors.grey.shade700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _statusChip(String? status) {
    final (label, color) = switch (status) {
      'ACTIVE' || 'APPROVED_PUBLISHED' || 'MUTUALLY_AGREED' || 'COMPLETED' || 'FULFILLED' => (status!, Colors.green.shade700),
      'SUSPENDED' || 'REJECTED' => (status!, Colors.red.shade700),
      _ => (status ?? 'PENDING', Colors.orange.shade800),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
