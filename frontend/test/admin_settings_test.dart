import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/constants/app_constants.dart';
import 'package:landtrust_app/modules/admin/view_models/admin_view_model.dart';
import 'package:landtrust_app/modules/admin/views/admin_settings_tab.dart';
import 'package:landtrust_app/modules/admin/repositories/admin_repository.dart';
import 'package:landtrust_app/modules/marketplace/views/mobile/rules_and_fees_mobile_view.dart';
import 'package:landtrust_app/modules/marketplace/views/web/rules_and_fees_web_view.dart';

class FakeAdminRepository extends AdminRepository {
  Map<String, dynamic> fakeDashboard = {};
  @override
  Future<Map<String, dynamic>> fetchDashboard() async => fakeDashboard;
  @override
  Future<List<dynamic>> fetchUsers() async => [];
  @override
  Future<List<dynamic>> fetchListings() async => [];
  @override
  Future<List<dynamic>> fetchRequirements() async => [];
  @override
  Future<List<dynamic>> fetchInquiries() async => [];
  @override
  Future<List<dynamic>> fetchCommissions() async => [];
  @override
  Future<List<dynamic>> fetchProposals() async => [];
  @override
  Future<List<dynamic>> fetchTransactions() async => [];
  @override
  Future<List<dynamic>> fetchPaymentMethods() async => [];
  @override
  Future<List<dynamic>> fetchLocations() async => [];
}

class TestAdminViewModel extends AdminViewModel {
  final FakeAdminRepository fakeRepo;
  TestAdminViewModel(this.fakeRepo) : super(repository: fakeRepo);

  void triggerSyncWithSettings(Map<String, dynamic> newSettings) {
    fakeRepo.fakeDashboard = {'settings': newSettings};
    loadAllData();
  }
}

void main() {
  testWidgets('AdminSettingsTab respects baseline default and protects active edits', (tester) async {
    final repo = FakeAdminRepository();
    final vm = TestAdminViewModel(repo);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AdminSettingsTab(viewModel: vm, isMobile: true),
        ),
      ),
    ));

    final phoneField = find.widgetWithText(TextField, AppConstants.defaultSupportPhone).first;
    expect(phoneField, findsOneWidget);

    await tester.enterText(phoneField, '01999-888777');
    await tester.pump();
    expect(find.widgetWithText(TextField, '01999-888777'), findsOneWidget);

    vm.triggerSyncWithSettings({'supportPhone': '01333-222111'});
    await tester.pumpAndSettle();

    // In-flight edit must not be overwritten
    expect(find.widgetWithText(TextField, '01999-888777'), findsOneWidget);
    expect(find.widgetWithText(TextField, '01333-222111'), findsNothing);
  });

  testWidgets('Rules and fees views use AppConstants fallbacks', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RulesAndFeesMobileView(config: {})),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining(AppConstants.defaultSupportPhone), findsWidgets);
    expect(find.textContaining(AppConstants.defaultSupportEmail), findsWidgets);

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: RulesAndFeesWebView(config: {})),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining(AppConstants.defaultSupportPhone), findsWidgets);
    expect(find.textContaining(AppConstants.defaultSupportEmail), findsWidgets);
  });
}
