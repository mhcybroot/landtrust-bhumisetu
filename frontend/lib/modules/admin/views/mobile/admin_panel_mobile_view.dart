import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/animated_fade_switcher.dart';
import 'package:landtrust_app/core/widgets/horizontal_scroll_fade_view.dart';
import '../../view_models/admin_view_model.dart';
import '../admin_commissions_tab.dart';
import '../admin_demands_inquiries_tab.dart';
import '../admin_finance_proposals_tab.dart';
import '../admin_listings_tab.dart';
import '../admin_overview_tab.dart';
import '../admin_settings_tab.dart';
import '../admin_users_tab.dart';
import '../admin_chat_inbox_tab.dart';

class AdminPanelMobileView extends StatelessWidget {
  final AdminViewModel viewModel;
  final VoidCallback? onRefreshParent;

  const AdminPanelMobileView({super.key, required this.viewModel, this.onRefreshParent});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (Icons.dashboard_outlined, 'সারসংক্ষেপ'),
      (Icons.people_alt_outlined, 'সদস্য (${viewModel.users.length})'),
      (Icons.landscape_outlined, 'বিজ্ঞাপন (${viewModel.listings.length})'),
      (Icons.person_search_outlined, 'চাহিদা'),
      (Icons.military_tech_outlined, 'কমিশন'),
      (Icons.account_balance_outlined, 'লেজার'),
      (Icons.settings_outlined, 'সেটিংস'),
      (Icons.mark_chat_unread_outlined, 'সাপোর্ট'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: RefreshIndicator(
        color: const Color(0xFF0B4F32),
        onRefresh: viewModel.loadAllData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF0A2E1F), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('অ্যাডমিন ড্যাশবোর্ড', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.refresh, color: Colors.white, size: 20), onPressed: viewModel.loadAllData),
                ],
              ),
            ),
            const SizedBox(height: 10),
            HorizontalScrollFadeView(
              child: Row(
                children: List.generate(tabs.length, (idx) {
                  final sel = viewModel.selectedTab == idx;
                  final item = tabs[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Icon(item.$1, size: 14, color: sel ? Colors.white : const Color(0xFF0B4F32)),
                      label: Text(item.$2),
                      selected: sel,
                      selectedColor: const Color(0xFF0B4F32),
                      labelStyle: TextStyle(color: sel ? Colors.white : Colors.black87, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 11.5),
                      onSelected: (_) => viewModel.selectTab(idx),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedFadeSwitcher(
              child: KeyedSubtree(
                key: ValueKey(viewModel.selectedTab),
                child: switch (viewModel.selectedTab) {
                  1 => AdminUsersTab(viewModel: viewModel, isMobile: true),
                  2 => AdminListingsTab(viewModel: viewModel, isMobile: true),
                  3 => AdminDemandsInquiriesTab(viewModel: viewModel, isMobile: true),
                  4 => AdminCommissionsTab(viewModel: viewModel, isMobile: true),
                  5 => AdminFinanceProposalsTab(viewModel: viewModel, isMobile: true),
                  6 => AdminSettingsTab(viewModel: viewModel, isMobile: true, onSettingsSaved: onRefreshParent),
                  7 => const AdminChatInboxTab(isMobile: true),
                  _ => AdminOverviewTab(viewModel: viewModel, isMobile: true),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

