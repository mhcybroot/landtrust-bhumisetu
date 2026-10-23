import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/member_portal/widgets/marketing_officer_view.dart';
import 'package:landtrust_app/modules/member_portal/widgets/payout_and_resubmit_dialogs.dart';
import 'package:landtrust_app/modules/member_portal/widgets/digital_id_card_dialog.dart';
import 'package:landtrust_app/modules/member_portal/widgets/member_header_banner.dart';

void main() {
  testWidgets('MarketingOfficerView renders stats and triggers payout on 320x480 viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool payoutTriggered = false;
    final officerData = {
      'referralCode': 'LT-AG-007',
      'totalReferredCount': 12,
      'verifiedReferredCount': 8,
      'totalEarnedCommission': 15000,
      'pendingPayableCommission': 4500,
      'referredUsers': [
        {'fullName': 'রহিম মিয়া', 'role': 'BUYER', 'upazila': 'নোয়াখালী সদর', 'district': 'নোয়াখালী', 'accountStatus': 'ACTIVE'}
      ],
      'commissions': [
        {'commissionType': 'LISTING', 'referredUserName': 'রহিম মিয়া', 'commissionAmountBdt': 500, 'status': 'PAID', 'note': 'লিস্টিং বোনাস'}
      ],
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MarketingOfficerView(
            officerData: officerData,
            isMobile: true,
            onPayoutRequest: () => payoutTriggered = true,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('আপনার ইউনিক রেফারেল কোড ও লিংক'), findsOneWidget);
    expect(find.text('মোট রেফারেল'), findsOneWidget);

    await tester.ensureVisible(find.text('উইথড্র রিকোয়েস্ট'));
    await tester.pumpAndSettle();
    expect(find.text('উইথড্র রিকোয়েস্ট'), findsOneWidget);

    await tester.tap(find.text('উইথড্র রিকোয়েস্ট'));
    await tester.pump();
    expect(payoutTriggered, isTrue);
  });

  testWidgets('OfficerPayoutDialog submits withdrawal without click swallowing', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    double? submittedAmount;
    String? submittedMethod;
    String? submittedAccount;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => OfficerPayoutDialog.show(
              ctx,
              pendingPayable: 5000,
              isMobile: true,
              onSubmit: (amt, mth, acc) async {
                submittedAmount = amt;
                submittedMethod = mth;
                submittedAccount = acc;
              },
            ),
            child: const Text('Open Payout'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open Payout'));
    await tester.pumpAndSettle();

    expect(find.text('কমিশন উইথড্র রিকোয়েস্ট'), findsOneWidget);
    expect(find.text('অনুরোধ পাঠান'), findsOneWidget);

    // Enter account number
    await tester.enterText(find.widgetWithText(TextField, 'একাউন্ট / মোবাইল নম্বর *'), '01819998877');
    await tester.pump();

    // Tap submit button
    await tester.tap(find.text('অনুরোধ পাঠান'));
    await tester.pumpAndSettle();

    expect(submittedAmount, equals(5000));
    expect(submittedMethod, equals('বিকাশ (bKash)'));
    expect(submittedAccount, equals('01819998877'));
  });

  testWidgets('DigitalIdCardDialog flips front and back cleanly', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final officerData = {
      'officer': {
        'fullName': 'মোঃ আনোয়ার হোসেন',
        'role': 'UPAZILA_AGENT',
        'district': 'নোয়াখালী',
        'upazila': 'বেগমগঞ্জ',
        'myReferralCode': 'LT-AG-BEGUMGANJ',
      },
      'referralCode': 'LT-AG-BEGUMGANJ',
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => DigitalIdCardDialog.show(ctx, officerData: officerData, isMobile: true),
            child: const Text('Open ID'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open ID'));
    await tester.pumpAndSettle();

    expect(find.text('মোঃ আনোয়ার হোসেন'), findsOneWidget);
    expect(find.text('উপজেলা প্রধান এজেন্ট'), findsOneWidget);
    expect(find.text('LT-AG-BEGUMGANJ'), findsOneWidget);

    // Tap to flip
    await tester.tap(find.text('🔄 ট্যাপ করে পেছনের কিউআর ও সিলমোহর দেখুন'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('স্ক্যান করে প্রোফাইল ও রেফারেল নিশ্চিত করুন'), findsOneWidget);
  });

  testWidgets('MemberHeaderBanner correctly recognizes DISTRICT_AGENT and UPAZILA_AGENT roles', (tester) async {
    final districtAgentUser = {
      'fullName': 'কামাল চৌধুরী',
      'role': 'DISTRICT_AGENT',
      'phoneNumber': '01712345678',
      'district': 'নোয়াখালী',
      'upazila': 'সদর',
      'accountStatus': 'ACTIVE',
    };

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MemberHeaderBanner(
            user: districtAgentUser,
            isMobile: true,
            unreadCount: 2,
            onProfileClick: () {},
            onNotificationsClick: () {},
            onRefresh: () {},
            onResubmitPaymentClick: () {},
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('ভূমিকা: জেলা প্রধান প্রতিনিধি'), findsOneWidget);
    expect(find.text('কামাল চৌধুরী'), findsOneWidget);
    expect(find.text('নোটিফিকেশন (2)'), findsOneWidget);
  });
}
