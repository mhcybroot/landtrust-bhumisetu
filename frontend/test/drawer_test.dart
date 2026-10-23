import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/localization/locale_notifier.dart';
import 'package:landtrust_app/modules/shell/widgets/shell_drawer.dart';

void main() {
  testWidgets('ShellDrawer renders on 320x480 viewport without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testUser = {
      'fullName': 'মোঃ আনোয়ার হোসেন',
      'role': 'UPAZILA_AGENT',
      'phoneNumber': '01712345678',
    };

    int? selectedTab;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        endDrawer: ShellDrawer(
          selectedIndex: 0,
          isLoggedIn: true,
          isAdmin: false,
          user: testUser,
          config: const {},
          onTabSelected: (idx) => selectedTab = idx,
          onLogout: () {},
        ),
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            child: const Text('Open Drawer'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    expect(find.text('bdHousing'), findsOneWidget);
    expect(find.text('মোঃ আনোয়ার হোসেন'), findsOneWidget);
    expect(find.textContaining('ভূমিকা: উপজেলা এজেন্ট'), findsOneWidget);
    expect(find.text('চাহিদা'), findsOneWidget);

    // Tap demands tab
    await tester.tap(find.text('চাহিদা'));
    await tester.pumpAndSettle();

    expect(selectedTab, equals(1));
    expect(find.text('মোঃ আনোয়ার হোসেন'), findsNothing); // Drawer closed
  });

  testWidgets('Language toggle inside ShellDrawer works without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        endDrawer: ShellDrawer(
          selectedIndex: 0,
          isLoggedIn: false,
          isAdmin: false,
          user: null,
          config: const {},
          onTabSelected: (_) {},
          onLogout: () {},
        ),
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            child: const Text('Open Drawer'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open Drawer'));
    await tester.pumpAndSettle();

    // Toggle language
    final enPill = find.text('🇬🇧 EN');
    expect(enPill, findsOneWidget);
    await tester.tap(enPill);
    await tester.pumpAndSettle();

    expect(LocaleNotifier.instance.isEnglish, isTrue);

    // Toggle back to Bangla
    final bnPill = find.text('🇧🇩 বাং');
    expect(bnPill, findsOneWidget);
    await tester.tap(bnPill);
    await tester.pumpAndSettle();

    expect(LocaleNotifier.instance.isBangla, isTrue);
  });
}
