import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/gis_plot_animations.dart';

void main() {
  testWidgets('PlotBoundaryTracer renders canvas tracer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PlotBoundaryTracer())));
    expect(find.byType(PlotBoundaryTracer), findsOneWidget);
  });

  testWidgets('RoadWidthTape renders width label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RoadWidthTape(widthFeet: 24))));
    expect(find.textContaining('২৪ ফুট'), findsOneWidget);
  });

  testWidgets('CompassNorthLock renders compass needle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CompassNorthLock(headingDegrees: 45))));
    expect(find.byType(CompassNorthLock), findsOneWidget);
  });

  testWidgets('GpsPinDropBounce renders dropping pin', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GpsPinDropBounce())));
    expect(find.byType(GpsPinDropBounce), findsOneWidget);
  });

  testWidgets('LandmarkRadarWave renders radar wave', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LandmarkRadarWave(icon: Icons.school))));
    expect(find.byType(LandmarkRadarWave), findsOneWidget);
  });

  testWidgets('MouzaSheetOverlay renders overlay with opacity', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MouzaSheetOverlay(opacity: 0.8, child: Text('মৌজা নকশা')))));
    expect(find.text('মৌজা নকশা'), findsOneWidget);
  });

  testWidgets('ElevationProfileBar renders height label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ElevationProfileBar(heightFeet: 6.5))));
    expect(find.textContaining('৬.৫ ফুট'), findsOneWidget);
  });

  testWidgets('FloodLevelWave renders wave simulation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FloodLevelWave(waterLevelPercent: 0.4))));
    expect(find.byType(FloodLevelWave), findsOneWidget);
  });

  testWidgets('SunShadowSweep renders sun angle simulation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SunShadowSweep(timeOfDayHour: 14))));
    expect(find.byType(SunShadowSweep), findsOneWidget);
  });

  testWidgets('CornerPillarFlip renders pillar indicator', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CornerPillarFlip(pillarLabel: 'P-1'))));
    expect(find.text('P-1'), findsOneWidget);
  });
}
