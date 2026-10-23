import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/admin/view_models/admin_view_model.dart';
import 'package:landtrust_app/modules/admin/views/admin_overview_tab.dart';
import 'package:landtrust_app/modules/admin/views/admin_users_tab.dart';
import 'package:landtrust_app/modules/admin/views/admin_listings_tab.dart';
import 'package:landtrust_app/modules/admin/views/admin_demands_inquiries_tab.dart';
import 'package:landtrust_app/modules/admin/views/admin_commissions_tab.dart';
import 'package:landtrust_app/modules/admin/views/admin_finance_proposals_tab.dart';
import 'package:landtrust_app/modules/admin/views/admin_settings_tab.dart';
import 'package:landtrust_app/modules/admin/views/admin_chat_inbox_tab.dart';
import 'package:landtrust_app/modules/admin/views/mobile/admin_panel_mobile_view.dart';

void main() {
  testWidgets('Test AdminOverviewTab on mobile 360x640', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = AdminViewModel();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: AdminOverviewTab(viewModel: vm, isMobile: true)),
      ),
    ));
    await tester.pump();
  });

  testWidgets('Test AdminPanelMobileView full structure on mobile 360x640', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = AdminViewModel();
    await tester.pumpWidget(MaterialApp(
      home: AdminPanelMobileView(viewModel: vm),
    ));
    await tester.pump();
  });

  for (int i = 1; i <= 7; i++) {
    testWidgets('Test Admin tab $i on mobile 360x640', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final vm = AdminViewModel();
      Widget tabWidget = switch (i) {
        1 => AdminUsersTab(viewModel: vm, isMobile: true),
        2 => AdminListingsTab(viewModel: vm, isMobile: true),
        3 => AdminDemandsInquiriesTab(viewModel: vm, isMobile: true),
        4 => AdminCommissionsTab(viewModel: vm, isMobile: true),
        5 => AdminFinanceProposalsTab(viewModel: vm, isMobile: true),
        6 => AdminSettingsTab(viewModel: vm, isMobile: true),
        _ => const AdminChatInboxTab(isMobile: true),
      };

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: tabWidget),
        ),
      ));
      await tester.pump();
    });
  }
}
