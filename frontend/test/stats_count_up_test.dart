import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/animated_count_text.dart';
import 'package:landtrust_app/core/widgets/status_badge.dart';

void main() {
  group('StatCardWidget AnimatedCountText Integration Tests', () {
    testWidgets('renders AnimatedCountText with "45 টি" and counts up', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'অনুমোদিত বিজ্ঞাপন',
              value: '45 টি',
              subtitle: 'যাচাইকৃত জমির তালিকা',
              color: Color(0xFF0B4F32),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedCountText), findsOneWidget);
      expect(find.text('অনুমোদিত বিজ্ঞাপন'), findsOneWidget);
      expect(find.text('যাচাইকৃত জমির তালিকা'), findsOneWidget);
      expect(find.text('0 টি'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('45 টি'), findsOneWidget);
    });

    testWidgets('formats and displays currency "৳ 1,50,000"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'মোট কমিশন',
              value: '৳ 1,50,000',
              subtitle: 'সর্বমোট পাওনা',
              color: Color(0xFF1A237E),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedCountText), findsOneWidget);
      expect(find.text('৳ 0'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('৳ 1,50,000'), findsOneWidget);
    });

    testWidgets('renders suffix for "14 জন"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'মার্কেটিং অফিসার',
              value: '14 জন',
              subtitle: 'মাঠ পর্যায়ের প্রতিনিধি',
              color: Color(0xFF1B5E20),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedCountText), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('14 জন'), findsOneWidget);
    });

    testWidgets('handles non-numeric strings gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCardWidget(
              title: 'তথ্য',
              value: 'N/A',
              subtitle: 'উপলব্ধ নয়',
              color: Colors.grey,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedCountText), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('N/A'), findsOneWidget);
    });
  });
}
