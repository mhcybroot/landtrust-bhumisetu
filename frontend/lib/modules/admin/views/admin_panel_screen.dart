import 'package:flutter/material.dart';
import '../view_models/admin_view_model.dart';
import 'admin_commissions_tab.dart';
import 'admin_demands_inquiries_tab.dart';
import 'admin_finance_proposals_tab.dart';
import 'admin_listings_tab.dart';
import 'admin_overview_tab.dart';
import 'admin_settings_tab.dart';
import 'admin_users_tab.dart';

class AdminPanelScreen extends StatefulWidget {
  final VoidCallback onRefreshParent;

  const AdminPanelScreen({super.key, required this.onRefreshParent});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  late final AdminViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminViewModel();
    _viewModel.loadAllData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading && _viewModel.users.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
        }

        final isMobile = MediaQuery.of(context).size.width < 768;
        final tabs = [
          (Icons.dashboard, 'ড্যাশবোর্ড ও ফান্ড'),
          (Icons.people, 'সদস্য (${_viewModel.users.length})'),
          (Icons.landscape, 'বিজ্ঞাপন (${_viewModel.listings.length})'),
          (Icons.person_search, 'চাহিদা ও ইনকোয়ারি'),
          (Icons.military_tech, 'কমিশন (${_viewModel.commissions.length})'),
          (Icons.account_balance, 'লেজার ও চুক্তি'),
          (Icons.settings, 'সেটিংস ও পলিসি'),
        ];

        return RefreshIndicator(
          onRefresh: _viewModel.loadAllData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 12 : 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBanner(isMobile),
                    const SizedBox(height: 12),
                    _buildTabsBar(tabs),
                    const SizedBox(height: 16),
                    _buildActiveTab(isMobile),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(color: const Color(0xFF0A2E1F), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('কেন্দ্রীয় অ্যাডমিন প্যানেল — ভূমি সেতু', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('সদস্য অনুমোদন, নথি যাচাই, ইনকোয়ারি ও ৩-খাত আর্থিক ব্যবস্থাপনা', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _viewModel.loadAllData, tooltip: 'রিফ্রেশ'),
        ],
      ),
    );
  }

  Widget _buildTabsBar(List<(IconData, String)> tabs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final sel = _viewModel.selectedTab == idx;
          final item = tabs[idx];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              avatar: Icon(item.$1, size: 16, color: sel ? Colors.white : const Color(0xFF0B4F32)),
              label: Text(item.$2),
              selected: sel,
              selectedColor: const Color(0xFF0B4F32),
              labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 12),
              onSelected: (_) => _viewModel.selectTab(idx),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTab(bool isMobile) {
    return switch (_viewModel.selectedTab) {
      1 => AdminUsersTab(viewModel: _viewModel, isMobile: isMobile),
      2 => AdminListingsTab(viewModel: _viewModel, isMobile: isMobile),
      3 => AdminDemandsInquiriesTab(viewModel: _viewModel, isMobile: isMobile),
      4 => AdminCommissionsTab(viewModel: _viewModel, isMobile: isMobile),
      5 => AdminFinanceProposalsTab(viewModel: _viewModel, isMobile: isMobile),
      6 => AdminSettingsTab(viewModel: _viewModel, isMobile: isMobile),
      _ => AdminOverviewTab(viewModel: _viewModel, isMobile: isMobile),
    };
  }
}
