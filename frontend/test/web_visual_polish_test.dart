import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/hover_lift_card.dart';
import 'package:landtrust_app/core/animations/staggered_slide_fade.dart';
import 'package:landtrust_app/core/widgets/shimmer_card_placeholder.dart';
import 'package:landtrust_app/modules/marketplace/view_models/marketplace_view_model.dart';
import 'package:landtrust_app/modules/marketplace/views/web/home_marketplace_web_view.dart';
import 'package:landtrust_app/modules/marketplace/widgets/property_card_widget.dart';

class MockMarketplaceViewModel extends MarketplaceViewModel {
  final bool mockLoading;
  final List<dynamic> mockListings;
  final Map<String, dynamic> mockConfig;

  MockMarketplaceViewModel({
    this.mockLoading = false,
    this.mockListings = const [],
    this.mockConfig = const {},
  });

  @override
  bool get isLoading => mockLoading;

  @override
  List<dynamic> get listings => mockListings;

  @override
  Map<String, dynamic> get config => mockConfig;
}

void main() {
  const dummyListing = {
    'id': 101,
    'title': 'পূর্বাচল আবাসিক প্লট',
    'areaName': 'সেক্টর ৪',
    'upazila': 'রূপগঞ্জ',
    'district': 'নারায়ণগঞ্জ',
    'landType': 'আবাসিক',
    'areaDecimal': '7.5',
    'expectedPriceBdt': '75,00,000',
    'pricePerDecimalBdt': '10,00,000',
    'verificationStatus': 'VERIFIED',
    'imageUrl': null,
    'sellerPhone': '01711112233',
  };

  group('PropertyCardWidget HoverLiftCard Integration Tests', () {
    testWidgets('wraps card in HoverLiftCard and handles hover and taps', (tester) async {
      var detailsClicked = false;
      var inquiryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: PropertyCardWidget(
                  listing: dummyListing,
                  isMobile: false,
                  onDetailsClick: () => detailsClicked = true,
                  onInquiryClick: () => inquiryClicked = true,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(HoverLiftCard), findsOneWidget);
      expect(find.text('পূর্বাচল আবাসিক প্লট'), findsOneWidget);

      // Verify hover reaction
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(HoverLiftCard)));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Tap on Details button
      final detailsBtn = find.widgetWithText(OutlinedButton, 'বিস্তারিত');
      expect(detailsBtn, findsOneWidget);
      await tester.tap(detailsBtn);
      expect(detailsClicked, isTrue);

      // Tap on Inquiry button
      final inquiryBtn = find.widgetWithText(ElevatedButton, 'যোগাযোগ');
      expect(inquiryBtn, findsOneWidget);
      await tester.tap(inquiryBtn);
      expect(inquiryClicked, isTrue);

      // Tap on card body
      detailsClicked = false;
      await tester.tap(find.text('পূর্বাচল আবাসিক প্লট'));
      expect(detailsClicked, isTrue);

      // Exit hover
      await gesture.moveTo(const Offset(1200, 1200));
      await tester.pumpAndSettle();
    });
  });

  group('HomeMarketplaceWebView Visual Polish Tests', () {
    testWidgets('renders 6 ShimmerCardPlaceholder widgets when isLoading is true', (tester) async {
      final mockVm = MockMarketplaceViewModel(
        mockLoading: true,
        mockListings: const [],
        mockConfig: const {
          'settings': {'heroTitle': 'টেস্ট শিরোনাম'},
          'locations': [],
        },
      );

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeMarketplaceWebView(
              viewModel: mockVm,
              onNavigateToAuth: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(ShimmerCardPlaceholder), findsNWidgets(6));
      expect(find.byType(PropertyCardWidget), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders listings wrapped in StaggeredSlideFade when loaded', (tester) async {
      final mockVm = MockMarketplaceViewModel(
        mockLoading: false,
        mockListings: const [dummyListing, dummyListing],
        mockConfig: const {
          'settings': {'heroTitle': 'টেস্ট শিরোনাম'},
          'locations': [],
        },
      );

      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeMarketplaceWebView(
              viewModel: mockVm,
              onNavigateToAuth: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ShimmerCardPlaceholder), findsNothing);
      expect(find.byType(PropertyCardWidget), findsNWidgets(2));
      expect(find.byType(StaggeredSlideFade), findsNWidgets(2));
    });
  });
}
