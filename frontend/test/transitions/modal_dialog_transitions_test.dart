import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/modal_dialog_transitions.dart';

void main() {
  testWidgets('ScaleBounceDialogTransition renders child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ScaleBounceDialogTransition(child: Text('Modal 11')))));
    expect(find.text('Modal 11'), findsOneWidget);
  });

  testWidgets('BackdropBlurRevealTransition renders child with blur', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BackdropBlurRevealTransition(child: Text('Modal 12')))));
    expect(find.text('Modal 12'), findsOneWidget);
  });

  testWidgets('TopCurtainNotificationDrop renders banner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TopCurtainNotificationDrop(message: 'জরুরি নোটিশ'))));
    expect(find.text('জরুরি নোটিশ'), findsOneWidget);
  });

  testWidgets('Perspective3dFlipAlert renders alert card', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Perspective3dFlipAlert(child: Text('Legal Alert')))));
    expect(find.text('Legal Alert'), findsOneWidget);
  });

  testWidgets('CenterPopActionTransition renders pop action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CenterPopActionTransition(child: Text('Pop Content')))));
    expect(find.text('Pop Content'), findsOneWidget);
  });

  testWidgets('SlideUpNoticeTransition renders notice bar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SlideUpNoticeTransition(notice: 'সফলভাবে সংরক্ষিত'))));
    expect(find.text('সফলভাবে সংরক্ষিত'), findsOneWidget);
  });

  testWidgets('RadialCornerDialogReveal renders modal child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RadialCornerDialogReveal(child: Text('Radial Modal')))));
    expect(find.text('Radial Modal'), findsOneWidget);
  });

  testWidgets('PencilSketchBorderDialog renders sketched dialog', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PencilSketchBorderDialog(child: Text('Sketch Dialog')))));
    expect(find.text('Sketch Dialog'), findsOneWidget);
  });

  testWidgets('ShutterBlindModalTransition renders shutter modal', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ShutterBlindModalTransition(child: Text('Shutter Dialog')))));
    expect(find.text('Shutter Dialog'), findsOneWidget);
  });

  testWidgets('VanishDissolveDismiss renders dissolving child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: VanishDissolveDismiss(child: Text('Dissolve Me')))));
    expect(find.text('Dissolve Me'), findsOneWidget);
  });
}
