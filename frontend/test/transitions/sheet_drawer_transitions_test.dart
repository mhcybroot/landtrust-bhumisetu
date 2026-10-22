import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/sheet_drawer_transitions.dart';

void main() {
  testWidgets('SmoothSheetDragSnapper renders sheet child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SmoothSheetDragSnapper(child: Text('Sheet Content')))));
    expect(find.text('Sheet Content'), findsOneWidget);
  });

  testWidgets('FilterDrawerFoldTransition renders drawer child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FilterDrawerFoldTransition(isOpen: true, child: Text('Filters')))));
    expect(find.text('Filters'), findsOneWidget);
  });

  testWidgets('StickyHeaderShrinkTransition renders shrink header', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: StickyHeaderShrinkTransition(title: 'Marketplace', isShrunk: false))));
    expect(find.text('Marketplace'), findsOneWidget);
  });

  testWidgets('AccordionShelfExpandTransition renders expanded shelf', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AccordionShelfExpandTransition(isExpanded: true, child: Text('Shelf Info')))));
    expect(find.text('Shelf Info'), findsOneWidget);
  });

  testWidgets('RotatingChevronDropdownTransition renders dropdown', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RotatingChevronDropdownTransition(isDropped: true, title: 'খতিয়ান বিবরণ'))));
    expect(find.text('খতিয়ান বিবরণ'), findsOneWidget);
  });

  testWidgets('MultiTabSlideFadeTransition renders tab content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MultiTabSlideFadeTransition(activeTab: 1, child: Text('Tab 1 Body')))));
    expect(find.text('Tab 1 Body'), findsOneWidget);
  });

  testWidgets('SplitDrawerDockTransition renders dock content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SplitDrawerDockTransition(isDocked: true, child: Text('Dock Panel')))));
    expect(find.text('Dock Panel'), findsOneWidget);
  });

  testWidgets('CurvedEdgePullTransition renders curved pull', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CurvedEdgePullTransition(pullDistance: 40, child: Text('Pull Target')))));
    expect(find.text('Pull Target'), findsOneWidget);
  });

  testWidgets('FloatingDockCollapseTransition renders floating dock', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FloatingDockCollapseTransition(isVisible: true, child: Text('Nav Bar')))));
    expect(find.text('Nav Bar'), findsOneWidget);
  });

  testWidgets('FloatingActionMenuRadialUnfurl renders radial menu', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FloatingActionMenuRadialUnfurl(isOpen: true, child: Text('Action Hub')))));
    expect(find.text('Action Hub'), findsOneWidget);
  });
}
