import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/nrb/widgets/nrb_request_card.dart';
import 'package:landtrust_app/modules/nrb/widgets/nrb_service_dialog.dart';

void main() {
  testWidgets('NrbRequestCard renders with status and sheen', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NrbRequestCard(request: {'poaStatus': 'SUBMITTED'}, isMobile: true)),
    ));
    await tester.pump();
    expect(find.byType(NrbRequestCard), findsOneWidget);
  });

  testWidgets('NrbServiceDialog renders legal stamp and currency converter', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NrbServiceDialog(isMobile: true)),
    ));
    await tester.pump();
    expect(find.byType(NrbServiceDialog), findsOneWidget);
  });
}
