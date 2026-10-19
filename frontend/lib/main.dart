import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';
import 'screens/member_dashboard_screen.dart';
import 'screens/admin_panel_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
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

  // Advanced Search Filters
  bool _filtersExpanded = false;
  String _filterDistrict = '';
  String _filterUpazila = '';
  String _filterLandType = '';
  String _filterVerification = '';
  final TextEditingController _maxBudgetCtrl = TextEditingController();
  final TextEditingController _minAreaCtrl = TextEditingController();
  final TextEditingController _maxAreaCtrl = TextEditingController();
  final TextEditingController _keywordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    setState(() => _loading = true);
    await ApiService.restoreSession();
    final refParam = Uri.base.queryParameters['ref'];
    if (refParam != null && refParam.trim().isNotEmpty && ApiService.currentUser == null) {
      _selectedIndex = 3;
    }
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final res = await Future.wait([
        ApiService.getPublicConfig(),
        ApiService.getPublicStats(),
        ApiService.getPublicListings(
          district: _filterDistrict.isEmpty ? null : _filterDistrict,
          upazila: _filterUpazila.isEmpty ? null : _filterUpazila,
          landType: _filterLandType.isEmpty ? null : _filterLandType,
          maxBudget: _maxBudgetCtrl.text.trim().isEmpty ? null : _maxBudgetCtrl.text.trim(),
          verificationStatus: _filterVerification.isEmpty ? null : _filterVerification,
          minArea: _minAreaCtrl.text.trim().isEmpty ? null : _minAreaCtrl.text.trim(),
          maxArea: _maxAreaCtrl.text.trim().isEmpty ? null : _maxAreaCtrl.text.trim(),
          keyword: _keywordCtrl.text.trim().isEmpty ? null : _keywordCtrl.text.trim(),
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
          SnackBar(content: Text('সার্ভার সংযোগ বার্তা: $e')),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 64 : 72),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B4F32),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Logo & Slogan
                Flexible(
                  child: InkWell(
                    onTap: () => setState(() => _selectedIndex = 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(isMobile ? 6 : 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.landscape, color: const Color(0xFF0B4F32), size: isMobile ? 20 : 24),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ভূমি সেতু (LandTrust)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 15 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isMobile ? 'ক্রেতা-বিক্রেতার সংযোগ • নোয়াখালী' : 'ক্রেতা-বিক্রেতার বিশ্বস্ত সংযোগ • নোয়াখালী ও সারাদেশ',
                                style: TextStyle(color: Colors.white70, fontSize: isMobile ? 10 : 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigation Buttons (Desktop/Tablet) or Quick Action/Logout (Mobile)
                if (!isMobile)
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
                            isAdmin ? 'অ্যাডমিন প্যানেল' : 'আমার পোর্টাল (${user['fullName']})',
                          ),
                          const SizedBox(width: 6),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.amberAccent),
                            onPressed: () async {
                              await ApiService.logout();
                              setState(() => _selectedIndex = 0);
                            },
                            icon: const Icon(Icons.logout, size: 17),
                            label: const Text('লগআউট'),
                          ),
                        ],
                      ],
                    ),
                  )
                else if (user != null)
                  Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ActionChip(
                        backgroundColor: Colors.white24,
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                        label: Text(isAdmin ? 'অ্যাডমিন' : (user['fullName']?.toString() ?? 'ইউজার')),
                        onPressed: () => setState(() => _selectedIndex = 3),
                      ),
                      IconButton(
                        tooltip: 'লগআউট',
                        icon: const Icon(Icons.logout, color: Colors.amberAccent, size: 20),
                        onPressed: () async {
                          await ApiService.logout();
                          setState(() => _selectedIndex = 0);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFD8F3DC),
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: Color(0xFF0B4F32)),
                  label: 'জমি খুঁজুন',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.assignment_outlined),
                  selectedIcon: const Icon(Icons.assignment, color: Color(0xFF0B4F32)),
                  label: 'কিনতে চাই (${_requirements.length})',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.policy_outlined),
                  selectedIcon: Icon(Icons.policy, color: Color(0xFF0B4F32)),
                  label: 'নিয়ম ও ফি',
                ),
                NavigationDestination(
                  icon: Icon(user == null ? Icons.person_add_alt_1_outlined : (isAdmin ? Icons.admin_panel_settings_outlined : Icons.dashboard_outlined)),
                  selectedIcon: Icon(
                    user == null ? Icons.person_add_alt_1 : (isAdmin ? Icons.admin_panel_settings : Icons.dashboard_customize),
                    color: const Color(0xFF0B4F32),
                  ),
                  label: user == null ? 'নিবন্ধন/লগইন' : (isAdmin ? 'অ্যাডমিন' : 'পোর্টাল'),
                ),
              ],
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeAndSearchTab(isMobile),
                  _buildBuyerDemandsPublicTab(isMobile),
                  _buildRulesAndFeesTab(isMobile),
                  user == null
                      ? _AuthAndRegisterView(
                          config: _config,
                          isMobile: isMobile,
                          onAuthSuccess: () {
                            _loadInitialData();
                            setState(() => _selectedIndex = 3);
                          },
                        )
                      : (isAdmin
                          ? AdminPanelScreen(onConfigChanged: _loadInitialData)
                          : MemberDashboardScreen(onRefreshParent: _loadInitialData)),
                ],
              ),
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

  // ==================== TAB 0: HOME & ADVANCED LAND SEARCH ====================
  Widget _buildHomeAndSearchTab(bool isMobile) {
    final settings = (_config['settings'] as Map<String, dynamic>?) ?? {};
    final locations = (_config['locations'] as List<dynamic>?) ?? [];
    final districts = locations.map((l) => l['districtNameBn'].toString()).toSet().toList();
    final upazilas = locations
        .where((l) => _filterDistrict.isEmpty || l['districtNameBn'] == _filterDistrict)
        .map((l) => l['upazilaNameBn'].toString())
        .toSet()
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Hero Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 20 : 32,
            ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'নোয়াখালী থেকে শুরু • সারাদেশে বিশ্বস্ত নেটওয়ার্ক',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 11 : 12, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ভূমি সেতু (Bhumi Setu)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'নিরাপদ জমি কেনাবেচা, সরাসরি চাহিদা সংগ্রহ ও মার্কেটিং অফিসার রেফারেল নেটওয়ার্ক।',
                      style: TextStyle(color: Colors.white70, fontSize: isMobile ? 13 : 15),
                    ),
                    const SizedBox(height: 16),

                    // Quick Role Action Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
                          ),
                          onPressed: () => setState(() => _selectedIndex = 3),
                          icon: const Icon(Icons.person_search, size: 16),
                          label: Text('জমি কিনব (ফি ৳${settings['buyerRegistrationFee'] ?? 500})', style: const TextStyle(fontSize: 12)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B4F32),
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
                          ),
                          onPressed: () => setState(() => _selectedIndex = 3),
                          icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                          label: Text('জমি বিক্রি (ফি ৳${settings['sellerRegistrationFee'] ?? 500})', style: const TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
                          ),
                          onPressed: () => setState(() => _selectedIndex = 3),
                          icon: const Icon(Icons.share, size: 16),
                          label: Text('মার্কেটিং অফিসার (ফি ৳${settings['officerRegistrationFee'] ?? 300})', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Smart Search & Filter Box
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Search Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _keywordCtrl,
                                    decoration: InputDecoration(
                                      hintText: 'মৌজা / এলাকা / দাগ নং / বিবরণ...',
                                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0B4F32)),
                                      isDense: true,
                                      suffixIcon: _keywordCtrl.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear, size: 18),
                                              onPressed: () {
                                                _keywordCtrl.clear();
                                                _loadInitialData();
                                              },
                                            )
                                          : null,
                                    ),
                                    onSubmitted: (_) => _loadInitialData(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0B4F32),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 14 : 20,
                                      vertical: isMobile ? 12 : 14,
                                    ),
                                  ),
                                  onPressed: _loadInitialData,
                                  child: const Text('খুঁজুন'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Quick Category Filter Chips Row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _filterChip(
                                    label: 'সকল জমি',
                                    selected: _filterLandType.isEmpty && _filterVerification.isEmpty,
                                    onTap: () {
                                      setState(() {
                                        _filterLandType = '';
                                        _filterVerification = '';
                                      });
                                      _loadInitialData();
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _filterChip(
                                    label: '🟢 সরেজমিনে যাচাইকৃত',
                                    selected: _filterVerification == 'FIELD_VERIFIED',
                                    onTap: () {
                                      setState(() {
                                        _filterVerification = _filterVerification == 'FIELD_VERIFIED' ? '' : 'FIELD_VERIFIED';
                                      });
                                      _loadInitialData();
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _filterChip(
                                    label: 'আবাসিক',
                                    selected: _filterLandType == 'আবাসিক',
                                    onTap: () {
                                      setState(() {
                                        _filterLandType = _filterLandType == 'আবাসিক' ? '' : 'আবাসিক';
                                      });
                                      _loadInitialData();
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _filterChip(
                                    label: 'বাণিজ্যিক',
                                    selected: _filterLandType == 'বাণিজ্যিক',
                                    onTap: () {
                                      setState(() {
                                        _filterLandType = _filterLandType == 'বাণিজ্যিক' ? '' : 'বাণিজ্যিক';
                                      });
                                      _loadInitialData();
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _filterChip(
                                    label: 'কৃষি',
                                    selected: _filterLandType == 'কৃষি',
                                    onTap: () {
                                      setState(() {
                                        _filterLandType = _filterLandType == 'কৃষি' ? '' : 'কৃষি';
                                      });
                                      _loadInitialData();
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF0B4F32),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                    onPressed: () => setState(() => _filtersExpanded = !_filtersExpanded),
                                    icon: Icon(_filtersExpanded ? Icons.tune : Icons.filter_alt_outlined, size: 16),
                                    label: Text(
                                      _filtersExpanded ? 'ফিল্টার লুকান' : 'আরও ফিল্টার (জেলা/বাজেট)',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Expandable Filter Panel
                            if (_filtersExpanded) ...[
                              const Divider(height: 18),
                              LayoutBuilder(
                                builder: (ctx, constraints) {
                                  final colWidth = isMobile
                                      ? (constraints.maxWidth - 10) / 2
                                      : (constraints.maxWidth - 36) / 4;

                                  return Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      SizedBox(
                                        width: colWidth,
                                        child: DropdownButtonFormField<String>(
                                          value: _filterDistrict.isEmpty ? null : _filterDistrict,
                                          decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
                                          items: [
                                            const DropdownMenuItem(value: '', child: Text('সকল জেলা')),
                                            ...districts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                                          ],
                                          onChanged: (v) => setState(() {
                                            _filterDistrict = v ?? '';
                                            _filterUpazila = '';
                                          }),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colWidth,
                                        child: DropdownButtonFormField<String>(
                                          value: upazilas.contains(_filterUpazila) && _filterUpazila.isNotEmpty ? _filterUpazila : null,
                                          decoration: const InputDecoration(labelText: 'উপজেলা', isDense: true),
                                          items: [
                                            const DropdownMenuItem(value: '', child: Text('সকল উপজেলা')),
                                            ...upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))),
                                          ],
                                          onChanged: (v) => setState(() => _filterUpazila = v ?? ''),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colWidth,
                                        child: TextField(
                                          controller: _maxBudgetCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(labelText: 'সর্বোচ্চ বাজেট (৳)', isDense: true),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colWidth,
                                        child: TextField(
                                          controller: _minAreaCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(labelText: 'ন্যূনতম শতাংশ', isDense: true),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colWidth,
                                        child: TextField(
                                          controller: _maxAreaCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(labelText: 'সর্বোচ্চ শতাংশ', isDense: true),
                                        ),
                                      ),
                                      SizedBox(
                                        width: colWidth,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF0B4F32),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                                ),
                                                onPressed: _loadInitialData,
                                                child: const Text('প্রয়োগ করুন'),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              tooltip: 'রিসেট',
                                              icon: const Icon(Icons.refresh, color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  _filterDistrict = '';
                                                  _filterUpazila = '';
                                                  _filterLandType = '';
                                                  _filterVerification = '';
                                                  _maxBudgetCtrl.clear();
                                                  _minAreaCtrl.clear();
                                                  _maxAreaCtrl.clear();
                                                  _keywordCtrl.clear();
                                                });
                                                _loadInitialData();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content Container
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 4 Responsive Live Stat Cards
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final cardWidth = isMobile
                            ? (constraints.maxWidth - 10) / 2
                            : (constraints.maxWidth - 36) / 4;
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _homeStatCard('অনুমোদিত বিজ্ঞাপন', '${_stats['publishedListings'] ?? 0} টি', Icons.verified_outlined, cardWidth),
                            _homeStatCard('ক্রেতার চাহিদা', '${_stats['activeBuyerRequirements'] ?? 0} টি', Icons.person_pin_circle_outlined, cardWidth),
                            _homeStatCard('মার্কেটিং অফিসার', '${_stats['marketingOfficers'] ?? 0} জন', Icons.badge_outlined, cardWidth),
                            _homeStatCard('কভারকৃত উপজেলা', '${_stats['coveredUpazilas'] ?? 9} টি', Icons.map_outlined, cardWidth),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'বিক্রয়যোগ্য জমির তালিকা (${_listings.length})',
                          style: TextStyle(
                            fontSize: isMobile ? 17 : 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0B4F32),
                          ),
                        ),
                        if (_listings.isNotEmpty)
                          Text(
                            'সর্বশেষ আপডেট',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'স্বচ্ছতা ও সুরক্ষার জন্য প্রাথমিক নথি যাচাইকৃত বিজ্ঞাপনসমূহ প্রদর্শিত হচ্ছে।',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Listings Grid
                    if (_listings.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 10),
                                const Text('এই ফিল্টারে কোনো অনুমোদিত জমির বিজ্ঞাপন পাওয়া যায়নি।'),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _filterDistrict = '';
                                      _filterUpazila = '';
                                      _filterLandType = '';
                                      _filterVerification = '';
                                      _maxBudgetCtrl.clear();
                                      _keywordCtrl.clear();
                                    });
                                    _loadInitialData();
                                  },
                                  child: const Text('সব ফিল্টার রিসেট করুন'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          double cardWidth;
                          if (constraints.maxWidth < 620) {
                            cardWidth = constraints.maxWidth; // 1 column on mobile
                          } else if (constraints.maxWidth < 980) {
                            cardWidth = (constraints.maxWidth - 14) / 2; // 2 columns
                          } else {
                            cardWidth = (constraints.maxWidth - 32) / 3; // 3 columns
                          }

                          return Wrap(
                            spacing: 14,
                            runSpacing: 14,
                            children: _listings.map((l) {
                              return SizedBox(
                                width: cardWidth,
                                child: _propertyCard(l as Map<String, dynamic>, isMobile),
                              );
                            }).toList(),
                          );
                        },
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

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFF0B4F32),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontSize: 12,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }

  Widget _propertyCard(Map<String, dynamic> l, bool isMobile) {
    final vStatus = l['verificationStatus'] as String? ?? 'SUBMITTED';
    final (badgeText, badgeColor) = switch (vStatus) {
      'FIELD_VERIFIED' => ('🟢 সরেজমিন যাচাইকৃত', Colors.green.shade800),
      'DOC_CHECKED' => ('🔵 কাগজপত্র যাচাইকৃত', Colors.blue.shade800),
      _ => ('⚪ প্রাথমিক তথ্য', Colors.grey.shade700),
    };
    final hasVideo = (l['videoUrl'] ?? '').toString().trim().isNotEmpty;
    final hasMap = (l['mapLink'] ?? '').toString().trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Badges
          InkWell(
            onTap: () => _showPropertyDetailsDialog(l, isMobile),
            child: Stack(
              children: [
                ApiService.buildSmartImage(
                  l['imageUrl'] as String?,
                  height: isMobile ? 180 : 200,
                  width: double.infinity,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: badgeColor),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B4F32),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l['landType'] ?? 'আবাসিক',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                if (hasVideo || hasMap)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Wrap(
                      spacing: 4,
                      children: [
                        if (hasVideo)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_circle_fill, size: 12, color: Colors.white),
                                SizedBox(width: 3),
                                Text('ভিডিও', style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        if (hasMap)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map, size: 12, color: Colors.white),
                                SizedBox(width: 3),
                                Text('ম্যাপ', style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l['title'] ?? '',
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 15, color: Color(0xFF0B4F32)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${l['areaName']}, ${l['upazila']}, ${l['district']}',
                        style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F8F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('পরিমাণ', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                          Text('${l['areaDecimal']} শতাংশ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('মূল্য', style: TextStyle(fontSize: 10.5, color: Colors.black54)),
                          Text(
                            '৳${l['expectedPriceBdt']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0B4F32)),
                          ),
                          if (l['pricePerDecimalBdt'] != null)
                            Text(
                              '(৳${l['pricePerDecimalBdt']}/শতাংশ)',
                              style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showPropertyDetailsDialog(l, isMobile),
                        child: const Text('বিস্তারিত', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B4F32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _handleInquiryClick(l),
                        child: const Text('আগ্রহ প্রকাশ', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPropertyDetailsDialog(Map<String, dynamic> l, bool isMobile) {
    final mainImg = (l['imageUrl'] ?? '').toString().trim();
    final extraRaw = (l['additionalImageUrls'] ?? '').toString().trim();
    final extraImages = extraRaw.isEmpty
        ? <String>[]
        : extraRaw.split('|||').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    final allImages = <String>[
      if (mainImg.isNotEmpty) mainImg,
      ...extraImages,
    ];
    int activeImgIndex = 0;

    final videoUrl = (l['videoUrl'] ?? '').toString().trim();
    final mapLink = (l['mapLink'] ?? '').toString().trim();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 16 : 24,
          ),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          actionsPadding: const EdgeInsets.all(12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l['title'] ?? 'জমির বিস্তারিত তথ্য',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B4F32),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SizedBox(
            width: isMobile ? double.infinity : 680,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (allImages.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ApiService.buildSmartImage(
                        allImages[activeImgIndex],
                        height: isMobile ? 210 : 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        enableZoom: true,
                      ),
                    ),
                    if (allImages.length > 1) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 58,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: allImages.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (_, idx) {
                            final selected = idx == activeImgIndex;
                            return InkWell(
                              onTap: () => setDialogState(() => activeImgIndex = idx),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: selected ? const Color(0xFF0B4F32) : Colors.grey.shade300,
                                    width: selected ? 2.5 : 1,
                                  ),
                                ),
                                child: ApiService.buildSmartImage(
                                  allImages[idx],
                                  width: 72,
                                  height: 54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F8F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Text(
                              'মোট মূল্য: ৳${l['expectedPriceBdt']}',
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
                            ),
                            Text(
                              'প্রতি শতাংশ: ৳${l['pricePerDecimalBdt'] ?? '-'} (${l['areaDecimal']} শতাংশ)',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text('📍 অবস্থান: ${l['areaName']}, ${l['upazila']}, ${l['district']}'),
                        const SizedBox(height: 3),
                        Text('🗺️ মৌজা: ${l['mouzaName'] ?? 'উল্লেখ নেই'}  •  ধরন: ${l['landType']}'),
                        const SizedBox(height: 3),
                        Text('🛣️ রাস্তার তথ্য: ${l['roadAccessInfo'] ?? 'পাকা রাস্তা সংলগ্ন'}'),
                        const SizedBox(height: 3),
                        const Text('🔒 গোপনীয়তা: খতিয়ান/দাগ ও মালিকের নম্বর প্ল্যাটফর্ম মধ্যস্থতায় সংরক্ষিত।', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('বিস্তারিত বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(l['description'] ?? 'কোনো অতিরিক্ত বিবরণ দেওয়া হয়নি।', style: const TextStyle(fontSize: 13, height: 1.4)),
                  if (videoUrl.isNotEmpty || mapLink.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (videoUrl.isNotEmpty)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.play_circle_outline, color: Colors.red, size: 16),
                            label: const Text('ভিডিও লিংক কপি'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: videoUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ভিডিও লিংক কপি হয়েছে: $videoUrl')),
                              );
                            },
                          ),
                        if (mapLink.isNotEmpty)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.pin_drop_outlined, color: Colors.blue, size: 16),
                            label: const Text('Google Maps লিংক কপি'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: mapLink));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Google Maps লিংক কপি হয়েছে: $mapLink')),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4F32),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _handleInquiryClick(l);
              },
              icon: const Icon(Icons.support_agent, size: 17),
              label: const Text('আগ্রহ প্রকাশ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleInquiryClick(Map<String, dynamic> listing) {
    if (ApiService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('যোগাযোগের অনুরোধ পাঠাতে প্রথমে লগইন বা নিবন্ধন করুন।')),
      );
      setState(() => _selectedIndex = 3);
      return;
    }

    final budgetCtrl = TextEditingController(text: '${listing['expectedPriceBdt']}');
    final msgCtrl = TextEditingController(text: 'আমি এই জমিটি সরেজমিনে পরিদর্শন করতে এবং কাগজপত্র যাচাই সাপেক্ষে ক্রয় করতে আগ্রহী।');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('আগ্রহ প্রকাশ: ${listing['title']}', style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ভূমি সেতু অ্যাডমিন আপনার অনুরোধটি যাচাই করে বিক্রেতার সাথে যোগাযোগ ও পরিদর্শনের ব্যবস্থা করবেন।',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'আপনার প্রস্তাবিত বাজেট (৳)', isDense: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'আপনার বার্তা বা প্রশ্ন', isDense: true),
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
    );
  }

  // ==================== TAB 1: BUYER DEMANDS ("জমি কিনতে চাই") ====================
  Widget _buildBuyerDemandsPublicTab(bool isMobile) {
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
                    onPressed: () => setState(() => _selectedIndex = 3),
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('চাহিদা নিবন্ধন করুন', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_requirements.isEmpty)
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
                            onPressed: () => setState(() => _selectedIndex = 3),
                            child: const Text('প্রথম চাহিদাটি নিবন্ধন করুন'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ..._requirements.map((r) => Card(
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
                                    '${r['preferredUpazila']}, ${r['preferredDistrict']} — ${r['landType']} জমি',
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
                                    r['purchaseTimeline'] ?? 'জরুরি',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('এলাকা: ${r['preferredArea'] ?? 'উপজেলার যেকোনো এলাকা'} • ক্রেতা: ${r['buyerName']}'),
                            const SizedBox(height: 4),
                            Text(
                              'পরিমাণ: ${r['minAreaDecimal']}–${r['maxAreaDecimal']} শতাংশ • বাজেট: ৳${r['minBudgetBdt']}–৳${r['maxBudgetBdt']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('উদ্দেশ্য: ${r['purpose']} • শর্ত: ${r['specialRequirements'] ?? 'নিষ্কণ্টক কাগজপত্র'}'),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: isMobile ? double.infinity : null,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B4F32),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                ),
                                onPressed: () => _handleSellerOfferOnRequirement(r as Map<String, dynamic>),
                                icon: const Icon(Icons.real_estate_agent_outlined, size: 16),
                                label: const Text('উপযুক্ত জমি আছে — প্রস্তাব পাঠান', style: TextStyle(fontSize: 12.5)),
                              ),
                            ),
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

  void _handleSellerOfferOnRequirement(Map<String, dynamic> req) {
    if (ApiService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('জমির প্রস্তাব পাঠাতে প্রথমে লগইন বা নিবন্ধন করুন।')),
      );
      setState(() => _selectedIndex = 3);
      return;
    }

    final detailsCtrl = TextEditingController(
      text: '${req['preferredUpazila']} এলাকায় আমার নিষ্কণ্টক ${req['landType']} জমি রয়েছে, যা আপনার চাহিদার সাথে সামঞ্জস্যপূর্ণ।',
    );
    final priceCtrl = TextEditingController(text: '${req['maxBudgetBdt']}');
    final feeCtrl = TextEditingController(text: '50000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('জমির প্রস্তাব (${req['preferredUpazila']})', style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ক্রেতা: ${req['buyerName']} • বাজেট: ৳${req['minBudgetBdt']}–৳${req['maxBudgetBdt']}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0B4F32), fontSize: 13),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailsCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'আপনার জমির সংক্ষিপ্ত বিবরণ *', isDense: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'প্রত্যাশিত মোট মূল্য (৳) *', isDense: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: feeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'প্ল্যাটফর্মের জন্য প্রস্তাবিত পারিশ্রমিক (৳)', isDense: true),
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
                final res = await ApiService.submitSellerOfferForRequirement(req['id'] as int, {
                  'landDetails': detailsCtrl.text.trim(),
                  'askingPriceBdt': priceCtrl.text.trim(),
                  'proposedServiceFeeBdt': feeCtrl.text.trim(),
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'প্রস্তাব সফলভাবে পাঠানো হয়েছে!')),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            child: const Text('প্রস্তাব পাঠান'),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: RULES, FEES & CONTACT ====================
  Widget _buildRulesAndFeesTab(bool isMobile) {
    final settings = (_config['settings'] as Map<String, dynamic>?) ?? {};
    final paymentMethods = (_config['paymentMethods'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'নিয়মাবলি, নিবন্ধন ফি ও যোগাযোগ',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B4F32),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 14 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '১. নিবন্ধন ফি ও কমিশন হার',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('• ক্রেতা নিবন্ধন ফি: ৳${settings['buyerRegistrationFee'] ?? 500} (চাহিদা নিবন্ধন ও সংযোগ সহায়তা)'),
                      Text('• বিক্রেতা নিবন্ধন ফি: ৳${settings['sellerRegistrationFee'] ?? 500} (বিজ্ঞাপন প্রকাশ ও নথি যাচাই)'),
                      Text('• মার্কেটিং অফিসার নিবন্ধন ফি: ৳${settings['officerRegistrationFee'] ?? 300} (ইউনিক কোড ও প্রশিক্ষণ)'),
                      const Divider(height: 20),
                      const Text(
                        '২. পেমেন্ট পাঠানোর মাধ্যমসমূহ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...paymentMethods.map((pm) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4FBF7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_wallet, size: 18, color: Color(0xFF0B4F32)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${pm['providerName']} (${pm['accountType']}): ${pm['accountNumber']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16, color: Color(0xFF0B4F32)),
                                  tooltip: 'নম্বর কপি করুন',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: pm['accountNumber'].toString()));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${pm['accountNumber']} কপি হয়েছে!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 20),
                      const Text(
                        '৩. নিরাপত্তা ও নীতিমালা',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text('• অনুমতি ছাড়া কোনো দলিল বা ব্যক্তিগত মোবাইল নম্বর উন্মুক্ত করা হয় না।'),
                      const Text('• প্রতিটি সম্মানী ও কমিশন বাস্তব যাচাইযোগ্য লেনদেনের বিপরীতে প্রদান করা হয়।'),
                      const Text('• চূড়ান্ত বায়না বা দলিলের পূর্বে বিজ্ঞ আইনজীবী ও সার্ভেয়ার দ্বারা কাগজপত্র যাচাই করা আবশ্যক।'),
                      const Divider(height: 20),
                      Text(
                        'অফিস: ${settings['officeAddress'] ?? 'মাইজদী কোর্ট, নোয়াখালী'} | হেল্পলাইন: ${settings['supportPhone'] ?? '01800-000000'} | ইমেইল: ${settings['supportEmail'] ?? 'support@landtrust.com.bd'}',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
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

  Widget _homeStatCard(String label, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(icon, color: const Color(0xFF0B4F32), size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54), overflow: TextOverflow.ellipsis),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
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
  final bool isMobile;
  final VoidCallback onAuthSuccess;

  const _AuthAndRegisterView({
    required this.config,
    required this.isMobile,
    required this.onAuthSuccess,
  });

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
  String _district = 'নোয়াখালী';
  String _upazila = 'নোয়াখালী সদর';
  final _addressCtrl = TextEditingController();
  late final TextEditingController _referralCodeCtrl;
  String _selectedPaymentMethod = 'বিকাশ (bKash)';
  final _senderPhoneCtrl = TextEditingController();
  final _trxIdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final refFromUrl = Uri.base.queryParameters['ref'] ?? '';
    _referralCodeCtrl = TextEditingController(text: refFromUrl.trim());
  }

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
    final locations = (widget.config['locations'] as List<dynamic>?) ?? [];

    final districts = locations.isNotEmpty
        ? locations.map((l) => l['districtNameBn'].toString()).toSet().toList()
        : ['নোয়াখালী'];
    if (!districts.contains(_district)) {
      _district = districts.first;
    }

    final upazilasForDistrict = locations
        .where((l) => l['districtNameBn'] == _district)
        .map((l) => l['upazilaNameBn'].toString())
        .toSet()
        .toList();
    final upazilas = upazilasForDistrict.isNotEmpty
        ? upazilasForDistrict
        : [
            'নোয়াখালী সদর', 'বেগমগঞ্জ', 'চাটখিল', 'কোম্পানীগঞ্জ',
            'সেনবাগ', 'সোনাইমুড়ী', 'কবিরহাট', 'সুবর্ণচর', 'হাতিয়া'
          ];
    if (!upazilas.contains(_upazila)) {
      _upazila = upazilas.first;
    }

    final paymentOptions = paymentMethods.isNotEmpty
        ? paymentMethods.map((pm) => pm['providerName'].toString()).toSet().toList()
        : ['বিকাশ (bKash)', 'নগদ (Nagad)', 'ইসলামী ব্যাংক পিএলসি'];
    if (!paymentOptions.contains(_selectedPaymentMethod)) {
      _selectedPaymentMethod = paymentOptions.first;
    }

    final currentRoleFee = switch (_selectedRole) {
      'SELLER' => settings['sellerRegistrationFee'] ?? 500,
      'MARKETING_OFFICER' => settings['officerRegistrationFee'] ?? 300,
      _ => settings['buyerRegistrationFee'] ?? 500,
    };

    final refFromUrl = Uri.base.queryParameters['ref'] ?? '';
    final isMobile = widget.isMobile;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (refFromUrl.trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, color: Color(0xFF0B4F32), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'রেফারেল কোড (${refFromUrl.trim()}) স্বয়ংক্রিয়ভাবে যুক্ত হয়েছে।',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0B4F32)),
                        ),
                      ),
                    ],
                  ),
                ),

              // 1-Click Demo Login Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0B4F32).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚡ ডেমো অ্যাকাউন্ট পরীক্ষা (১-ক্লিক লগইন):',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF0B4F32)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _demoButton('অ্যাডমিন ডেমো', '01700000000', 'admin123', const Color(0xFF0A2E1F), Icons.admin_panel_settings),
                        _demoButton('অফিসার ডেমো', '01800000001', '123456', Colors.indigo.shade700, Icons.share),
                        _demoButton('বিক্রেতা ডেমো', '01900000002', '123456', Colors.teal.shade800, Icons.landscape),
                        _demoButton('ক্রেতা ডেমো', '01600000003', '123456', Colors.orange.shade900, Icons.person_search),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Toggle between Registration and Login
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isLogin ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                        foregroundColor: !_isLogin ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => setState(() => _isLogin = false),
                      child: const Text('নতুন সদস্য নিবন্ধন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLogin ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                        foregroundColor: _isLogin ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => setState(() => _isLogin = true),
                      child: const Text('পুরাতন সদস্য লগইন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLogin)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('লগইন করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _loginPhoneCtrl,
                          decoration: const InputDecoration(labelText: 'মোবাইল নম্বর', isDense: true),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _loginPassCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: 'পাসওয়ার্ড', isDense: true),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _submitting
                                ? null
                                : () => _quickDemoLogin(_loginPhoneCtrl.text.trim(), _loginPassCtrl.text),
                            child: const Text('লগইন করুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 14 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'সদস্য নিবন্ধন ফর্ম',
                          style: TextStyle(fontSize: isMobile ? 17 : 20, fontWeight: FontWeight.bold, color: const Color(0xFF0B4F32)),
                        ),
                        const SizedBox(height: 12),

                        // Role Selector
                        LayoutBuilder(
                          builder: (ctx, constraints) {
                            final cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 16) / 3;
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: _roleCard('BUYER', '১. জমির ক্রেতা', 'ফি: ৳${settings['buyerRegistrationFee'] ?? 500}', Icons.person_search),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _roleCard('SELLER', '২. জমির বিক্রেতা', 'ফি: ৳${settings['sellerRegistrationFee'] ?? 500}', Icons.landscape),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: _roleCard('MARKETING_OFFICER', '৩. মার্কেটিং অফিসার', 'ফি: ৳${settings['officerRegistrationFee'] ?? 300}', Icons.share),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        // Responsive Form Fields
                        LayoutBuilder(
                          builder: (ctx, constraints) {
                            final halfWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: halfWidth,
                                  child: TextField(
                                    controller: _fullNameCtrl,
                                    decoration: const InputDecoration(labelText: 'পূর্ণ নাম *', isDense: true),
                                  ),
                                ),
                                SizedBox(
                                  width: halfWidth,
                                  child: TextField(
                                    controller: _phoneCtrl,
                                    decoration: const InputDecoration(labelText: 'মোবাইল নম্বর (01XXXXXXXXX) *', isDense: true),
                                  ),
                                ),
                                SizedBox(
                                  width: halfWidth,
                                  child: TextField(
                                    controller: _passCtrl,
                                    obscureText: true,
                                    decoration: const InputDecoration(labelText: 'পাসওয়ার্ড দিন *', isDense: true),
                                  ),
                                ),
                                SizedBox(
                                  width: halfWidth,
                                  child: DropdownButtonFormField<String>(
                                    value: _district,
                                    decoration: const InputDecoration(labelText: 'জেলা', isDense: true),
                                    items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                    onChanged: (v) => setState(() => _district = v!),
                                  ),
                                ),
                                SizedBox(
                                  width: halfWidth,
                                  child: DropdownButtonFormField<String>(
                                    value: _upazila,
                                    decoration: const InputDecoration(labelText: 'উপজেলা', isDense: true),
                                    items: upazilas.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                                    onChanged: (v) => setState(() => _upazila = v!),
                                  ),
                                ),
                                SizedBox(
                                  width: halfWidth,
                                  child: TextField(
                                    controller: _addressCtrl,
                                    decoration: const InputDecoration(labelText: 'বর্তমান ঠিকানা / এলাকা', isDense: true),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Referral Code Input
                        if (_selectedRole != 'MARKETING_OFFICER') ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: _referralCodeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'রেফারেল কোড (ঐচ্ছিক, যেমন: LT-NOA-1001)',
                              prefixIcon: Icon(Icons.card_giftcard, size: 18),
                              isDense: true,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Payment Instructions Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade600),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'নিবন্ধন ফি: ৳$currentRoleFee (নিচের নম্বরে Send Money করুন)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              ...paymentMethods.map((pm) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '👉 ${pm['providerName']}: ${pm['accountNumber']} (${pm['accountType']})',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0B4F32)),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: pm['accountNumber'].toString()));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${pm['accountNumber']} কপি হয়েছে!')),
                                            );
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            child: Icon(Icons.copy, size: 15, color: Color(0xFF0B4F32)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        LayoutBuilder(
                          builder: (ctx, constraints) {
                            final halfWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: halfWidth,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedPaymentMethod,
                                    decoration: const InputDecoration(labelText: 'পেমেন্টের মাধ্যম', isDense: true),
                                    items: paymentOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                    onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
                                  ),
                                ),
                                SizedBox(
                                  width: halfWidth,
                                  child: TextField(
                                    controller: _senderPhoneCtrl,
                                    decoration: const InputDecoration(labelText: 'প্রেরক মোবাইল নম্বর *', isDense: true),
                                  ),
                                ),
                                SizedBox(
                                  width: constraints.maxWidth,
                                  child: TextField(
                                    controller: _trxIdCtrl,
                                    decoration: const InputDecoration(labelText: 'ট্রানজ্যাকশন আইডি (TrxID) *', isDense: true),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B4F32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _submitting ? null : _submitRegistration,
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: Text(
                              'নিবন্ধন সম্পন্ন করুন (ফি: ৳$currentRoleFee)',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _demoButton(String label, String phone, String pass, Color color, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      onPressed: _submitting ? null : () => _quickDemoLogin(phone, pass),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _roleCard(String roleValue, String title, String subtitle, IconData icon) {
    final selected = _selectedRole == roleValue;
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleValue),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF0B4F32) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0B4F32), size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF0B4F32), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (_trxIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে পেমেন্টের ট্রানজ্যাকশন আইডি (TrxID) প্রদান করুন।')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiService.register({
        'fullName': _fullNameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'password': _passCtrl.text,
        'role': _selectedRole,
        'district': _district,
        'upazila': _upazila,
        'address': _addressCtrl.text.trim(),
        'referralCode': _selectedRole == 'MARKETING_OFFICER' ? '' : _referralCodeCtrl.text.trim(),
        'paymentMethod': _selectedPaymentMethod,
        'senderPhone': _senderPhoneCtrl.text.trim().isEmpty ? _phoneCtrl.text.trim() : _senderPhoneCtrl.text.trim(),
        'transactionId': _trxIdCtrl.text.trim(),
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
