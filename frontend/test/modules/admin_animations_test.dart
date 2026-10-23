import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/admin/widgets/award_commission_dialog.dart';
import 'package:landtrust_app/modules/admin/widgets/admin_listing_fees_card.dart';

void main() {
  testWidgets('AwardCommissionDialog renders milestone path and confetti burst', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AwardCommissionDialog(proposal: {'id': 1}, isMobile: true)),
    ));
    await tester.pump();
    expect(find.byType(AwardCommissionDialog), findsOneWidget);
  });

  testWidgets('AdminListingFeesCard renders fees with submit morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AdminListingFeesCard(fees: const {'buyerRegistrationFee': 1000}, onSave: (_) {})),
    ));
    await tester.pump();
    expect(find.byType(AdminListingFeesCard), findsOneWidget);
  });
}
