import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/transitions.dart';
import 'package:landtrust_app/modules/marketplace/widgets/safety_warning_card.dart';

void main() {
  testWidgets('AppDialogTransition shows animated dialog', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => AppDialogTransition.show(
            context: context,
            builder: (_) => const AlertDialog(title: Text('Test Dialog')),
          ),
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Test Dialog'), findsOneWidget);
    expect(find.byType(BackdropBlurRevealTransition), findsOneWidget);
    expect(find.byType(ScaleBounceDialogTransition), findsOneWidget);
  });

  testWidgets('SharedAxisSlideRoute navigates smoothly', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Navigator.push(context, SharedAxisSlideRoute(page: const Scaffold(body: Text('Second Page')))),
          child: const Text('Navigate'),
        ),
      ),
    ));

    await tester.tap(find.text('Navigate'));
    await tester.pumpAndSettle();
    expect(find.text('Second Page'), findsOneWidget);
  });

  testWidgets('Spec aliases instantiate and render correctly', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            GridToLightboxZoom(isExpanded: true, collapsedChild: Text('Thumb'), expandedChild: Text('Lightbox')),
            DigitalReceiptPaperUnfold(isUnfolded: true, child: Text('Receipt Content')),
            WalletBalanceCreditRoll(amount: 15000),
            PaymentConfirmationShieldGlow(isLocked: true),
            BuyerToSellerFlipTransition(roleName: 'SELLER', child: Text('Seller View')),
          ],
        ),
      ),
    ));

    expect(find.text('Lightbox'), findsOneWidget);
    expect(find.text('Receipt Content'), findsOneWidget);
    expect(find.byType(WalletBalanceCreditRoll), findsOneWidget);
    expect(find.byType(PaymentConfirmationShieldGlow), findsOneWidget);
    expect(find.text('Seller View'), findsOneWidget);
  });

  testWidgets('SafetyWarningCard renders with SecurityShieldLockSnap', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SafetyWarningCard(isMobile: true)),
    ));
    expect(find.byType(SecurityShieldLockSnap), findsOneWidget);
  });
}
