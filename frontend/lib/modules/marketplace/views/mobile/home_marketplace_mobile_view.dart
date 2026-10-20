import 'package:flutter/material.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import '../../view_models/marketplace_view_model.dart';
import '../../widgets/contact_inquiry_dialog.dart';
import '../../widgets/mobile/mobile_filter_bottom_sheet.dart';
import '../../widgets/mobile/mobile_property_card.dart';
import '../../widgets/mobile/mobile_property_details_sheet.dart';
import '../../widgets/mobile/mobile_search_header.dart';

class HomeMarketplaceMobileView extends StatefulWidget {
  final MarketplaceViewModel viewModel;
  final VoidCallback onNavigateToAuth;

  const HomeMarketplaceMobileView({
    super.key,
    required this.viewModel,
    required this.onNavigateToAuth,
  });

  @override
  State<HomeMarketplaceMobileView> createState() => _HomeMarketplaceMobileViewState();
}

class _HomeMarketplaceMobileViewState extends State<HomeMarketplaceMobileView> {
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

  void _openFilterSheet(List<String> upazilas) {
    final vm = widget.viewModel;
    MobileFilterBottomSheet.show(
      context,
      upazilas: upazilas,
      initialUpazila: vm.filterUpazila,
      initialLandType: vm.filterLandType,
      initialVerification: vm.filterVerification,
      maxBudgetCtrl: _maxBudgetCtrl,
      minAreaCtrl: _minAreaCtrl,
      maxAreaCtrl: _maxAreaCtrl,
      onApply: (u, lt, v) {
        vm.setFilterUpazila(u);
        vm.setFilterLandType(lt);
        vm.setFilterVerification(v);
        _triggerSearch();
      },
      onReset: _resetSearch,
    );
  }

  void _handleInquiry(Map<String, dynamic> listing) {
    if (SessionManager.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('যোগাযোগ করতে প্রথমে লগইন করুন।')),
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
    final locations = (vm.config['locations'] as List<dynamic>?) ?? [];
    final upazilas = locations
        .where((l) => vm.filterDistrict.isEmpty || l['districtNameBn'] == vm.filterDistrict)
        .map((l) => l['upazilaNameBn'].toString())
        .toSet()
        .toList();

    return RefreshIndicator(
      color: const Color(0xFF0B4F32),
      onRefresh: () async => vm.loadInitialData(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MobileSearchHeader(
              searchCtrl: _searchCtrl,
              onSearch: _triggerSearch,
              onFilterClick: () => _openFilterSheet(upazilas),
              upazilas: upazilas,
              selectedUpazila: vm.filterUpazila,
              onUpazilaSelected: (u) {
                vm.setFilterUpazila(u);
                _triggerSearch();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('বিক্রয়যোগ্য জমি (${vm.listings.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32))),
                  if (_searchCtrl.text.isNotEmpty || vm.filterUpazila.isNotEmpty)
                    TextButton(onPressed: _resetSearch, child: const Text('রিসেট', style: TextStyle(fontSize: 12))),
                ],
              ),
            ),
          ),
          if (vm.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF0B4F32))),
            )
          else if (vm.listings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 10),
                    const Text('কোনো জমির বিজ্ঞাপন পাওয়া যায়নি।'),
                    const SizedBox(height: 10),
                    TextButton(onPressed: _resetSearch, child: const Text('সব ফিল্টার মুছুন')),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final listing = vm.listings[index] as Map<String, dynamic>;
                  return MobilePropertyCard(
                    listing: listing,
                    onDetailsClick: () => MobilePropertyDetailsSheet.show(
                      context,
                      listing: listing,
                      onInquiryClick: () => _handleInquiry(listing),
                    ),
                    onInquiryClick: () => _handleInquiry(listing),
                  );
                },
                childCount: vm.listings.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
