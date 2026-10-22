import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/form_feedback_animations.dart';

void main() {
  testWidgets('ErrorShakeAnimation renders child and shakes on trigger', (tester) async {
    final shakeKey = GlobalKey<ErrorShakeAnimationState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorShakeAnimation(
            key: shakeKey,
            child: const Text('Input Field'),
          ),
        ),
      ),
    );

    expect(find.text('Input Field'), findsOneWidget);
    shakeKey.currentState?.shake();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Input Field'), findsOneWidget);
  });

  testWidgets('PasswordEyeMorph toggles visibility icon with crossfade', (tester) async {
    bool obscure = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return PasswordEyeMorph(
                isObscured: obscure,
                onToggle: () => setState(() => obscure = !obscure),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(PasswordEyeMorph), findsOneWidget);
    await tester.tap(find.byType(PasswordEyeMorph));
    await tester.pump(const Duration(milliseconds: 200));
    expect(obscure, isFalse);
  });

  testWidgets('StepPulseIndicator displays active step number and pulse', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StepPulseIndicator(
            stepNumber: 2,
            isCurrent: true,
            isCompleted: false,
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.byType(StepPulseIndicator), findsOneWidget);
  });

  testWidgets('MorphingFabTrigger expands and handles callback', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorphingFabTrigger(
            icon: Icons.add,
            label: 'নতুন বিজ্ঞাপন',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('নতুন বিজ্ঞাপন'), findsOneWidget);
    await tester.tap(find.byType(MorphingFabTrigger));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tapped, isTrue);
  });
}
