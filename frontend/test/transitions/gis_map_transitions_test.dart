import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/gis_map_transitions.dart';

void main() {
  testWidgets('Map2dTo3dCameraTilt renders tilted child', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Map2dTo3dCameraTilt(is3d: true, child: Text('Map Canvas')))));
    expect(find.text('Map Canvas'), findsOneWidget);
  });

  testWidgets('MouzaOverlayCrossfade renders mouza layer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MouzaOverlayCrossfade(opacity: 0.7, child: Text('Mouza Layer')))));
    expect(find.text('Mouza Layer'), findsOneWidget);
  });

  testWidgets('PlotBoundaryCenterZoom renders plot perimeter', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PlotBoundaryCenterZoom(isFocused: true, child: Text('Plot Area')))));
    expect(find.text('Plot Area'), findsOneWidget);
  });

  testWidgets('MarkerClusterSplitTransition renders cluster pins', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MarkerClusterSplitTransition(isSplit: true))));
    expect(find.byType(MarkerClusterSplitTransition), findsOneWidget);
  });

  testWidgets('DrawingCursorToPenMorph renders stylus tool', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DrawingCursorToPenMorph(isDrawing: true))));
    expect(find.byType(DrawingCursorToPenMorph), findsOneWidget);
  });

  testWidgets('RoadToPlotFlipTransition renders parcel perspective', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RoadToPlotFlipTransition(isPlotView: true))));
    expect(find.byType(RoadToPlotFlipTransition), findsOneWidget);
  });

  testWidgets('CompassNorthHeadingAlign renders compass needle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CompassNorthHeadingAlign(heading: 45))));
    expect(find.byType(CompassNorthHeadingAlign), findsOneWidget);
  });

  testWidgets('FloodZoneWaterRiseTransition renders flood layer', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FloodZoneWaterRiseTransition(waterLevel: 0.5))));
    expect(find.byType(FloodZoneWaterRiseTransition), findsOneWidget);
  });

  testWidgets('LandmarkRadarPinDrop renders dropped landmark', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LandmarkRadarPinDrop(icon: Icons.local_hospital))));
    expect(find.byType(LandmarkRadarPinDrop), findsOneWidget);
  });

  testWidgets('SplitMapListPanelSlide renders split panel', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SplitMapListPanelSlide(splitRatio: 0.6, leftChild: Text('Left Map'), rightChild: Text('Right List')))));
    expect(find.text('Left Map'), findsOneWidget);
    expect(find.text('Right List'), findsOneWidget);
  });
}
