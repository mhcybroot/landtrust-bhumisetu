import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/finance_escrow_animations.dart';

void main() {
  testWidgets('EscrowVaultLock renders vault icon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: EscrowVaultLock(isLocked: true))));
    expect(find.byType(EscrowVaultLock), findsOneWidget);
  });

  testWidgets('BankNoteCounter renders note count', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BankNoteCounter(notesCount: 50))));
    expect(find.textContaining('৫০ বান্ডিল'), findsOneWidget);
  });

  testWidgets('DepositShieldPulse renders deposit shield', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DepositShieldPulse())));
    expect(find.byType(DepositShieldPulse), findsOneWidget);
  });

  testWidgets('TaxBreakdownSplit renders tax split bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TaxBreakdownSplit(stampDutyPercent: 3, regFeePercent: 2, localTaxPercent: 1.5))));
    expect(find.byType(TaxBreakdownSplit), findsOneWidget);
  });

  testWidgets('MilestonePathGlow renders installment steps', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MilestonePathGlow(totalInstallments: 4, paidInstallments: 2))));
    expect(find.byType(MilestonePathGlow), findsOneWidget);
  });

  testWidgets('RefundReversalArrow renders refund reversal indicator', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RefundReversalArrow())));
    expect(find.byType(RefundReversalArrow), findsOneWidget);
  });

  testWidgets('LedgerSlideEntry renders transaction row', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LedgerSlideEntry(child: Text('TXN-7788')))));
    expect(find.text('TXN-7788'), findsOneWidget);
  });

  testWidgets('CashbackGlowRipple renders cashback ripple', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CashbackGlowRipple(amountTaka: 500))));
    expect(find.textContaining('500'), findsOneWidget);
  });

  testWidgets('InvoiceProgressBar renders progress bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: InvoiceProgressBar(progress: 0.7))));
    expect(find.byType(InvoiceProgressBar), findsOneWidget);
  });

  testWidgets('FeeSpeedoMeter renders meter arc', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FeeSpeedoMeter(valueRatio: 0.6))));
    expect(find.byType(FeeSpeedoMeter), findsOneWidget);
  });
}
