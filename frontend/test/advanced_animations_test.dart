import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/sheen_sweep_effect.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

void main() {
  testWidgets('SheenSweepEffect renders child widget properly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SheenSweepEffect(
            child: Text('যাচাইকৃত'),
          ),
        ),
      ),
    );

    expect(find.text('যাচাইকৃত'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SheenSweepEffect), findsOneWidget);
  });

  testWidgets('VerificationBadge wraps approved status in SheenSweepEffect', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VerificationBadge(status: 'APPROVED_PUBLISHED'),
        ),
      ),
    );

    expect(find.byType(SheenSweepEffect), findsOneWidget);
    expect(find.textContaining('যাচাইকৃত'), findsOneWidget);
  });
}
