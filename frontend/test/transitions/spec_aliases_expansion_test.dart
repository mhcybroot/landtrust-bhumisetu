import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/transitions.dart';

void main() {
  testWidgets('All spec animation aliases instantiate cleanly', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            StaggeredSheetItemsSlide(index: 0, child: Text('Item')),
            ActiveTabIndicatorGlide(tabIndex: 0, child: Text('Tab')),
            SearchFilterTagSlide(isSelected: true, child: Text('Tag')),
            ReviewSummaryCardFlip(showBack: false, front: Text('F'), back: Text('B')),
          ],
        ),
      ),
    ));
    expect(find.text('Item'), findsOneWidget);
    expect(find.text('Tab'), findsOneWidget);
  });
}
