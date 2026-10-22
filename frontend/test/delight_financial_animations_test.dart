import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/delight_financial_animations.dart';

void main() {
  testWidgets('ChatTypingWave renders three animated dots', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ChatTypingWave())),
    );
    expect(find.byType(ChatTypingWave), findsOneWidget);
  });

  testWidgets('MessageFlightCurve slides message upward on enter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MessageFlightCurve(child: Text('হ্যালো অফিসার')))),
    );
    expect(find.text('হ্যালো অফিসার'), findsOneWidget);
  });

  testWidgets('RadialGaugeFill renders progress arc', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RadialGaugeFill(percent: 0.65))),
    );
    expect(find.byType(RadialGaugeFill), findsOneWidget);
  });

  testWidgets('RollingDigitCounter renders target value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RollingDigitCounter(value: 85000, prefix: '৳'))),
    );
    expect(find.textContaining('85000'), findsOneWidget);
  });

  testWidgets('CommissionSplitBar renders 3 shares', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CommissionSplitBar(fieldShare: 70, upazilaShare: 20, districtShare: 10))),
    );
    expect(find.byType(CommissionSplitBar), findsOneWidget);
  });

  testWidgets('CoinDropVisual animates falling coin', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CoinDropVisual())),
    );
    expect(find.byType(CoinDropVisual), findsOneWidget);
  });

  testWidgets('BottomNavBubbleJump animates active item bounce', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BottomNavBubbleJump(icon: Icons.home_rounded, isSelected: true))),
    );
    expect(find.byType(BottomNavBubbleJump), findsOneWidget);
  });

  testWidgets('ConfettiCelebration renders canvas particle overlay', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ConfettiCelebration())),
    );
    expect(find.byType(ConfettiCelebration), findsOneWidget);
  });
}
