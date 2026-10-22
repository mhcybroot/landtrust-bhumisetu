import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/animated_count_text.dart';
import 'package:landtrust_app/core/animations/hover_lift_card.dart';
import 'package:landtrust_app/core/animations/shimmer_effect.dart';
import 'package:landtrust_app/core/widgets/frosted_glass_container.dart';
import 'package:landtrust_app/core/widgets/smart_image_viewer.dart';

void main() {
  group('AnimatedCountText Widget Tests', () {
    testWidgets('animates count-up and preserves suffix for "45 টি"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCountText(
              text: '45 টি',
              duration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );

      expect(find.text('0 টি'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('45 টি'), findsOneWidget);
    });

    testWidgets('formats South Asian comma currency for "৳ 1,50,000"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCountText(
              text: '৳ 1,50,000',
              duration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );

      expect(find.text('৳ 0'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('৳ 1,50,000'), findsOneWidget);
    });

    testWidgets('animates and renders suffix for "14 জন"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCountText(
              text: '14 জন',
              duration: Duration(milliseconds: 300),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('14 জন'), findsOneWidget);
    });

    testWidgets('renders non-numeric string gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCountText(text: 'N/A'),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('N/A'), findsOneWidget);
    });
  });

  group('HoverLiftCard Widget Tests', () {
    testWidgets('renders child and responds to hover state and tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoverLiftCard(
                onTap: () => tapped = true,
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Card Content'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);

      // Simulate mouse hover
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(HoverLiftCard)));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Tap card
      await tester.tap(find.byType(HoverLiftCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);

      // Hover out
      await gesture.moveTo(const Offset(800, 800));
      await tester.pumpAndSettle();
    });
  });

  group('FrostedGlassContainer Widget Tests', () {
    testWidgets('renders child with BackdropFilter and blur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FrostedGlassContainer(
              blur: 12.0,
              child: Text('Frosted Content'),
            ),
          ),
        ),
      );

      expect(find.text('Frosted Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);

      final filterWidget = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(filterWidget.filter.toString(), contains('blur'));
    });
  });

  group('SmartImageViewer Widget Tests', () {
    testWidgets('renders fallback when url is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SmartImageViewer(url: null))),
      );
      expect(find.byIcon(Icons.landscape_rounded), findsOneWidget);
    });

    testWidgets('renders memory image when url is base64 data URI', (tester) async {
      const base64Png =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SmartImageViewer(url: base64Png))),
      );
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.landscape_rounded), findsNothing);
    });

    testWidgets('configures network shimmer placeholder and fade entrance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SmartImageViewer(url: 'https://example.com/land.jpg', height: 100, width: 100),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final image = tester.widget<Image>(imageFinder);
      expect(image.loadingBuilder, isNotNull);
      expect(image.frameBuilder, isNotNull);

      final context = tester.element(imageFinder);
      final loadingWidget = image.loadingBuilder!(
        context,
        const SizedBox(),
        const ImageChunkEvent(cumulativeBytesLoaded: 10, expectedTotalBytes: 100),
      );
      expect(loadingWidget, isA<ShimmerEffect>());

      const dummy = SizedBox(key: ValueKey('child'));
      expect(image.loadingBuilder!(context, dummy, null), equals(dummy));

      final frameWidget = image.frameBuilder!(context, dummy, 1, false) as AnimatedOpacity;
      expect(frameWidget.opacity, 1.0);
      expect(frameWidget.duration, const Duration(milliseconds: 280));
    });
  });
}
