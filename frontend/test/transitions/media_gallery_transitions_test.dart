import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/media_gallery_transitions.dart';

void main() {
  testWidgets('ThumbnailToLightboxMorph renders expanded child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ThumbnailToLightboxMorph(isExpanded: true, collapsedChild: Text('Thumb'), expandedChild: Text('Lightbox')))));
    expect(find.text('Lightbox'), findsOneWidget);
  });

  testWidgets('Panorama360SpinTransition renders rotating child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Panorama360SpinTransition(angle: 1.0, child: Text('360 Sphere')))));
    expect(find.text('360 Sphere'), findsOneWidget);
  });

  testWidgets('FilmstripSlideCrossfade renders current filmstrip photo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FilmstripSlideCrossfade(index: 1, child: Text('Photo 1')))));
    expect(find.text('Photo 1'), findsOneWidget);
  });

  testWidgets('VideoPlayPulseOverlay renders video player', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: VideoPlayPulseOverlay(isPlaying: true, child: Text('Player View')))));
    expect(find.text('Player View'), findsOneWidget);
  });

  testWidgets('BlueprintFloorPlanCrossfade renders active plan', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BlueprintFloorPlanCrossfade(showBlueprint: true, floorPlan: Text('Floor'), blueprint: Text('Blueprint')))));
    expect(find.text('Blueprint'), findsOneWidget);
  });

  testWidgets('DroneAerialZoomReveal renders aerial viewport', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DroneAerialZoomReveal(isZoomed: true, child: Text('Drone Shot')))));
    expect(find.text('Drone Shot'), findsOneWidget);
  });

  testWidgets('ImageWatermarkSheenSwipe renders sheened image', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ImageWatermarkSheenSwipe(child: Text('Watermarked Image')))));
    expect(find.text('Watermarked Image'), findsOneWidget);
  });

  testWidgets('BeforeAfterCurtainWipe renders dual images', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BeforeAfterCurtainWipe(splitRatio: 0.5, beforeChild: Text('Before'), afterChild: Text('After')))));
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
  });

  testWidgets('AudioWaveformBarExpand renders audio track', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AudioWaveformBarExpand(isExpanded: true, child: Text('Audio Note')))));
    expect(find.text('Audio Note'), findsOneWidget);
  });

  testWidgets('DocumentPdfPageTurnTransition renders page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DocumentPdfPageTurnTransition(isFlipped: true, front: Text('Page 1'), back: Text('Page 2')))));
    expect(find.text('Page 2'), findsOneWidget);
  });
}
