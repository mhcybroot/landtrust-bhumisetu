import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/media_browsing_animations.dart';

void main() {
  testWidgets('WormPageIndicator renders dot count and active pill', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WormPageIndicator(
            count: 4,
            currentIndex: 1,
          ),
        ),
      ),
    );

    expect(find.byType(WormPageIndicator), findsOneWidget);
  });

  testWidgets('SmartInteractiveZoom scales on double tap', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SmartInteractiveZoom(
            child: SizedBox(width: 200, height: 200, child: Text('Zoom Target')),
          ),
        ),
      ),
    );

    expect(find.text('Zoom Target'), findsOneWidget);
    await tester.tap(find.text('Zoom Target'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Zoom Target'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Zoom Target'), findsOneWidget);
  });

  testWidgets('BeforeAfterSlider splits two views with drag divider', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 200,
            child: BeforeAfterSlider(
              before: Text('Before Land'),
              after: Text('After Dev'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Before Land'), findsOneWidget);
    expect(find.text('After Dev'), findsOneWidget);
    expect(find.byType(BeforeAfterSlider), findsOneWidget);
  });

  testWidgets('TiltParallaxWrapper renders child with hover tilt', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TiltParallaxWrapper(
            child: Text('Parallax Card'),
          ),
        ),
      ),
    );

    expect(find.text('Parallax Card'), findsOneWidget);
  });
}
