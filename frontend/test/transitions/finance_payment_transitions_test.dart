import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/finance_payment_transitions.dart';

void main() {
  testWidgets('PaymentSuccessCoinDropTransition renders dropped coin', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PaymentSuccessCoinDropTransition(isSuccess: true, child: Text('Coin')))));
    expect(find.text('Coin'), findsOneWidget);
  });

  testWidgets('EscrowStatusProgressStepTransition renders progress step', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EscrowStatusProgressStepTransition(currentStep: 2, totalSteps: 4))));
    expect(find.byType(EscrowStatusProgressStepTransition), findsOneWidget);
  });

  testWidgets('BankCardFlipCvvTransition renders card face', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BankCardFlipCvvTransition(showBack: true, front: Text('Card Front'), back: Text('Card Back')))));
    expect(find.text('Card Back'), findsOneWidget);
  });

  testWidgets('TkCurrencyRollingOdometerTransition renders formatted currency', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TkCurrencyRollingOdometerTransition(amount: 50000))));
    expect(find.byType(TkCurrencyRollingOdometerTransition), findsOneWidget);
  });

  testWidgets('OtpDigitBoxPulseTransition renders otp box', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: OtpDigitBoxPulseTransition(isFocused: true, child: Text('5')))));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('DigitalReceiptFoldUnfoldTransition renders receipt', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DigitalReceiptFoldUnfoldTransition(isUnfolded: true, child: Text('Receipt Items')))));
    expect(find.text('Receipt Items'), findsOneWidget);
  });

  testWidgets('CommissionSplitSlidingBar renders split bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CommissionSplitSlidingBar(platformRatio: 0.7))));
    expect(find.byType(CommissionSplitSlidingBar), findsOneWidget);
  });

  testWidgets('SecurityShieldLockSnap renders shield', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SecurityShieldLockSnap(isLocked: true))));
    expect(find.byType(SecurityShieldLockSnap), findsOneWidget);
  });

  testWidgets('PayoutTransferFlyArrow renders fly arrow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PayoutTransferFlyArrow(isTransferring: true))));
    expect(find.byType(PayoutTransferFlyArrow), findsOneWidget);
  });

  testWidgets('InvoiceQrCodeZoomReveal renders qr zoom', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: InvoiceQrCodeZoomReveal(isVisible: true, child: Text('QR Code')))));
    expect(find.text('QR Code'), findsOneWidget);
  });
}
