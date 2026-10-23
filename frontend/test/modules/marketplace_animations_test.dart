import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/finance_payment_transitions.dart';
import 'package:landtrust_app/modules/marketplace/widgets/marketplace_pagination_bar.dart';
import 'package:landtrust_app/modules/marketplace/widgets/safety_warning_card.dart';

void main() {
  testWidgets('MarketplacePaginationBar renders page indicators', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MarketplacePaginationBar(totalItems: 45, itemsPerPage: 12, currentPage: 1, onPageChanged: (_) {}),
      ),
    ));
    expect(find.byType(MarketplacePaginationBar), findsOneWidget);
  });

  testWidgets('SafetyWarningCard animates with shield lock snap', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SafetyWarningCard(isMobile: false))));
    expect(find.text('জরুরি জনসচেতনতামূলক সতর্কবার্তা ও লেনদেন নীতি'), findsOneWidget);
    expect(find.byType(SecurityShieldLockSnap), findsOneWidget);
  });
}
