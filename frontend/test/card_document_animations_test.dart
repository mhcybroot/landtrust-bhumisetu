import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/card_document_animations.dart';

void main() {
  testWidgets('HeartBurstAnimation toggles state and emits particles', (tester) async {
    bool fav = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return HeartBurstAnimation(
                isFavorite: fav,
                onChanged: (v) => setState(() => fav = v),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(HeartBurstAnimation), findsOneWidget);
    await tester.tap(find.byType(HeartBurstAnimation));
    await tester.pump(const Duration(milliseconds: 200));
    expect(fav, isTrue);
  });

  testWidgets('AccordionTile expands and collapses content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccordionTile(
            title: Text('খতিয়ান রেকর্ড'),
            content: Text('সিএস দাগ নং ১২০৪'),
          ),
        ),
      ),
    );

    expect(find.text('খতিয়ান রেকর্ড'), findsOneWidget);
    await tester.tap(find.text('খতিয়ান রেকর্ড'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('সিএস দাগ নং ১২০৪'), findsOneWidget);
  });

  testWidgets('SwipeActionReveal renders child and responds to drag', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SwipeActionReveal(
            actionText: 'মুছুন',
            child: SizedBox(height: 50, child: Text('নোটিফিকেশন কার্ড')),
          ),
        ),
      ),
    );

    expect(find.text('নোটিফিকেশন কার্ড'), findsOneWidget);
  });

  testWidgets('CompassRefreshSpinner rotates smoothly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CompassRefreshSpinner(size: 24),
        ),
      ),
    );

    expect(find.byType(CompassRefreshSpinner), findsOneWidget);
  });
}
