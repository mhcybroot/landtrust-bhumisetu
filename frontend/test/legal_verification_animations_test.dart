import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/legal_verification_animations.dart';

void main() {
  testWidgets('TrustSealStamp renders official seal', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TrustSealStamp())));
    expect(find.byType(TrustSealStamp), findsOneWidget);
  });

  testWidgets('KhatiyanPageCurl renders page corner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: KhatiyanPageCurl())));
    expect(find.byType(KhatiyanPageCurl), findsOneWidget);
  });

  testWidgets('OwnershipChainTree renders genealogy steps', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: OwnershipChainTree(steps: ['CS', 'SA', 'RS']))));
    expect(find.text('CS'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);
  });

  testWidgets('DocumentScannerLaser renders scanning beam', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DocumentScannerLaser())));
    expect(find.byType(DocumentScannerLaser), findsOneWidget);
  });

  testWidgets('WatermarkSheenWave renders watermark text', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: WatermarkSheenWave(text: 'ORIGINAL'))));
    expect(find.text('ORIGINAL'), findsOneWidget);
  });

  testWidgets('DeedRibbonUnfurl renders deed ribbon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DeedRibbonUnfurl())));
    expect(find.byType(DeedRibbonUnfurl), findsOneWidget);
  });

  testWidgets('QrCodeScanFrame renders corner brackets', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: QrCodeScanFrame())));
    expect(find.byType(QrCodeScanFrame), findsOneWidget);
  });

  testWidgets('InjunctionWarningBeacon renders warning beacon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: InjunctionWarningBeacon(warningText: 'মামলাধীন'))));
    expect(find.text('মামলাধীন'), findsOneWidget);
  });

  testWidgets('MutationLedgerFlip renders mutation number', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MutationLedgerFlip(mutationNo: 'MUT-8902'))));
    expect(find.text('MUT-8902'), findsOneWidget);
  });

  testWidgets('DigitalSignatureStroke renders signature canvas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DigitalSignatureStroke())));
    expect(find.byType(DigitalSignatureStroke), findsOneWidget);
  });
}
