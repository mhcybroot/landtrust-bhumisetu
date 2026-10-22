import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/pulse_beacon_indicator.dart';
import 'package:landtrust_app/core/animations/sheen_sweep_effect.dart';
import 'package:landtrust_app/core/widgets/animated_success_dialog.dart';
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

  testWidgets('AnimatedSuccessDialog renders with checkmark and confirms', (tester) async {
    bool confirmed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                AnimatedSuccessDialog.show(
                  context,
                  title: 'আবেদন সফল',
                  message: 'আপনার অনুরোধ গৃহীত হয়েছে।',
                  onConfirm: () => confirmed = true,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('আবেদন সফল'), findsOneWidget);
    expect(find.text('আপনার অনুরোধ গৃহীত হয়েছে।'), findsOneWidget);

    await tester.tap(find.text('ঠিক আছে'));
    await tester.pumpAndSettle();

    expect(confirmed, isTrue);
  });

  testWidgets('PulseBeaconIndicator renders radiating rings and center dot', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PulseBeaconIndicator(
            color: Colors.green,
            size: 10,
          ),
        ),
      ),
    );

    expect(find.byType(PulseBeaconIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(PulseBeaconIndicator), findsOneWidget);
  });
}
