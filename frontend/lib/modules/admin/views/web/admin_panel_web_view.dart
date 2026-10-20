import 'package:flutter/material.dart';
import 'package:landtrust_app/core/widgets/horizontal_scroll_fade_view.dart';
import '../../view_models/admin_view_model.dart';
import '../admin_commissions_tab.dart';
import '../admin_demands_inquiries_tab.dart';
import '../admin_finance_proposals_tab.dart';
import '../admin_listings_tab.dart';
import '../admin_overview_tab.dart';
import '../admin_settings_tab.dart';
import '../admin_users_tab.dart';

class AdminPanelWebView extends StatelessWidget {
  final AdminViewModel viewModel;

  const AdminPanelWebView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.dashboard, 'ড্যাশবোর্ড ও ফান্ড'),
      (Icons.people, 'সদস্য (${viewModel.users.length})'),
      (Icons.landscape, 'বিজ্ঞাপন (${viewModel.listings.length})'),
      (Icons.person_search, 'চাহিদা ও ইনকোয়ারি'),
      (Icons.military_tech, 'কমিশন (${viewModel.commissions.length})'),
      (Icons.account_balance, 'লেজার ও চুক্তি'),
      (Icons.settings, 'সেটিংস ও পলিসি'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF0A2E1F), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('কেন্দ্রীয় অ্যাডমিন প্যানেল — ভূমি সেতু', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('সদস্য অনুমোদন, নথি যাচাই, ইনকোয়ারি ও ৩-খাত আর্থিক ব্যবস্থাপনা', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: viewModel.loadAllData, tooltip: 'রিফ্রেশ'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              HorizontalScrollFadeView(
                child: Row(
                  children: List.generate(tabs.length, (idx) {
                    final sel = viewModel.selectedTab == idx;
                    final item = tabs[idx];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(item.$1, size: 16, color: sel ? Colors.white : const Color(0xFF0B4F32)),
                        label: Text(item.$2),
                        selected: sel,
                        selectedColor: const Color(0xFF0B4F32),
                        labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13),
                        onSelected: (_) => viewModel.selectTab(idx),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              switch (viewModel.selectedTab) {
                1 => AdminUsersTab(viewModel: viewModel, isMobile: false),
                2 => AdminListingsTab(viewModel: viewModel, isMobile: false),
                3 => AdminDemandsInquiriesTab(viewModel: viewModel, isMobile: false),
                4 => AdminCommissionsTab(viewModel: viewModel, isMobile: false),
                5 => AdminFinanceProposalsTab(viewModel: viewModel, isMobile: false),
                6 => AdminSettingsTab(viewModel: viewModel, isMobile: false),
                _ => AdminOverviewTab(viewModel: viewModel, isMobile: false),
              },
            ],
          ),
        ),
      ),
    );
  }
}
