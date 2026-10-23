import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/nrb/widgets/my_nrb_requests_dialog.dart';
import 'package:landtrust_app/modules/nrb/widgets/nrb_request_card.dart';
import 'package:landtrust_app/modules/nrb/widgets/nrb_service_dialog.dart';

void main() {
  testWidgets('Test MyNrbRequestsDialog on small mobile 320x480', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MyNrbRequestsDialog(isMobile: true)),
    ));
    await tester.pump();
    expect(find.text('আমার প্রবাসী সেবা ও PoA আবেদন'), findsOneWidget);
  });

  testWidgets('Test NrbServiceDialog on mobile 360x640', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NrbServiceDialog(isMobile: true)),
    ));
    await tester.pump();
    expect(find.text('প্রবাসী জমি বিক্রয় ও PoA সেবা'), findsOneWidget);
  });

  testWidgets('Test NrbRequestCard on mobile 320x480', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NrbRequestCard(request: {
        'poaStatus': 'SUBMITTED',
        'serviceType': 'POWER_OF_ATTORNEY',
        'district': 'নোয়াখালী',
        'upazila': 'নোয়াখালী সদর',
        'countryOfResidence': 'সৌদি আরব (রিয়াদ)',
        'landAreaDecimal': 5.5,
        'askingPriceBdt': 4500000,
      }, isMobile: true)),
    ));
    await tester.pump();
    expect(find.text('পাওয়ার অব অ্যাটর্নি (PoA)'), findsOneWidget);
  });
}
