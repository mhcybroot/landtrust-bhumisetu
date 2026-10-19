import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/member_dashboard_screen.dart';
import 'screens/admin_panel_screen.dart';

void main() {
  runApp(const LandTrustApp());
}

class LandTrustApp extends StatelessWidget {
  const LandTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ভূমি সেতু (LandTrust) — ক্রেতা-বিক্রেতার বিশ্বস্ত সংযোগ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B4F32),
          primary: const Color(0xFF0B4F32),
          secondary: const Color(0xFFD97706),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
      ),
      home: const MainShellScreen(),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  bool _loading = true;

  Map<String, dynamic> _config = {};
  Map<String, dynamic> _stats = {};
  List<dynamic> _listings = [];
  List<dynamic> _requirements = [];

  // Search Filters
  String _filterUpazila = '';
  String _filterLandType = '';
  final TextEditingController _maxBudgetCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        ApiService.getPublicConfig(),
        ApiService.getPublicStats(),
        ApiService.getPublicListings(
          upazila: _filterUpazila.isEmpty ? null : _filterUpazila,
          landType: _filterLandType.isEmpty ? null : _filterLandType,
          maxBudget: _maxBudgetCtrl.text.trim().isEmpty ? null : _maxBudgetCtrl.text.trim(),
        ),
        ApiService.getPublicRequirements(),
      ]);
      _config = res[0] as Map<String, dynamic>;
      _stats = res[1] as Map<String, dynamic>;
      _listings = res[2] as List<dynamic>;
      _requirements = res[3] as List<dynamic>;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('সার্ভার সংযোগ ত্রুটি: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final isAdmin = user != null && user['role'] == 'ADMIN';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B4F32),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Logo & Slogan
                InkWell(
                  onTap: () => setState(() => _selectedIndex = 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.landscape, color: Color(0xFF0B4F32), size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ভূমি সেতু (LandTrust)',
                            style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ক্রেতা-বিক্রেতার বিশ্বস্ত সংযোগ • নোয়াখালী',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Navigation Buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _navButton(0, Icons.home, 'হোম ও জমি অনুসন্ধান'),
                      _navButton(1, Icons.assignment, 'জমি কিনতে চাই (${_requirements.length})'),
                      _navButton(2, Icons.policy, 'নিয়মাবলি ও ফি'),
                      if (user == null)
                        _navButton(3, Icons.person_add_alt_1, 'নিবন্ধন / লগইন')
                      else ...[
                        _navButton(
                          3,
                          isAdmin ? Icons.admin_panel_settings : Icons.dashboard_customize,
                          isAdmin ? 'অ্যাডমিন প্যানেল' : 'আমার পোর্টাল (${user['role']})',
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
                          onPressed: () {
                            ApiService.logout();
                            setState(() => _selectedIndex = 0);
                          },
                          icon: const Icon(Icons.logout, size: 18),
                          label: const Text('লগআউট'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeAndSearchTab(),
                _buildBuyerDemandsPublicTab(),
                _buildRulesAndFeesTab(),
                user == null
                    ? _buildAuthAndRegistrationTab()
                    : (isAdmin
                        ? AdminPanelScreen(onConfigChanged: _loadInitialData)
                        : MemberDashboardScreen(onRefreshParent: _loadInitialData)),
              ],
            ),
    );
  }

  Widget _navButton(int index, IconData icon, String label) {
    final active = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: active ? Colors.white : Colors.transparent,
          foregroundColor: active ? const Color(0xFF0B4F32) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => setState(() => _selectedIndex = index),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  // ==================== TAB 0: HOME & LAND SEARCH ====================
  Widget _buildHomeAndSearchTab() {
    final settings = (_config['settings'] as Map<String, dynamic>?) ?? {};
    final locations = (_config['locations'] as List<dynamic>?) ?? [];
    final upazilas = locations.map((l) => l['upazilaNameBn'].toString()).toSet().toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF083A24), Color(0xFF136841)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'প্রাথমিক কার্যক্রম: নোয়াখালী জেলা (পর্যায়ক্রমে সারাদেশে সম্প্রসারণযোগ্য)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'ভূমি সেতু (Bhumi Setu) — ক্রেতা, বিক্রেতা ও মার্কেটিং অফিসারের সমন্বিত ডিজিটাল প্ল্যাটফর্ম',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'শুধু বিজ্ঞাপন প্রকাশ নয় — জমির ক্রেতার চাহিদা সংগ্রহ, বিক্রেতার জমির প্রাথমিক কাগজপত্র যাচাই, মার্কেটিং অফিসারের রেফারেল নেটওয়ার্ক এবং নিরাপদ মধ্যস্থতায় জমি কেনাবেচার বিশ্বস্ত মাধ্যম।',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 22),

                    // Quick Role Action Buttons
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          onPressed: () => setState(() => _selectedIndex = 3),
                          icon: const Icon(Icons.person_search),
                          label: Text('জমি কিনতে চাই (নিবন্ধন ফি: ৳${settings['buyerRegistrationFee'] ?? 500})'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B4F32),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          onPressed: () => setState(() => _selectedIndex = 3),
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: Text('জমি বিক্রি করতে চাই (নিবন্ধন ফি: ৳${settings['sellerRegistrationFee'] ?? 500})'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          onPressed: () => setState(() => _selectedIndex = 3),
                          icon: const Icon(Icons.share),
                          label: Text('মার্কেটিং অফিসার হিসেবে যুক্ত হোন (ফি: ৳${settings['officerRegistrationFee'] ?? 300})'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Search & Filter Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 230,
                            child: DropdownButtonFormField<String>(
                              initialValue: _filterUpazila.isEmpty ? null : _filterUpazila,
                              decoration: const InputDecoration(
                                labelText: 'উপজেলা (নোয়াখালী)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: [
                                const DropdownMenuItem(value: '', child: Text('সকল উপজেলা')),
                                ...upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))),
                              ],
                              onChanged: (v) => setState(() => _filterUpazila = v ?? ''),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: DropdownButtonFormField<String>(
                              initialValue: _filterLandType.isEmpty ? null : _filterLandType,
                              decoration: const InputDecoration(
                                labelText: 'জমির ধরন',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: '', child: Text('সকল ধরন')),
                                DropdownMenuItem(value: 'আবাসিক', child: Text('আবাসিক')),
                                DropdownMenuItem(value: 'বাণিজ্যিক', child: Text('বাণিজ্যিক')),
                                DropdownMenuItem(value: 'কৃষি', child: Text('কৃষি')),
                                DropdownMenuItem(value: 'বাগান/খামার', child: Text('বাগান/খামার')),
                              ],
                              onChanged: (v) => setState(() => _filterLandType = v ?? ''),
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: TextField(
                              controller: _maxBudgetCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'সর্বোচ্চ বাজেট (৳)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            ),
                            onPressed: _loadInitialData,
                            icon: const Icon(Icons.search),
                            label: const Text('জমি খুঁজুন'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _filterUpazila = '';
                                _filterLandType = '';
                                _maxBudgetCtrl.clear();
                              });
                              _loadInitialData();
                            },
                            child: const Text('ফিল্টার রিসেট'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content Container
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4 Live Stat Cards
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _homeStatCard('অনুমোদিত জমির বিজ্ঞাপন', '${_stats['publishedListings'] ?? 0} টি', Icons.verified_outlined),
                        _homeStatCard('সক্রিয় ক্রেতার চাহিদা', '${_stats['activeBuyerRequirements'] ?? 0} টি', Icons.person_pin_circle_outlined),
                        _homeStatCard('নিবন্ধিত মার্কেটিং অফিসার', '${_stats['marketingOfficers'] ?? 0} জন', Icons.badge_outlined),
                        _homeStatCard('নোয়াখালীর কভারকৃত উপজেলা', '${_stats['coveredUpazilas'] ?? 9} টি', Icons.map_outlined),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Verified Land Listings Section
                    const Text(
                      'যাচাইকৃত বিক্রয়যোগ্য জমির বিজ্ঞাপনসমূহ (Verified Properties)',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'প্রতিটি বিজ্ঞাপনে প্রাথমিক যাচাইয়ের অবস্থা স্পষ্টভাবে উল্লেখ করা হয়েছে। নিরাপত্তার স্বার্থে দলিল ও মালিকের নম্বর গোপন রেখে প্ল্যাটফর্মের মাধ্যমে সংযোগ স্থাপন করা হয়।',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    if (_listings.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('এই ফিল্টারে কোনো অনুমোদিত জমির বিজ্ঞাপন পাওয়া যায়নি।')),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: _listings.map((l) => _propertyCard(l as Map<String, dynamic>)).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertyCard(Map<String, dynamic> l) {
    final vStatus = l['verificationStatus'] as String? ?? 'SUBMITTED';
    final (badgeText, badgeColor) = switch (vStatus) {
      'FIELD_VERIFIED' => ('🟢 সরেজমিনে ও নথি যাচাইকৃত', Colors.green.shade800),
      'DOC_CHECKED' => ('🔵 কাগজপত্র প্রাথমিক যাচাইকৃত', Colors.blue.shade800),
      _ => ('⚪ প্রাথমিক তথ্য প্রাপ্ত', Colors.grey.shade700),
    };

    return Container(
      width: 375,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  l['imageUrl'] ?? 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
                  height: 185,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 185,
                    color: const Color(0xFFE8F5E9),
                    child: const Center(child: Icon(Icons.landscape, size: 54, color: Color(0xFF0B4F32))),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4F32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l['landType'] ?? 'আবাসিক',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l['title'] ?? '',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF0B4F32)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${l['areaName']}, ${l['upazila']}, ${l['district']}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F8F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('জমির পরিমাণ', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text('${l['areaDecimal']} শতাংশ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('প্রত্যাশিত মূল্য', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(
                            '৳${l['expectedPriceBdt']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0B4F32)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'রাস্তার সুবিধা: ${l['roadAccessInfo'] ?? 'পাকা রাস্তা সংলগ্ন'}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  l['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B4F32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _handleInquiryClick(l),
                    icon: const Icon(Icons.support_agent, size: 18),
                    label: const Text('পরিদর্শন ও ক্রয়ের জন্য আগ্রহ প্রকাশ করুন'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleInquiryClick(Map<String, dynamic> listing) {
    if (ApiService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('জমির বিস্তারিত জানতে ও যোগাযোগের অনুরোধ পাঠাতে প্রথমে লগইন বা নিবন্ধন করুন।')),
      );
      setState(() => _selectedIndex = 3);
      return;
    }

    final budgetCtrl = TextEditingController(text: '${listing['expectedPriceBdt']}');
    final msgCtrl = TextEditingController(text: 'আমি এই জমিটি সরেজমিনে পরিদর্শন করতে এবং কাগজপত্র যাচাই সাপেক্ষে ক্রয় করতে আগ্রহী।');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('যোগাযোগের অনুরোধ: ${listing['title']}'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'নিরাপত্তা ও স্বচ্ছতার স্বার্থে ভূমি সেতু অ্যাডমিন আপনার অনুরোধটি পর্যালোচনা করে বিক্রেতার সাথে পরিদর্শন ও আলোচনার ব্যবস্থা করবেন।',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'আপনার প্রস্তাবিত বাজেট (৳)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'আপনার বার্তা বা প্রশ্ন'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
            onPressed: () async {
              await ApiService.createInquiry({
                'listingId': listing['id'],
                'offeredBudgetBdt': budgetCtrl.text,
                'message': msgCtrl.text,
              });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('আপনার আগ্রহের অনুরোধটি সফলভাবে জমা হয়েছে! অ্যাডমিন শীঘ্রই যোগাযোগ করবেন।')),
              );
            },
            child: const Text('অনুরোধ পাঠান'),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 1: BUYER DEMANDS ("জমি কিনতে চাই") ====================
  Widget _buildBuyerDemandsPublicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“জমি কিনতে চাই” — নিবন্ধিত ক্রেতাদের বর্তমান চাহিদা',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'আপনার জমি যদি নিচের কোনো ক্রেতার চাহিদার সাথে মিলে যায়, তবে বিক্রেতা হিসেবে নিবন্ধন করে জমির তথ্য জমা দিন।',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                    onPressed: () => setState(() => _selectedIndex = 3),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('আপনার জমির চাহিদা নিবন্ধন করুন'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._requirements.map((r) => Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${r['preferredUpazila']}, ${r['preferredDistrict']} — ${r['landType']} জমি প্রয়োজন',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                              ),
                              Chip(
                                label: Text(r['purchaseTimeline'] ?? 'জরুরি'),
                                backgroundColor: Colors.amber.shade100,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('পছন্দের এলাকা: ${r['preferredArea'] ?? 'উপজেলার যেকোনো ভালো এলাকা'} • ক্রেতা: ${r['buyerName']}'),
                          const SizedBox(height: 4),
                          Text(
                            'চাহিদার পরিমাণ: ${r['minAreaDecimal']} থেকে ${r['maxAreaDecimal']} শতাংশ  •  সম্ভাব্য বাজেট: ৳${r['minBudgetBdt']} – ৳${r['maxBudgetBdt']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('কেনার উদ্দেশ্য: ${r['purpose']} • বিশেষ শর্ত: ${r['specialRequirements'] ?? 'নিষ্কণ্টক কাগজপত্র'}'),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 2: RULES, FEES & CONTACT ====================
  Widget _buildRulesAndFeesTab() {
    final settings = (_config['settings'] as Map<String, dynamic>?) ?? {};
    final paymentMethods = (_config['paymentMethods'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'নিয়মাবলি, নিবন্ধন ফি, সম্মানীর নীতিমালা ও যোগাযোগ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '১. অ্যাডমিন কর্তৃক নির্ধারিত বর্তমান নিবন্ধন ফি ও কমিশন হার',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('• ক্রেতা নিবন্ধন ফি: ৳${settings['buyerRegistrationFee'] ?? 500} (চাহিদা নিবন্ধন, জমি অনুসন্ধান ও সংযোগ সহায়তা)'),
                      Text('• বিক্রেতা নিবন্ধন ফি: ৳${settings['sellerRegistrationFee'] ?? 500} (প্রাথমিক তথ্য যাচাই ও বিজ্ঞাপন প্রকাশ)'),
                      Text('• মার্কেটিং অফিসার নিবন্ধন ফি: ৳${settings['officerRegistrationFee'] ?? 300} (ইউনিক রেফারেল কোড, পোর্টাল ও প্রশিক্ষণ সুবিধা)'),
                      const Divider(height: 24),
                      const Text(
                        '২. পেমেন্ট পাঠানোর অনুমোদিত মাধ্যমসমূহ (অ্যাডমিন নির্ধারিত)',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...paymentMethods.map((pm) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• ${pm['providerName']} (${pm['accountType']}): ${pm['accountNumber']} — ${pm['instructions'] ?? ''}',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0B4F32)),
                            ),
                          )),
                      const Divider(height: 24),
                      const Text(
                        '৩. নিরাপত্তা ও আইনগত শর্তাবলি',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('• অনুমতি ছাড়া কোনো জমির দলিল, খতিয়ান বা গ্রাহকের ব্যক্তিগত ফোন নম্বর প্রকাশ করা হয় না।'),
                      const Text('• নতুন সদস্য সংগ্রহ করে আগের সদস্যদের পারিশ্রমিক দেওয়া হয় না; প্রতিটি সম্মানী বাস্তব ও যাচাইযোগ্য রেফারেল বা লেনদেনের বিপরীতে প্রদান করা হয়।'),
                      const Text('• চূড়ান্ত জমি ক্রয়-বিক্রয়ের পূর্বে স্থানীয় বিজ্ঞ আইনজীবী ও সার্ভেয়ারের মাধ্যমে দলিল ও সরেজমিন সীমানা যাচাই করা আবশ্যক।'),
                      const Divider(height: 24),
                      Text('যোগাযোগ: ${settings['officeAddress'] ?? 'মাইজদী কোর্ট, নোয়াখালী'} | হেল্পলাইন: ${settings['supportPhone'] ?? '01711-889900'} | ইমেইল: ${settings['supportEmail'] ?? 'support@bhumisetu.com.bd'}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 3: LOGIN & 3-ROLE REGISTRATION WITH REFERRAL CODE + MANUAL TRXID ====================
  Widget _buildAuthAndRegistrationTab() {
    return _AuthAndRegisterView(
      config: _config,
      onAuthSuccess: () {
        _loadInitialData();
        setState(() => _selectedIndex = 3);
      },
    );
  }

  Widget _homeStatCard(String label, String value, IconData icon) {
    return Container(
      width: 275,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(icon, color: const Color(0xFF0B4F32)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthAndRegisterView extends StatefulWidget {
  final Map<String, dynamic> config;
  final VoidCallback onAuthSuccess;

  const _AuthAndRegisterView({required this.config, required this.onAuthSuccess});

  @override
  State<_AuthAndRegisterView> createState() => _AuthAndRegisterViewState();
}

class _AuthAndRegisterViewState extends State<_AuthAndRegisterView> {
  bool _isLogin = false;
  bool _submitting = false;

  // Login controllers
  final _loginPhoneCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Registration controllers
  String _selectedRole = 'BUYER';
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _upazila = 'নোয়াখালী সদর';
  final _addressCtrl = TextEditingController();
  final _referralCodeCtrl = TextEditingController(text: 'LT-NOA-1001');
  String _selectedPaymentMethod = 'বিকাশ (bKash)';
  final _senderPhoneCtrl = TextEditingController();
  final _trxIdCtrl = TextEditingController();

  Future<void> _quickDemoLogin(String phone, String pass) async {
    setState(() => _submitting = true);
    try {
      await ApiService.login(phone, pass);
      widget.onAuthSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = (widget.config['settings'] as Map<String, dynamic>?) ?? {};
    final paymentMethods = (widget.config['paymentMethods'] as List<dynamic>?) ?? [];

    final currentRoleFee = switch (_selectedRole) {
      'SELLER' => settings['sellerRegistrationFee'] ?? 500,
      'MARKETING_OFFICER' => settings['officerRegistrationFee'] ?? 300,
      _ => settings['buyerRegistrationFee'] ?? 500,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1-Click Demo Login Bar for Testing All 4 Roles
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚡ দ্রুত পরীক্ষার জন্য ১-ক্লিকে ডেমো লগইন (One-Click Demo Logins):',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A2E1F), foregroundColor: Colors.white),
                          onPressed: _submitting ? null : () => _quickDemoLogin('01700000000', 'admin123'),
                          icon: const Icon(Icons.admin_panel_settings, size: 18),
                          label: const Text('অ্যাডমিন প্যানেল ডেমো'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700, foregroundColor: Colors.white),
                          onPressed: _submitting ? null : () => _quickDemoLogin('01800000001', '123456'),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('মার্কেটিং অফিসার পোর্টাল (কোড: LT-NOA-1001)'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
                          onPressed: _submitting ? null : () => _quickDemoLogin('01900000002', '123456'),
                          icon: const Icon(Icons.landscape, size: 18),
                          label: const Text('বিক্রেতা ড্যাশবোর্ড ডেমো'),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900, foregroundColor: Colors.white),
                          onPressed: _submitting ? null : () => _quickDemoLogin('01600000003', '123456'),
                          icon: const Icon(Icons.person_search, size: 18),
                          label: const Text('ক্রেতা ড্যাশবোর্ড ডেমো'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Toggle between Registration and Login
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isLogin ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                        foregroundColor: !_isLogin ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => setState(() => _isLogin = false),
                      child: const Text('নতুন সদস্য নিবন্ধন (ক্রেতা / বিক্রেতা / মার্কেটিং অফিসার)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLogin ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                        foregroundColor: _isLogin ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => setState(() => _isLogin = true),
                      child: const Text('পুরাতন সদস্য লগইন (মোবাইল ও পাসওয়ার্ড)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_isLogin)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('আপনার অ্যাকাউন্টে লগইন করুন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _loginPhoneCtrl,
                          decoration: const InputDecoration(labelText: 'মোবাইল নম্বর (যেমন: 01800000001)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'পাসওয়ার্ড', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _submitting
                                ? null
                                : () => _quickDemoLogin(_loginPhoneCtrl.text.trim(), _loginPassCtrl.text),
                            child: const Text('লগইন করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'তিন ধরনের সদস্য নিবন্ধন ফর্ম (OTP ছাড়া সরাসরি নিবন্ধন)',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                        ),
                        const SizedBox(height: 14),

                        // Role Selector
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _roleCard('BUYER', '১. জমির ক্রেতা', 'নিবন্ধন ফি: ৳${settings['buyerRegistrationFee'] ?? 500}', Icons.person_search),
                            _roleCard('SELLER', '২. জমির বিক্রেতা', 'নিবন্ধন ফি: ৳${settings['sellerRegistrationFee'] ?? 500}', Icons.landscape),
                            _roleCard('MARKETING_OFFICER', '৩. মার্কেটিং অফিসার', 'নিবন্ধন ফি: ৳${settings['officerRegistrationFee'] ?? 300}', Icons.share),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _fullNameCtrl,
                                decoration: const InputDecoration(labelText: 'পূর্ণ নাম *', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _phoneCtrl,
                                decoration: const InputDecoration(labelText: 'মোবাইল নম্বর (01XXXXXXXXX) *', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passCtrl,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: 'পাসওয়ার্ড দিন *', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _upazila,
                                decoration: const InputDecoration(labelText: 'উপজেলা (নোয়াখালী)', border: OutlineInputBorder()),
                                items: const [
                                  'নোয়াখালী সদর', 'বেগমগঞ্জ', 'চাটখিল', 'কোম্পানীগঞ্জ',
                                  'সেনবাগ', 'সোনাইমুড়ী', 'কবিরহাট', 'সুবর্ণচর', 'হাতিয়া'
                                ].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                onChanged: (v) => setState(() => _upazila = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(labelText: 'বর্তমান ঠিকানা / এলাকা', border: OutlineInputBorder()),
                        ),

                        // Referral Code Input for Buyer & Seller
                        if (_selectedRole != 'MARKETING_OFFICER') ...[
                          const SizedBox(height: 14),
                          TextField(
                            controller: _referralCodeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'মার্কেটিং অফিসারের রেফারেল কোড (থাকলে দিন, যেমন: LT-NOA-1001)',
                              helperText: 'রেফারেল কোড দিলে সংশ্লিষ্ট মার্কেটিং অফিসারের পোর্টালে আপনার নাম ও কমিশন যুক্ত হবে',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.card_giftcard),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                        // Admin-Configured Payment Numbers Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade600),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'নিবন্ধন ফি পরিশোধের নির্দেশনা (আপনার প্রদেয় ফি: ৳$currentRoleFee)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 6),
                              const Text('অ্যাডমিন নির্ধারিত নিচের যেকোনো নম্বরে নিবন্ধন ফি পাঠিয়ে প্রেরক নম্বর ও TrxID নিচে লিখুন:'),
                              const SizedBox(height: 8),
                              ...paymentMethods.map((pm) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '👉 ${pm['providerName']} (${pm['accountType']}): ${pm['accountNumber']} — ${pm['instructions'] ?? ''}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedPaymentMethod,
                                decoration: const InputDecoration(labelText: 'পেমেন্টের মাধ্যম', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'বিকাশ (bKash)', child: Text('বিকাশ (bKash)')),
                                  DropdownMenuItem(value: 'নগদ (Nagad)', child: Text('নগদ (Nagad)')),
                                  DropdownMenuItem(value: 'ইসলামী ব্যাংক পিএলসি', child: Text('ব্যাংক ট্রান্সফার')),
                                ],
                                onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _senderPhoneCtrl,
                                decoration: const InputDecoration(labelText: 'যে নম্বর থেকে টাকা পাঠিয়েছেন *', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _trxIdCtrl,
                                decoration: const InputDecoration(labelText: 'ট্রানজ্যাকশন আইডি (TrxID) *', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _submitting ? null : _submitRegistration,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              'নিবন্ধন সম্পন্ন করুন (ফি: ৳$currentRoleFee)',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String roleValue, String title, String subtitle, IconData icon) {
    final selected = _selectedRole == roleValue;
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: Container(
        width: 265,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0B4F32) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B4F32), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF0B4F32), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRegistration() async {
    setState(() => _submitting = true);
    try {
      await ApiService.register({
        'fullName': _fullNameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'password': _passCtrl.text,
        'role': _selectedRole,
        'district': 'নোয়াখালী',
        'upazila': _upazila,
        'address': _addressCtrl.text.trim(),
        'referralCode': _selectedRole == 'MARKETING_OFFICER' ? '' : _referralCodeCtrl.text.trim(),
        'paymentMethod': _selectedPaymentMethod,
        'senderPhone': _senderPhoneCtrl.text.trim().isEmpty ? _phoneCtrl.text.trim() : _senderPhoneCtrl.text.trim(),
        'transactionId': _trxIdCtrl.text.trim().isEmpty ? 'TRX-${DateTime.now().millisecondsSinceEpoch % 100000}' : _trxIdCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('নিবন্ধন সফল হয়েছে! স্বাগতম ভূমি সেতুতে।')),
        );
      }
      widget.onAuthSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
