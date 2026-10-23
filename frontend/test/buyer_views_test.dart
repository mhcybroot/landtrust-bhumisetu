import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/marketplace/widgets/contact_inquiry_dialog.dart';
import 'package:landtrust_app/modules/marketplace/widgets/seller_offer_dialog.dart';
import 'package:landtrust_app/modules/member_portal/widgets/buyer_workspace_view.dart';
import 'package:landtrust_app/modules/member_portal/widgets/requirement_form_dialog.dart';

void main() {
  testWidgets('Test RequirementFormDialog submit tap is executed and not swallowed', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool submitted = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => RequirementFormDialog.show(
              ctx,
              isMobile: true,
              districts: ['নোয়াখালী', 'কুমিল্লা'],
              getUpazilas: (d) => ['নোয়াখালী সদর', 'বেগমগঞ্জ'],
              onSubmit: (p) async { submitted = true; },
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('নতুন জমি / ফ্ল্যাট ক্রয়ের চাহিদা নিবন্ধন'), findsOneWidget);
    final submitFinder = find.widgetWithText(ElevatedButton, 'নিবন্ধন করুন');
    expect(submitFinder, findsOneWidget);

    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
  });

  testWidgets('Test ContactInquiryDialog opens and submits on mobile 360x640', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool submitted = false;
    final listing = {'id': 101, 'title': 'নোয়াখালী মাইজদীতে ৫ শতক জমি', 'expectedPriceBdt': 1500000};
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => ContactInquiryDialog.show(
              ctx,
              listing: listing,
              onSubmit: (b, m) async { submitted = true; },
            ),
            child: const Text('Inquire'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Inquire'));
    await tester.pumpAndSettle();

    expect(find.textContaining('আগ্রহ প্রকাশ:'), findsOneWidget);
    await tester.tap(find.text('অনুরোধ পাঠান'));
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
  });

  testWidgets('Test SellerOfferDialog renders without overflow on 320x480 viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool submitted = false;
    final req = {'id': 55, 'buyerName': 'আনোয়ার হোসেন', 'preferredUpazila': 'নোয়াখালী সদর', 'landType': 'আবাসিক', 'minBudgetBdt': 1000000, 'maxBudgetBdt': 2500000};
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => SellerOfferDialog.show(
              ctx,
              requirement: req,
              onSubmit: (d, p, f) async { submitted = true; },
            ),
            child: const Text('Offer'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Offer'));
    await tester.pumpAndSettle();

    expect(find.textContaining('জমির প্রস্তাব'), findsOneWidget);
    await tester.tap(find.text('প্রস্তাব পাঠান'));
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
  });

  testWidgets('Test BuyerWorkspaceView renders on 320px viewport without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final reqs = [
      {
        'id': 1,
        'landType': 'ফ্ল্যাট / বাণিজ্যিক স্পেস',
        'status': 'SUBMITTED',
        'preferredArea': 'মাইজদী বাজার',
        'preferredUpazila': 'নোয়াখালী সদর',
        'preferredDistrict': 'নোয়াখালী',
        'minAreaDecimal': 5.0,
        'maxAreaDecimal': 10.0,
        'minBudgetBdt': 1500000.0,
        'maxBudgetBdt': 3500000.0,
        'purpose': 'বাণিজ্যিক ভবন',
        'purchaseTimeline': 'জরুরি (৭ দিনের মধ্যে)',
      }
    ];
    final inqs = [
      {
        'id': 10,
        'listingTitle': 'নোয়াখালী মাইজদীতে ৫ শতক বাণিজ্যিক ভিটা জমি',
        'offeredBudgetBdt': 2000000.0,
        'message': 'কাগজপত্র সঠিক থাকলে দ্রুত ক্রয় করতে চাই।',
        'status': 'PENDING',
      }
    ];

    bool addReqClicked = false;
    bool editClicked = false;
    bool fulfillClicked = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BuyerWorkspaceView(
            myRequirements: reqs,
            myInquiries: inqs,
            isMobile: true,
            onAddRequirement: () => addReqClicked = true,
            onAddProposal: () {},
            onEditRequirement: (r) => editClicked = true,
            onFulfillRequirement: (id) => fulfillClicked = true,
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('আমার জমি কেনার চাহিদা (1)'), findsOneWidget);

    await tester.tap(find.text('নতুন চাহিদা দিন'));
    await tester.pump();
    expect(addReqClicked, isTrue);

    await tester.tap(find.text('সম্পাদনা (Edit)'));
    await tester.pump();
    expect(editClicked, isTrue);

    await tester.tap(find.text('চাহিদা পূরণ হয়েছে'));
    await tester.pump();
    expect(fulfillClicked, isTrue);
  });
}
