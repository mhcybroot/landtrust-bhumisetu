import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/auth/view_models/auth_view_model.dart';
import 'package:landtrust_app/modules/auth/views/mobile/auth_mobile_view.dart';

void main() {
  testWidgets('Test Signup page on mobile 360x640 with empty config', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = AuthViewModel();
    vm.setLoginMode(false); // Signup page

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AuthMobileView(
          viewModel: vm,
          config: const {},
          onLogin: (u, p) async {},
          onRegister: (_) async {},
        ),
      ),
    ));
    await tester.pump();
  });

  testWidgets('Test Signup page on mobile 360x640 with realistic config', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final vm = AuthViewModel();
    vm.setLoginMode(false); // Signup page

    final mockConfig = {
      'settings': {
        'buyerRegistrationFee': 500,
        'sellerRegistrationFeeUnion': 500,
        'sellerRegistrationFeePourashava': 1000,
        'officerRegistrationFeeUnion': 300,
        'officerRegistrationFeePourashava': 500,
      },
      'paymentMethods': [
        {'providerName': 'বিকাশ (bKash)', 'accountNumber': '01711-889900', 'accountType': 'Personal'},
        {'providerName': 'নগদ (Nagad)', 'accountNumber': '01819-556677', 'accountType': 'Personal'},
      ],
      'locations': [
        {'districtNameBn': 'নোয়াখালী', 'upazilaNameBn': 'নোয়াখালী সদর', 'areaType': 'UPAZILA'},
        {'districtNameBn': 'নোয়াখালী', 'upazilaNameBn': 'চৌমুহনী পৌরসভা', 'areaType': 'POURASHAVA'},
        {'districtNameBn': 'ফেনী', 'upazilaNameBn': 'ফেনী সদর', 'areaType': 'UPAZILA'},
      ]
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AuthMobileView(
          viewModel: vm,
          config: mockConfig,
          onLogin: (u, p) async {},
          onRegister: (_) async {},
        ),
      ),
    ));
    await tester.pump();
  });
}
