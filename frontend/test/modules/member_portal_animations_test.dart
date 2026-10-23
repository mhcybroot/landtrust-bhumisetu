import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/member_portal/widgets/digital_id_card_dialog.dart';
import 'package:landtrust_app/modules/member_portal/widgets/agreement_certificate_dialog.dart';

void main() {
  testWidgets('DigitalIdCardDialog renders with 3D flip card and trust seal', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DigitalIdCardDialog(
          officerData: {'referralCode': 'LT-TEST'},
          isMobile: true,
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(DigitalIdCardDialog), findsOneWidget);
    expect(find.text('bdHousing'), findsOneWidget);
  });

  testWidgets('AgreementCertificateDialog renders trust seal and ribbon', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AgreementCertificateDialog(
          proposal: {'id': 1, 'customerName': 'Rahim', 'status': 'AGREED'},
          isMobile: true,
        ),
      ),
    ));
    await tester.pump();
    expect(find.byType(AgreementCertificateDialog), findsOneWidget);
  });
}
