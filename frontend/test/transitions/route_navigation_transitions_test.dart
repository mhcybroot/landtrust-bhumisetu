import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/route_navigation_transitions.dart';

void main() {
  testWidgets('SharedAxisSlideRoute pushes page with slide', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, SharedAxisSlideRoute(page: const Text('Target Page 1'))),
          child: const Text('Go 1'),
        );
      }),
    ));
    await tester.tap(find.text('Go 1'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 1'), findsOneWidget);
  });

  testWidgets('CircularClipRevealRoute pushes page with clip reveal', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, CircularClipRevealRoute(page: const Text('Target Page 2'))),
          child: const Text('Go 2'),
        );
      }),
    ));
    await tester.tap(find.text('Go 2'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 2'), findsOneWidget);
  });

  testWidgets('ZoomFadeRoute pushes page with scale fade', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, ZoomFadeRoute(page: const Text('Target Page 3'))),
          child: const Text('Go 3'),
        );
      }),
    ));
    await tester.tap(find.text('Go 3'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 3'), findsOneWidget);
  });

  testWidgets('ParallaxBackRoute pushes page with parallax', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, ParallaxBackRoute(page: const Text('Target Page 4'))),
          child: const Text('Go 4'),
        );
      }),
    ));
    await tester.tap(find.text('Go 4'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 4'), findsOneWidget);
  });

  testWidgets('HorizontalCubeRotateRoute pushes page with cube rotation', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, HorizontalCubeRotateRoute(page: const Text('Target Page 5'))),
          child: const Text('Go 5'),
        );
      }),
    ));
    await tester.tap(find.text('Go 5'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 5'), findsOneWidget);
  });

  testWidgets('VerticalCurtainSlideRoute pushes page with curtain slide', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, VerticalCurtainSlideRoute(page: const Text('Target Page 6'))),
          child: const Text('Go 6'),
        );
      }),
    ));
    await tester.tap(find.text('Go 6'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 6'), findsOneWidget);
  });

  testWidgets('StaggeredSplitSlideRoute pushes page with split slide', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, StaggeredSplitSlideRoute(page: const Text('Target Page 7'))),
          child: const Text('Go 7'),
        );
      }),
    ));
    await tester.tap(find.text('Go 7'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 7'), findsOneWidget);
  });

  testWidgets('DiagonalWipeRoute pushes page with diagonal wipe', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, DiagonalWipeRoute(page: const Text('Target Page 8'))),
          child: const Text('Go 8'),
        );
      }),
    ));
    await tester.tap(find.text('Go 8'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 8'), findsOneWidget);
  });

  testWidgets('FadeThroughRoute pushes page with fade through', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, FadeThroughRoute(page: const Text('Target Page 9'))),
          child: const Text('Go 9'),
        );
      }),
    ));
    await tester.tap(find.text('Go 9'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 9'), findsOneWidget);
  });

  testWidgets('ElasticPopBackRoute pushes page with elastic pop', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => Navigator.push(context, ElasticPopBackRoute(page: const Text('Target Page 10'))),
          child: const Text('Go 10'),
        );
      }),
    ));
    await tester.tap(find.text('Go 10'));
    await tester.pumpAndSettle();
    expect(find.text('Target Page 10'), findsOneWidget);
  });
}
