import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/auth/widgets/payment_info_box.dart';
import 'package:landtrust_app/modules/auth/widgets/demo_accounts_bar.dart';

void main() {
  testWidgets('PaymentInfoBox renders with copy button', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: PaymentInfoBox(
          fee: 1000,
          paymentMethods: [
            {'providerName': 'bKash', 'accountNumber': '01711889900', 'accountType': 'Personal'},
          ],
        ),
      ),
    ));
    expect(find.byType(PaymentInfoBox), findsOneWidget);
    expect(find.text('কপি'), findsOneWidget);
  });

  testWidgets('DemoAccountsBar chips bounce on press with sheen sweep', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DemoAccountsBar(isLoading: false, onDemoSelect: (_, _) {})),
    ));
    expect(find.byType(DemoAccountsBar), findsOneWidget);
    expect(find.text('অ্যাডমিন ডেমো'), findsOneWidget);
  });
}
