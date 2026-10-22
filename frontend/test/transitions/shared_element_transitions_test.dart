import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/shared_element_transitions.dart';

void main() {
  testWidgets('PropertyCardToDetailMorph toggles expanded state', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PropertyCardToDetailMorph(isExpanded: false, collapsed: Text('Card View'), expanded: Text('Detail View'))),
    ));
    expect(find.text('Card View'), findsOneWidget);
  });

  testWidgets('FloatingSearchToHeaderMorph renders search pill', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: FloatingSearchToHeaderMorph(isExpanded: false, searchBar: Text('Search Pill'), headerBar: Text('Sticky Header'))),
    ));
    expect(find.text('Search Pill'), findsOneWidget);
  });

  testWidgets('MapPlotToFullscreenHero renders plot hero', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MapPlotToFullscreenHero(isExpanded: false, miniPlot: Text('Mini Plot'), fullscreenPlot: Text('Full Map'))),
    ));
    expect(find.text('Mini Plot'), findsOneWidget);
  });

  testWidgets('AvatarToProfileBadgeMorph renders avatar morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AvatarToProfileBadgeMorph(isExpanded: false, avatar: Text('Avatar'), badge: Text('Badge'))),
    ));
    expect(find.text('Avatar'), findsOneWidget);
  });

  testWidgets('ThumbnailGridToLightboxMorph renders thumbnail morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ThumbnailGridToLightboxMorph(isExpanded: false, thumbnail: Text('Thumb'), lightbox: Text('Lightbox'))),
    ));
    expect(find.text('Thumb'), findsOneWidget);
  });

  testWidgets('FabToSheetMorph renders FAB morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: FabToSheetMorph(isExpanded: false, fab: Text('FAB'), sheet: Text('Sheet'))),
    ));
    expect(find.text('FAB'), findsOneWidget);
  });

  testWidgets('KhatiyanTileToDeedViewerMorph renders tile morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: KhatiyanTileToDeedViewerMorph(isExpanded: false, tile: Text('Khatiyan Tile'), viewer: Text('Deed Viewer'))),
    ));
    expect(find.text('Khatiyan Tile'), findsOneWidget);
  });

  testWidgets('BadgeLevelUpMorph renders level badge morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: BadgeLevelUpMorph(isLevelUp: false, initialBadge: Text('Silver'), upgradedBadge: Text('Gold'))),
    ));
    expect(find.text('Silver'), findsOneWidget);
  });

  testWidgets('PriceTagToEscrowHero renders price tag hero', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PriceTagToEscrowHero(isEscrowActive: false, priceTag: Text('৳ ৫০ লাখ'), escrowField: Text('Escrow Vault'))),
    ));
    expect(find.text('৳ ৫০ লাখ'), findsOneWidget);
  });

  testWidgets('PlotMarkerToBottomPreviewMorph renders marker morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PlotMarkerToBottomPreviewMorph(isSelected: false, marker: Text('Pin'), preview: Text('Card'))),
    ));
    expect(find.text('Pin'), findsOneWidget);
  });
}
