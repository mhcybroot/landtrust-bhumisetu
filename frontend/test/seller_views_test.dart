import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/member_portal/widgets/listing_form_dialog.dart';
import 'package:landtrust_app/modules/member_portal/widgets/listing_payment_section.dart';
import 'package:landtrust_app/modules/member_portal/widgets/private_document_preview_dialog.dart';
import 'package:landtrust_app/modules/member_portal/widgets/seller_workspace_view.dart';

void main() {
  testWidgets('Test ListingFormDialog submit tap is executed and not swallowed', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool submitted = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => ListingFormDialog.show(
              ctx,
              isMobile: true,
              districts: ['নোয়াখালী', 'কুমিল্লা'],
              getUpazilas: (d) => ['নোয়াখালী সদর', 'বেগমগঞ্জ'],
              paymentMethods: [{'providerName': 'বিকাশ (bKash)', 'accountNumber': '01700000000'}],
              onSubmit: (p) async { submitted = true; },
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('নতুন জমি / ফ্ল্যাটের বিজ্ঞাপন জমা দিন'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'বিজ্ঞাপনের শিরোনাম *'), '৫ শতক জমি বিক্রয়');
    await tester.enterText(find.widgetWithText(TextField, 'পরিমাণ (শতাংশ বা স্কয়ার ফিট) *'), '5');
    await tester.enterText(find.widgetWithText(TextField, 'প্রত্যাশিত মোট মূল্য (৳) *'), '1500000');
    await tester.enterText(find.widgetWithText(TextField, 'প্রেরক মোবাইল নম্বর *'), '01711223344');
    await tester.enterText(find.widgetWithText(TextField, 'ট্রানজেকশন আইডি (TrxID) *'), 'TRX123456');

    final submitFinder = find.widgetWithText(ElevatedButton, 'জমা দিন');
    expect(submitFinder, findsOneWidget);

    await tester.tap(submitFinder);
    await tester.pumpAndSettle();

    expect(submitted, isTrue);
  });

  testWidgets('Test SellerWorkspaceView renders on 320px viewport without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final listings = [
      {
        'id': 1,
        'title': 'মাইজদীতে ১০ শতক আবাসিক প্লট',
        'landType': 'আবাসিক',
        'listingStatus': 'APPROVED_PUBLISHED',
        'isFeatured': true,
        'areaName': 'মাইজদী বাজার',
        'upazila': 'নোয়াখালী সদর',
        'district': 'নোয়াখালী',
        'mouzaName': 'মাইজদী',
        'areaDecimal': 10.0,
        'expectedPriceBdt': 2500000.0,
        'privateDocumentUrl': 'https://example.com/doc.pdf',
      }
    ];

    bool addListingClicked = false;
    bool editClicked = false;
    bool previewDocClicked = false;
    bool markSoldClicked = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SellerWorkspaceView(
            myListings: listings,
            isMobile: true,
            onAddListing: () => addListingClicked = true,
            onAddProposal: () {},
            onEditListing: (l) => editClicked = true,
            onPreviewDoc: (l) => previewDocClicked = true,
            onMarkSold: (id) => markSoldClicked = true,
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('আমার জমির বিজ্ঞাপন (1)'), findsOneWidget);

    await tester.ensureVisible(find.text('নতুন বিজ্ঞাপন জমা দিন'));
    await tester.tap(find.text('নতুন বিজ্ঞাপন জমা দিন'));
    await tester.pump();
    expect(addListingClicked, isTrue);

    await tester.ensureVisible(find.text('সম্পাদনা (Edit)'));
    await tester.tap(find.text('সম্পাদনা (Edit)'));
    await tester.pump();
    expect(editClicked, isTrue);

    await tester.ensureVisible(find.text('সংযুক্ত দলিল দেখুন'));
    await tester.tap(find.text('সংযুক্ত দলিল দেখুন'));
    await tester.pump();
    expect(previewDocClicked, isTrue);

    await tester.ensureVisible(find.text('বিক্রি সম্পন্ন (SOLD)'));
    await tester.tap(find.text('বিক্রি সম্পন্ন (SOLD)'));
    await tester.pump();
    expect(markSoldClicked, isTrue);
  });

  testWidgets('Test ListingPaymentSection renders on 320px screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final phoneCtrl = TextEditingController(text: '01711223344');
    final trxCtrl = TextEditingController(text: 'TX998877');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ListingPaymentSection(
            feeAmount: 1500,
            isFeatured: false,
            onFeaturedChanged: (_) {},
            paymentMethods: [
              {'providerName': 'ইসলামী ব্যাংক বাংলাদেশ (Islami Bank)', 'accountNumber': '20501234567890'}
            ],
            selectedMethod: 'ইসলামী ব্যাংক বাংলাদেশ (Islami Bank)',
            onMethodChanged: (_) {},
            senderPhoneCtrl: phoneCtrl,
            trxIdCtrl: trxCtrl,
            isMobile: true,
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Test PrivateDocumentPreviewDialog opens on 320x480 viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final listing = {'id': 1, 'title': 'মাইজদী প্লট', 'privateDocumentUrl': 'https://example.com/doc.png'};

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => PrivateDocumentPreviewDialog.show(ctx, listing: listing, isMobile: true),
            child: const Text('Preview'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Preview'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('সংযুক্ত খতিয়ান / দলিলের কপি'), findsOneWidget);
    await tester.tap(find.text('বন্ধ করুন'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('সংযুক্ত খতিয়ান / দলিলের কপি'), findsNothing);
  });
}
