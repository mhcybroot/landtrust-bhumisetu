import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/luxury_ui_animations.dart';

void main() {
  testWidgets('ThemeCircularReveal renders child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ThemeCircularReveal(child: Text('Theme Content')))));
    expect(find.text('Theme Content'), findsOneWidget);
  });

  testWidgets('OledDarkShimmer renders dark shimmer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: OledDarkShimmer(child: SizedBox(width: 80, height: 20)))));
    expect(find.byType(OledDarkShimmer), findsOneWidget);
  });

  testWidgets('ComparisonDrawerMorph renders compare dock', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ComparisonDrawerMorph(itemCount: 2))));
    expect(find.textContaining('২টি জমি'), findsOneWidget);
  });

  testWidgets('FilterFrostedBlur renders child with blur', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FilterFrostedBlur(child: Text('Filters')))));
    expect(find.text('Filters'), findsOneWidget);
  });

  testWidgets('BouncyCheckbox toggles value with bounce', (tester) async {
    bool val = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => BouncyCheckbox(value: val, onChanged: (v) => setState(() => val = v)),
          ),
        ),
      ),
    );

    expect(find.byType(BouncyCheckbox), findsOneWidget);
    await tester.tap(find.byType(BouncyCheckbox));
    await tester.pump(const Duration(milliseconds: 150));
    expect(val, isTrue);
  });

  testWidgets('NotificationBellJingle renders bell icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: NotificationBellJingle())));
    expect(find.byType(NotificationBellJingle), findsOneWidget);
  });

  testWidgets('EmptyStateFloat renders floating illustration', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EmptyStateFloat(icon: Icons.search_off))));
    expect(find.byType(EmptyStateFloat), findsOneWidget);
  });

  testWidgets('HeaderElevationFade renders elevated header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HeaderElevationFade(isElevated: true, child: Text('Header')))));
    expect(find.text('Header'), findsOneWidget);
  });

  testWidgets('MemberLevelUpGlow renders glow badge', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MemberLevelUpGlow(levelName: 'গোল্ড সদস্য'))));
    expect(find.text('গোল্ড সদস্য'), findsOneWidget);
  });

  testWidgets('PagePopSlide renders page slide child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PagePopSlide(child: Text('Previous Page')))));
    expect(find.text('Previous Page'), findsOneWidget);
  });
}
