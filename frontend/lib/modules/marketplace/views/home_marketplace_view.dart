import 'package:flutter/material.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import '../view_models/marketplace_view_model.dart';
import '../widgets/contact_inquiry_dialog.dart';
import '../widgets/hero_banner_widget.dart';
import '../widgets/home_stats_row.dart';
import '../widgets/listing_filter_bar.dart';
import '../widgets/property_card_widget.dart';
import '../widgets/property_details_dialog.dart';

class HomeMarketplaceView extends StatefulWidget {
  final MarketplaceViewModel viewModel;
  final bool isMobile;
  final VoidCallback onNavigateToAuth;

  const HomeMarketplaceView({
    super.key,
    required this.viewModel,
    required this.isMobile,
    required this.onNavigateToAuth,
  });

  @override
  State<HomeMarketplaceView> createState() => _HomeMarketplaceViewState();
}

class _HomeMarketplaceViewState extends State<HomeMarketplaceView> {
  final _searchCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();
  final _minAreaCtrl = TextEditingController();
  final _maxAreaCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _maxBudgetCtrl.dispose();
    _minAreaCtrl.dispose();
    _maxAreaCtrl.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    widget.viewModel.setKeyword(_searchCtrl.text.trim());
    widget.viewModel.loadListings(
      customBudget: _maxBudgetCtrl.text.trim().isEmpty ? null : _maxBudgetCtrl.text.trim(),
      customMinArea: _minAreaCtrl.text.trim().isEmpty ? null : _minAreaCtrl.text.trim(),
      customMaxArea: _maxAreaCtrl.text.trim().isEmpty ? null : _maxAreaCtrl.text.trim(),
    );
  }

  void _resetSearch() {
    _searchCtrl.clear();
    _maxBudgetCtrl.clear();
    _minAreaCtrl.clear();
    _maxAreaCtrl.clear();
    widget.viewModel.resetFilters();
  }

  void _handleInquiry(Map<String, dynamic> listing) {
    if (SessionManager.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('যোগাযোগের অনুরোধ পাঠাতে প্রথমে লগইন বা নিবন্ধন করুন।')),
      );
      widget.onNavigateToAuth();
      return;
    }
    ContactInquiryDialog.show(
      context,
      listing: listing,
      onSubmit: (b, m) => widget.viewModel.sendInquiry(listing['id'] as int, b, m),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final isMobile = widget.isMobile;
    final locations = (vm.config['locations'] as List<dynamic>?) ?? [];
    final districts = locations.map((l) => l['districtNameBn'].toString()).toSet().toList();
    final upazilas = locations
        .where((l) => vm.filterDistrict.isEmpty || l['districtNameBn'] == vm.filterDistrict)
        .map((l) => l['upazilaNameBn'].toString())
        .toSet()
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          HeroBannerWidget(
            isMobile: isMobile,
            settings: (vm.config['settings'] as Map<String, dynamic>?) ?? {},
            searchCtrl: _searchCtrl,
            onSearch: _triggerSearch,
            onRoleRegisterClick: widget.onNavigateToAuth,
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListingFilterBar(
                      isMobile: isMobile,
                      districts: districts,
                      upazilas: upazilas,
                      selectedDistrict: vm.filterDistrict,
                      selectedUpazila: vm.filterUpazila,
                      selectedLandType: vm.filterLandType,
                      selectedVerification: vm.filterVerification,
                      filtersExpanded: vm.filtersExpanded,
                      searchCtrl: _searchCtrl,
                      maxBudgetCtrl: _maxBudgetCtrl,
                      minAreaCtrl: _minAreaCtrl,
                      maxAreaCtrl: _maxAreaCtrl,
                      onDistrictChanged: (d) => vm.setFilterDistrict(d),
                      onUpazilaChanged: (u) => vm.setFilterUpazila(u),
                      onLandTypeSelected: (lt) => vm.setFilterLandType(lt),
                      onVerificationSelected: (v) => vm.setFilterVerification(v),
                      onToggleExpanded: () => vm.toggleFiltersExpanded(),
                      onSearch: _triggerSearch,
                      onReset: _resetSearch,
                    ),
                    const SizedBox(height: 20),
                    HomeStatsRow(stats: vm.stats, isMobile: widget.isMobile),
                    const SizedBox(height: 24),
                    _buildHeader(vm.listings.length),
                    const SizedBox(height: 14),
                    if (vm.isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                    else if (vm.listings.isEmpty)
                      _buildEmptyCard()
                    else
                      _buildGrid(vm.listings),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('বিক্রয়যোগ্য জমির তালিকা ($count)', style: TextStyle(fontSize: widget.isMobile ? 17 : 22, fontWeight: FontWeight.bold, color: const Color(0xFF0B4F32))),
        if (count > 0) Text('সর্বশেষ আপডেট', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ]),
      const SizedBox(height: 4),
      const Text('স্বচ্ছতা ও সুরক্ষার জন্য প্রাথমিক নথি যাচাইকৃত বিজ্ঞাপনসমূহ প্রদর্শিত হচ্ছে।', style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]);
  }

  Widget _buildEmptyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('এই ফিল্টারে কোনো অনুমোদিত জমির বিজ্ঞাপন পাওয়া যায়নি।'),
            const SizedBox(height: 10),
            TextButton(onPressed: _resetSearch, child: const Text('সব ফিল্টার রিসেট করুন')),
          ]),
        ),
      ),
    );
  }

  Widget _buildGrid(List<dynamic> listings) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cardWidth = constraints.maxWidth < 620 ? constraints.maxWidth : (constraints.maxWidth < 980 ? (constraints.maxWidth - 14) / 2 : (constraints.maxWidth - 32) / 3);
      return Wrap(
        spacing: 14,
        runSpacing: 14,
        children: listings.map((l) {
          final map = l as Map<String, dynamic>;
          return SizedBox(
            width: cardWidth,
            child: PropertyCardWidget(
              listing: map,
              isMobile: widget.isMobile,
              onDetailsClick: () => PropertyDetailsDialog.show(context, listing: map, isMobile: widget.isMobile, onInquiryClick: () => _handleInquiry(map)),
              onInquiryClick: () => _handleInquiry(map),
            ),
          );
        }).toList(),
      );
    });
  }
}
