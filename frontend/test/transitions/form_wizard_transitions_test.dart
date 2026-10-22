import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/form_wizard_transitions.dart';

void main() {
  testWidgets('StepSlideFadeTransition renders step child', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: StepSlideFadeTransition(currentStep: 1, child: Text('Step 1 Form')))));
    expect(find.text('Step 1 Form'), findsOneWidget);
  });

  testWidgets('StepProgressGrowthTransition renders progress line', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: StepProgressGrowthTransition(progress: 0.6))));
    expect(find.byType(StepProgressGrowthTransition), findsOneWidget);
  });

  testWidgets('FieldErrorShakeTransition renders child field', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FieldErrorShakeTransition(hasError: true, child: TextField()))));
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('FaceScannerFrameMorph renders scanner frame', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FaceScannerFrameMorph(isBiometricMode: true))));
    expect(find.byType(FaceScannerFrameMorph), findsOneWidget);
  });

  testWidgets('SubmitButtonLoaderToSuccess renders button state', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SubmitButtonLoaderToSuccess(isLoading: false, isSuccess: true, label: 'জমা দিন'))));
    expect(find.text('জমা দিন'), findsNothing);
  });

  testWidgets('CascadingDropdownTransition renders cascading child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CascadingDropdownTransition(isVisible: true, child: Text('জেলা নির্বাচন')))));
    expect(find.text('জেলা নির্বাচন'), findsOneWidget);
  });

  testWidgets('UnitConverterSpinTransition renders unit label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: UnitConverterSpinTransition(isKatha: true))));
    expect(find.text('কাঠা'), findsOneWidget);
  });

  testWidgets('DraftAutoSaveFlash renders persistent child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DraftAutoSaveFlash(isSaving: true, child: Text('Saved Draft')))));
    expect(find.text('Saved Draft'), findsOneWidget);
  });

  testWidgets('PriceSliderBubblePop renders bubble price', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PriceSliderBubblePop(priceText: '৳ ৩৫ লাখ', isDragging: true))));
    expect(find.text('৳ ৩৫ লাখ'), findsOneWidget);
  });

  testWidgets('UploadRingToCompleteTransition renders ring state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: UploadRingToCompleteTransition(isCompleted: true, progress: 1.0))));
    expect(find.byType(UploadRingToCompleteTransition), findsOneWidget);
  });
}
