import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/state_micro_transitions.dart';

void main() {
  testWidgets('ListItemDeleteCollapse renders list item', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ListItemDeleteCollapse(isDeleted: false, child: Text('List Item 1')))));
    expect(find.text('List Item 1'), findsOneWidget);
  });

  testWidgets('RefreshCrossfadeWipe renders loaded content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RefreshCrossfadeWipe(isRefreshing: false, child: Text('Refreshed Data')))));
    expect(find.text('Refreshed Data'), findsOneWidget);
  });

  testWidgets('SkeletonToContentFadeIn renders content when loaded', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SkeletonToContentFadeIn(isLoading: false, skeleton: Text('Loading...'), content: Text('Real Property')))));
    expect(find.text('Real Property'), findsOneWidget);
  });

  testWidgets('TabContentSlideWipe renders active tab content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TabContentSlideWipe(tabIndex: 2, child: Text('Tab 2 Body')))));
    expect(find.text('Tab 2 Body'), findsOneWidget);
  });

  testWidgets('BadgeCountPopTransition renders badge count', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BadgeCountPopTransition(count: 5))));
    expect(find.text('৫'), findsOneWidget);
  });

  testWidgets('CheckboxCrossfadeCheck renders check status', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CheckboxCrossfadeCheck(isChecked: true))));
    expect(find.byType(CheckboxCrossfadeCheck), findsOneWidget);
  });

  testWidgets('SortOrderArrowFlip renders sort arrow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SortOrderArrowFlip(isAscending: true))));
    expect(find.byType(SortOrderArrowFlip), findsOneWidget);
  });

  testWidgets('StatusPillColorShift renders status text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: StatusPillColorShift(isApproved: true, statusText: 'অনুমোদিত'))));
    expect(find.text('অনুমোদিত'), findsOneWidget);
  });

  testWidgets('EmptyToResultsMorph renders results view', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EmptyToResultsMorph(hasData: true, emptyView: Text('No Data'), resultsView: Text('Data Grid')))));
    expect(find.text('Data Grid'), findsOneWidget);
  });

  testWidgets('PaginationPageSlide renders page child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PaginationPageSlide(pageNumber: 2, child: Text('Page 2 Content')))));
    expect(find.text('Page 2 Content'), findsOneWidget);
  });
}
