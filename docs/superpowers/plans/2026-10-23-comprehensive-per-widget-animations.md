# Comprehensive Per-Widget Micro-Animations & Tactile Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Approach 2 (Component-by-Component Polish) across all 70 user-facing UI widgets and their interactive child cards in LandApp (bdHousing), wiring tactile micro-interactions (tap spring, hover lift, rolling digit odometer, pulse beacons, checkmark morphs, and state sweeps) using pure native Flutter primitives.

**Architecture:** Each widget and interactive child card directly integrates bespoke native animation primitives (`BouncingPressable`, `HoverLiftCard`, `SubmitButtonLoaderToSuccess`, `PulseBeaconIndicator`, `SheenSweepEffect`, `AnimatedCountText`, and `transition_aliases.dart`) without altering backend contracts or adding third-party packages. Strict file discipline keeps every modified and newly created `.dart` file at $\le 200$ lines.

**Tech Stack:** Flutter 3.33+, Dart 3.5+, pure Flutter framework animations (`AnimatedBuilder`, `TweenAnimationBuilder`, `AnimatedSwitcher`, `Transform`, `ClipRect`, `PathMetric`).

**Spec:** [`docs/superpowers/specs/2026-10-23-comprehensive-per-widget-animations-design.md`](file:///home/mhcybroot/Work/LandApp/docs/superpowers/specs/2026-10-23-comprehensive-per-widget-animations-design.md)

## Global Constraints

- Flutter 3.33+, Dart 3.5+.
- Every `.dart` file strictly capped at $\le 200$ lines.
- Zero new third-party packages added to `pubspec.yaml` (pure native Flutter).
- Zero linter warnings: `flutter analyze --no-fatal-infos` must report 0 issues.
- All existing tests (204 Flutter tests, 9 Spring Boot tests) and newly created widget tests must pass.
- 60fps performance on mobile, no unconstrained battery loops, no blocking sleep timers.

## Review Focus

1. **Active Edit Protection During Animation/Refresh:** Background timer or stream updates must not wipe user keystrokes in animated text fields (`AdminSettingsTab`, `ListingFormDialog`, `RequirementFormDialog`).
2. **Ticker & AnimationController Leaks:** Any `StatefulWidget` or `AnimationController` must dispose properly to prevent ticker leaks during navigation or dialog dismissals.
3. **Continuous Sliver Layout Stability:** `HomeMarketplaceWebView` and `HomeMarketplaceMobileView` continuous scrolling must not be broken or jittered by animated page indicators or staggered cascades.
4. **Line-Budget Overflow:** Highly dense files (>185 lines such as `admin_demands_inquiries_tab.dart`, `listing_form_dialog.dart`, `home_marketplace_mobile_view.dart`, `property_card_widget.dart`) must not exceed 200 lines when animated wrappers are added.
5. **Reduced Motion & Accessibility:** Touch press animations (`BouncingPressable`) and hover elevations must handle rapid taps without double-dispatching callbacks (`onTap` debouncing / idempotency).

---

### Task 1: Core Foundation & Aliases Polish

**Files:**
- Modify: `frontend/lib/core/animations/transitions/transition_aliases.dart:1-40`
- Modify: `frontend/lib/core/animations/transitions/transitions.dart:1-15`
- Create: `frontend/test/transitions/spec_aliases_expansion_test.dart`

**Interfaces:**
- Consumes: `frontend/lib/core/animations/transitions/*.dart`
- Produces: Complete typedef aliases for all spec transitions (`StaggeredSheetItemsSlide`, `FilterPillToFilterPanelMorph`, `CollapsibleFormSectionAccordion`, `CurvedCornerSheetReveal`, `FormStepSlideTransition`, `ReviewSummaryCardFlip`, `SearchFilterTagSlide`, `ActiveTabIndicatorGlide`, `SearchBoxToResultsViewMorph`)

- [ ] **Step 1: Write the failing test for expanded spec aliases**

```dart
// frontend/test/transitions/spec_aliases_expansion_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/transitions.dart';

void main() {
  testWidgets('All spec animation aliases instantiate cleanly', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            StaggeredSheetItemsSlide(index: 0, child: Text('Item')),
            ActiveTabIndicatorGlide(tabIndex: 0, child: Text('Tab')),
            SearchFilterTagSlide(isSelected: true, child: Text('Tag')),
            ReviewSummaryCardFlip(showBack: false, front: Text('F'), back: Text('B')),
          ],
        ),
      ),
    ));
    expect(find.text('Item'), findsOneWidget);
    expect(find.text('Tab'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && flutter test test/transitions/spec_aliases_expansion_test.dart`  
Expected: FAIL with undefined class/typedef errors.

- [ ] **Step 3: Implement missing aliases in `transition_aliases.dart`**

Add canonical typedef aliases mapping spec names to modular implementations:
- `StaggeredSheetItemsSlide = SmoothSheetDragSnapper`
- `ActiveTabIndicatorGlide = TabContentSlideWipe`
- `SearchFilterTagSlide = AnimatedStatusPill`
- `FilterPillToFilterPanelMorph = FilterPillToFilterPanelMorph`
- `CollapsibleFormSectionAccordion = AccordionShelfExpandTransition`
- `SearchBoxToResultsViewMorph = FloatingSearchToHeaderMorph`
- `CurvedCornerSheetReveal = CurvedEdgePullTransition`
- `FormStepSlideTransition = StepSlideFadeTransition`
- `ReviewSummaryCardFlip = BankCardFlipCvvTransition`

Keep `transition_aliases.dart` strictly $\le 200$ lines.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/transitions/spec_aliases_expansion_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/core/animations/transitions/ frontend/test/transitions/spec_aliases_expansion_test.dart
git commit -m "feat(animations): expand transition aliases for complete spec parity"
```

---

### Task 2: Module 1 — Shell & Navigation Polish (7 Widgets)

**Files:**
- Modify: `frontend/lib/modules/shell/views/main_shell_screen.dart`
- Modify: `frontend/lib/modules/shell/views/mobile/mobile_shell_view.dart`
- Modify: `frontend/lib/modules/shell/views/web/web_shell_view.dart`
- Modify: `frontend/lib/modules/shell/widgets/shell_header_bar.dart`
- Modify: `frontend/lib/modules/shell/widgets/shell_bottom_nav.dart`
- Modify: `frontend/lib/modules/shell/widgets/shell_drawer.dart`
- Modify: `frontend/lib/modules/shell/widgets/shell_helpline_dialog.dart`
- Modify: `frontend/lib/modules/shell/widgets/shell_footer.dart`
- Create: `frontend/test/modules/shell_animations_test.dart`

**Interfaces:**
- Consumes: `MultiTabSlideFadeTransition`, `HeaderElevationFade`, `StickyHeaderShrinkTransition`, `ActiveTabIndicatorGlide`, `NotificationBellJingle`, `BottomNavBubbleJump`, `StaggeredSheetItemsSlide`, `PulseBeaconIndicator`
- Produces: Fluid tactile shell with 0 static navigation widgets.

- [ ] **Step 1: Write widget test for shell animations**

```dart
// frontend/test/modules/shell_animations_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/shell/widgets/shell_bottom_nav.dart';
import 'package:landtrust_app/modules/shell/widgets/shell_helpline_dialog.dart';

void main() {
  testWidgets('ShellBottomNav renders with bounce bubble jump', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: ShellBottomNav(currentIndex: 0, onTap: (_) {}),
      ),
    ));
    expect(find.byType(ShellBottomNav), findsOneWidget);
  });

  testWidgets('ShellHelplineDialog renders with pulse beacon', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ShellHelplineDialog())));
    expect(find.text('২৪/৭ কাস্টমার সার্ভিস ও সাপোর্ট'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails or verifies baseline**

Run: `cd frontend && flutter test test/modules/shell_animations_test.dart`

- [ ] **Step 3: Wire animations across shell widgets**

1. In `MainShellScreen`, wrap tab views in `MultiTabSlideFadeTransition(tabIndex: _currentTabIndex, child: ...)`
2. In `MobileShellView`, wrap app bar in `HeaderElevationFade` and menu button in `BouncingPressable`.
3. In `WebShellView` and `ShellFooter`, add smooth entrance and sticky shrink transition.
4. In `ShellHeaderBar`, wrap active nav links with `ActiveTabIndicatorGlide` and alert bell with `NotificationBellJingle`.
5. In `ShellBottomNav`, wrap active icon in `BottomNavBubbleJump`.
6. In `ShellDrawer`, wrap drawer list items in `StaggeredSheetItemsSlide`.
7. In `ShellHelplineDialog`, add backdrop blur sweep and `PulseBeaconIndicator` on call icon.

Check line count: every file must stay $\le 200$ lines.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/modules/shell_animations_test.dart`  
Expected: PASS (0 analyzer warnings)

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/modules/shell/ frontend/test/modules/shell_animations_test.dart
git commit -m "feat(shell): wire tactile micro-interactions and transitions across shell widgets"
```

---

### Task 3: Module 2 — Marketplace & Public Browsing Polish (20 Widgets)

**Files:**
- Modify: `frontend/lib/modules/marketplace/views/home_marketplace_view.dart`
- Modify: `frontend/lib/modules/marketplace/views/web/home_marketplace_web_view.dart`
- Modify: `frontend/lib/modules/marketplace/views/mobile/home_marketplace_mobile_view.dart`
- Modify: `frontend/lib/modules/marketplace/views/buyer_demands_public_view.dart`
- Modify: `frontend/lib/modules/marketplace/views/mobile/buyer_demands_mobile_view.dart`
- Modify: `frontend/lib/modules/marketplace/views/rules_and_fees_view.dart`
- Modify: `frontend/lib/modules/marketplace/views/privacy_policy_view.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/property_card_widget.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/mobile/mobile_property_card.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/mobile/mobile_search_header.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/mobile/mobile_filter_bottom_sheet.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/property_details_dialog.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/mobile/mobile_property_details_sheet.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/contact_inquiry_dialog.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/seller_offer_dialog.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/safety_warning_card.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/hero_banner_widget.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/listing_filter_bar.dart`
- Modify: `frontend/lib/modules/marketplace/widgets/home_stats_row.dart`
- Create: `frontend/lib/modules/marketplace/widgets/marketplace_pagination_bar.dart`
- Create: `frontend/test/modules/marketplace_animations_test.dart`

**Interfaces:**
- Consumes: `HoverLiftCard`, `BouncingPressable`, `PulseBeaconIndicator`, `RollingDigitCounter`, `SecurityShieldLockSnap`, `CommissionSplitSlidingBar`, `PaginationPageSlide`
- Produces: Fully tactile marketplace browsing with odometer pricing, spring touch, and smooth indicators.

- [ ] **Step 1: Write test for marketplace animations**

```dart
// frontend/test/modules/marketplace_animations_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SafetyWarningCard())));
    expect(find.text('নিরাপদ ও ঝুঁকিহীন জমি ক্রয়ের মূলনীতি'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd frontend && flutter test test/modules/marketplace_animations_test.dart`  
Expected: FAIL (missing `MarketplacePaginationBar`).

- [ ] **Step 3: Implement `MarketplacePaginationBar` and wire marketplace widgets**

1. Create `MarketplacePaginationBar` ($\le 120$ lines) wrapping page indicators with `PaginationPageSlide` and jump-to-top spring.
2. In `PropertyCardWidget` & `MobilePropertyCard`, ensure `HoverLiftCard` or `BouncingPressable` wraps outer card and prices animate with `RollingDigitCounter`.
3. In `HeroBannerWidget`, wrap CTA buttons in `BouncingPressable`.
4. In `ListingFilterBar`, wrap category chips with `SearchFilterTagSlide` and filter toggles with `SlidingPillBar`.
5. In `ContactInquiryDialog` & `SellerOfferDialog`, wrap action buttons with `SubmitButtonLoaderToSuccess` and commission breakdown with `CommissionSplitSlidingBar`.
6. In `RulesAndFeesView` & `PrivacyPolicyView`, wrap sections with `CollapsibleFormSectionAccordion` and reading progress indicator with `InvoiceProgressBar`.

Line budget audit: ensure `home_marketplace_mobile_view.dart`, `home_marketplace_web_view.dart`, `property_card_widget.dart`, and `mobile_property_card.dart` stay $\le 200$ lines.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/modules/marketplace_animations_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/modules/marketplace/ frontend/test/modules/marketplace_animations_test.dart
git commit -m "feat(marketplace): wire per-widget micro-animations and tactile feedback across marketplace"
```

---

### Task 4: Module 3 — Authentication & Onboarding Polish (8 Widgets)

**Files:**
- Modify: `frontend/lib/modules/auth/views/auth_screen.dart`
- Modify: `frontend/lib/modules/auth/views/web/auth_web_view.dart`
- Modify: `frontend/lib/modules/auth/views/mobile/auth_mobile_view.dart`
- Modify: `frontend/lib/modules/auth/widgets/login_form_card.dart`
- Modify: `frontend/lib/modules/auth/widgets/register_form_card.dart`
- Modify: `frontend/lib/modules/auth/widgets/demo_accounts_bar.dart`
- Modify: `frontend/lib/modules/auth/widgets/payment_info_box.dart`
- Modify: `frontend/lib/modules/auth/widgets/role_selector_widget.dart`
- Create: `frontend/test/modules/auth_animations_test.dart`

**Interfaces:**
- Consumes: `RoleSwitchCrossfadeTransition`, `EmptyStateFloat`, `PasswordEyeMorph`, `ErrorShakeAnimation`, `StepProgressGrowthTransition`, `BouncingPressable`, `SheenSweepEffect`, `OtpDigitBoxPulseTransition`, `RoadToPlotFlipTransition`
- Produces: Polished authentication flow with tactile card flips, password morphs, and TrxID focus highlights.

- [ ] **Step 1: Write test for auth animations**

```dart
// frontend/test/modules/auth_animations_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/auth/widgets/payment_info_box.dart';
import 'package:landtrust_app/modules/auth/widgets/demo_accounts_bar.dart';

void main() {
  testWidgets('PaymentInfoBox renders with pulse highlight on TrxID', (tester) async {
    final ctrl = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PaymentInfoBox(isMobile: true, trxIdController: ctrl, isVerifying: false),
      ),
    ));
    expect(find.byType(PaymentInfoBox), findsOneWidget);
  });

  testWidgets('DemoAccountsBar chips bounce on press', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DemoAccountsBar(onSelectAccount: (_, __) {})),
    ));
    expect(find.byType(DemoAccountsBar), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails or verifies baseline**

Run: `cd frontend && flutter test test/modules/auth_animations_test.dart`

- [ ] **Step 3: Wire auth animations**

1. In `AuthScreen`, wrap view switcher with `RoleSwitchCrossfadeTransition`.
2. In `AuthWebView`, wrap decorative illustration with `EmptyStateFloat`.
3. In `LoginFormCard`, add `PasswordEyeMorph` on visibility toggle and `ErrorShakeAnimation` on error triggers.
4. In `RegisterFormCard`, wrap registration steps with `StepProgressGrowthTransition` and submit button with `SubmitButtonLoaderToSuccess` (keep file $\le 200$ lines).
5. In `DemoAccountsBar`, wrap role chips in `BouncingPressable` with `SheenSweepEffect`.
6. In `PaymentInfoBox`, wrap TrxID input field with `OtpDigitBoxPulseTransition` and bKash/Nagad copy buttons with `BouncingPressable`.
7. In `RoleSelectorWidget`, wrap role cards with perspective spring response.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/modules/auth_animations_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/modules/auth/ frontend/test/modules/auth_animations_test.dart
git commit -m "feat(auth): integrate tactile spring, password morph, and TrxID pulse in auth widgets"
```

---

### Task 5: Module 4 — Member Portal & Workspace Polish (12 Widgets)

**Files:**
- Modify: `frontend/lib/modules/member_portal/views/member_dashboard_screen.dart`
- Modify: `frontend/lib/modules/member_portal/views/mobile/member_dashboard_mobile_view.dart`
- Modify: `frontend/lib/modules/member_portal/views/web/member_dashboard_web_view.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/listing_form_dialog.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/requirement_form_dialog.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/digital_id_card_dialog.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/agreement_certificate_dialog.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/add_custom_proposal_dialog.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/private_document_preview_dialog.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/payout_and_resubmit_dialogs.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/member_notifications_dialog.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/profile_and_security_dialogs.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/buyer_workspace_view.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/seller_workspace_view.dart`
- Modify: `frontend/lib/modules/member_portal/widgets/marketing_officer_view.dart`
- Create: `frontend/test/modules/member_portal_animations_test.dart`

**Interfaces:**
- Consumes: `AdminDashboardCardStaggerSlide`, `TabContentSlideWipe`, `FormStepSlideTransition`, `PriceSliderBubblePop`, `BankCardFlipCvvTransition`, `TrustSealStamp`, `DeedRibbonUnfurl`, `DigitalSignatureStroke`, `CommissionSplitBar`, `DocumentScannerLaser`, `DocumentPdfPageTurnTransition`, `PayoutTransferFlyArrow`, `BadgeCountPopTransition`, `BiometricScanRippleTransition`
- Produces: High-trust interactive portal with 3D card flips, legal stamps, and laser document inspection.

- [ ] **Step 1: Write test for member portal animations**

```dart
// frontend/test/modules/member_portal_animations_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/member_portal/widgets/digital_id_card_dialog.dart';
import 'package:landtrust_app/modules/member_portal/widgets/agreement_certificate_dialog.dart';

void main() {
  testWidgets('DigitalIdCardDialog renders with 3D flip card', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: DigitalIdCardDialog(officerData: {'referralCode': 'LT-TEST'}, isMobile: true),
      ),
    ));
    expect(find.byType(DigitalIdCardDialog), findsOneWidget);
  });

  testWidgets('AgreementCertificateDialog renders trust seal and ribbon', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AgreementCertificateDialog(proposal: {'id': 1}, isMobile: true),
      ),
    ));
    expect(find.byType(AgreementCertificateDialog), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails or verifies baseline**

Run: `cd frontend && flutter test test/modules/member_portal_animations_test.dart`

- [ ] **Step 3: Wire member portal animations**

1. In `DigitalIdCardDialog`, wrap the card in `BankCardFlipCvvTransition` with `TrustSealStamp`.
2. In `AgreementCertificateDialog`, wrap title with `DeedRibbonUnfurl` and signature with `DigitalSignatureStroke`.
3. In `PrivateDocumentPreviewDialog`, wrap preview with `DocumentScannerLaser` and page curl effect.
4. In `ListingFormDialog` & `RequirementFormDialog`, wrap steps with `FormStepSlideTransition` and price sliders with `PriceSliderBubblePop` (maintain $\le 200$ lines).
5. In `PayoutAndResubmitDialogs`, wrap payout CTA with `PayoutTransferFlyArrow`.
6. In `MemberNotificationsDialog`, wrap badge count with `BadgeCountPopTransition` and dismiss items with `ListItemDeleteCollapse`.
7. In `ProfileAndSecurityDialogs`, wrap 2FA/biometric verification with `BiometricScanRippleTransition`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/modules/member_portal_animations_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/modules/member_portal/ frontend/test/modules/member_portal_animations_test.dart
git commit -m "feat(portal): wire 3D ID flip, legal stamps, and laser scan in member portal"
```

---

### Task 6: Module 5 — Admin Management Panel Polish (18 Widgets)

**Files:**
- Modify: `frontend/lib/modules/admin/views/admin_panel_screen.dart`
- Modify: `frontend/lib/modules/admin/views/mobile/admin_panel_mobile_view.dart`
- Modify: `frontend/lib/modules/admin/views/web/admin_panel_web_view.dart`
- Modify: `frontend/lib/modules/admin/views/admin_overview_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_users_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_listings_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_demands_inquiries_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_commissions_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_finance_proposals_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_settings_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_chat_inbox_tab.dart`
- Modify: `frontend/lib/modules/admin/views/admin_nrb_dialog.dart`
- Modify: `frontend/lib/modules/admin/widgets/admin_user_dialogs.dart`
- Modify: `frontend/lib/modules/admin/widgets/award_commission_dialog.dart`
- Modify: `frontend/lib/modules/admin/widgets/admin_finance_dialogs.dart`
- Modify: `frontend/lib/modules/admin/widgets/admin_settings_dialogs.dart`
- Modify: `frontend/lib/modules/admin/widgets/admin_communication_dialogs.dart`
- Modify: `frontend/lib/modules/admin/widgets/admin_listing_fees_card.dart`
- Modify: `frontend/lib/modules/admin/widgets/admin_listing_card.dart`
- Modify: `frontend/lib/modules/admin/widgets/admin_user_card.dart`
- Create: `frontend/test/modules/admin_animations_test.dart`

**Interfaces:**
- Consumes: `AdminDashboardCardStaggerSlide`, `WalletBalanceCreditRoll`, `UserStatusBadgeMorphTransition`, `PermissionRevokeStrikeTransition`, `AdminApprovalStampSlam`, `StatusPillColorShift`, `CommissionSplitSlidingBar`, `EscrowVaultLock`, `PermissionToggleMorph`, `ChatTypingWave`, `MilestonePathGlow`, `ConfettiCelebration`, `InvoiceQrCodeZoomReveal`, `DigitalReceiptFoldUnfoldTransition`, `RadialGaugeFill`
- Produces: Executive real-estate operations console with rolling currency counters, rubber stamp approvals, and escrow locks.

- [ ] **Step 1: Write test for admin animations**

```dart
// frontend/test/modules/admin_animations_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/admin/widgets/award_commission_dialog.dart';
import 'package:landtrust_app/modules/admin/widgets/admin_listing_fees_card.dart';

void main() {
  testWidgets('AwardCommissionDialog renders milestone path and confetti burst', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AwardCommissionDialog(proposal: {'id': 1}, isMobile: true)),
    ));
    expect(find.byType(AwardCommissionDialog), findsOneWidget);
  });

  testWidgets('AdminListingFeesCard renders fees with submit morph', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: AdminListingFeesCard(fees: const {'buyerRegistrationFee': 1000}, onSave: (_) {})),
    ));
    expect(find.byType(AdminListingFeesCard), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails or verifies baseline**

Run: `cd frontend && flutter test test/modules/admin_animations_test.dart`

- [ ] **Step 3: Wire admin micro-animations**

1. In `AdminOverviewTab`, wrap fund cards with `AdminDashboardCardStaggerSlide` and fund balances with `WalletBalanceCreditRoll`.
2. In `AdminUsersTab` & `AdminUserCard`, wrap status chips with `UserStatusBadgeMorphTransition` and suspension strikes with `PermissionRevokeStrikeTransition`.
3. In `AdminListingsTab` & `AdminListingCard`, wrap approval actions with `AdminApprovalStampSlam` and status with `StatusPillColorShift`.
4. In `AdminDemandsInquiriesTab`, wrap status chips with `StatusPillColorShift` (ensure file stays $\le 200$ lines).
5. In `AdminCommissionsTab` & `AwardCommissionDialog`, wrap commission split with `CommissionSplitSlidingBar`, milestone glow with `MilestonePathGlow`, and confetti burst with `ConfettiCelebration`.
6. In `AdminFinanceProposalsTab` & `AdminFinanceDialogs`, wrap escrow cards with `EscrowVaultLock`, receipt with `DigitalReceiptFoldUnfoldTransition`, and QR codes with `InvoiceQrCodeZoomReveal` (maintain $\le 200$ lines).
7. In `AdminSettingsTab` & `AdminSettingsDialogs`, wrap toggles with `PermissionToggleMorph` and platform rates with `RadialGaugeFill`.
8. In `AdminChatInboxTab`, wrap typing indicators with `ChatTypingWave`.
9. In `AdminNrbDialog`, wrap map routing with `GpsVehicleMove`.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/modules/admin_animations_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/modules/admin/ frontend/test/modules/admin_animations_test.dart
git commit -m "feat(admin): wire rolling odometer, approval stamp, and escrow vault animations in admin panel"
```

---

### Task 7: Module 6 — NRB Diaspora Services Polish (3 Widgets)

**Files:**
- Modify: `frontend/lib/modules/nrb/widgets/nrb_service_dialog.dart`
- Modify: `frontend/lib/modules/nrb/widgets/my_nrb_requests_dialog.dart`
- Modify: `frontend/lib/modules/nrb/widgets/nrb_request_card.dart`
- Create: `frontend/test/modules/nrb_animations_test.dart`

**Interfaces:**
- Consumes: `TrustSealStamp`, `UnitConverterSpinTransition`, `EscrowStatusProgressStepTransition`, `SheenSweepEffect`, `ReviewSummaryCardFlip`
- Produces: Polished NRB portal with embassy verification sheen sweeps and PoA legal seal stamps.

- [ ] **Step 1: Write test for NRB animations**

```dart
// frontend/test/modules/nrb_animations_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/nrb/widgets/nrb_request_card.dart';
import 'package:landtrust_app/modules/nrb/widgets/nrb_service_dialog.dart';

void main() {
  testWidgets('NrbRequestCard renders with status and sheen', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NrbRequestCard(request: {'poaStatus': 'SUBMITTED'}, isMobile: true)),
    ));
    expect(find.byType(NrbRequestCard), findsOneWidget);
  });

  testWidgets('NrbServiceDialog renders legal stamp and currency converter', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: NrbServiceDialog(isMobile: true)),
    ));
    expect(find.byType(NrbServiceDialog), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails or verifies baseline**

Run: `cd frontend && flutter test test/modules/nrb_animations_test.dart`

- [ ] **Step 3: Wire NRB animations**

1. In `NrbServiceDialog`, wrap PoA header with `TrustSealStamp` and currency rate calculator with `UnitConverterSpinTransition`.
2. In `MyNrbRequestsDialog`, wrap embassy progress timeline with `EscrowStatusProgressStepTransition`.
3. In `NrbRequestCard`, wrap verified status badge with `SheenSweepEffect` and card touch with `BouncingPressable`.

Ensure all 3 files remain $\le 200$ lines.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/modules/nrb_animations_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/modules/nrb/ frontend/test/modules/nrb_animations_test.dart
git commit -m "feat(nrb): integrate legal seal stamp and embassy timeline in diaspora services"
```

---

### Task 8: Module 7 — Live Chat & Communication Polish (2 Widgets + Bubble)

**Files:**
- Modify: `frontend/lib/modules/chat/views/chat_conversation_screen.dart`
- Modify: `frontend/lib/modules/chat/views/my_chat_threads_dialog.dart`
- Modify: `frontend/lib/modules/chat/widgets/chat_message_bubble.dart`
- Create: `frontend/test/modules/chat_animations_test.dart`

**Interfaces:**
- Consumes: `MessageFlightCurve`, `ChatTypingWave`, `BadgeCountPopTransition`, `ReadReceiptCheckMorph`, `BouncingPressable`
- Produces: Dynamic messaging experience with flight trajectories, unread badge pops, and live typing waves.

- [ ] **Step 1: Write test for chat animations**

```dart
// frontend/test/modules/chat_animations_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/chat/widgets/chat_message_bubble.dart';
import 'package:landtrust_app/modules/chat/views/my_chat_threads_dialog.dart';

void main() {
  testWidgets('ChatMessageBubble renders with touch spring and read checkmark', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ChatMessageBubble(message: {'content': 'Hello', 'senderId': 1}, isMe: true)),
    ));
    expect(find.byType(ChatMessageBubble), findsOneWidget);
  });

  testWidgets('MyChatThreadsDialog renders with unread count badge pop', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: MyChatThreadsDialog(isMobile: true)),
    ));
    expect(find.byType(MyChatThreadsDialog), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails or verifies baseline**

Run: `cd frontend && flutter test test/modules/chat_animations_test.dart`

- [ ] **Step 3: Wire chat animations**

1. In `ChatConversationScreen`, wrap outbound send action with `MessageFlightCurve` and loading/partner response state with `ChatTypingWave`.
2. In `MyChatThreadsDialog`, wrap unread counter with `BadgeCountPopTransition` and thread items with `StaggeredWaterfallSlide`.
3. In `ChatMessageBubble`, wrap bubble with `BouncingPressable` and status check with `ReadReceiptCheckMorph`.

Ensure all 3 files remain $\le 200$ lines.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd frontend && flutter test test/modules/chat_animations_test.dart`  
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add frontend/lib/modules/chat/ frontend/test/modules/chat_animations_test.dart
git commit -m "feat(chat): wire flight trajectories, typing waves, and unread pops in chat module"
```

---

### Task 9: Comprehensive End-to-End Verification, Line Audit & Production Release

**Files:**
- Audit all `.dart` files across `frontend/lib/` and `frontend/test/`
- Target outputs: `frontend/build/web`, `frontend/build/app/outputs/flutter-apk/*.apk`

- [ ] **Step 1: Line Count Audit**

Run:
```bash
python3 -c "
import os
too_long = []
for root, _, files in os.walk('frontend/lib'):
    for f in files:
        if f.endswith('.dart'):
            p = os.path.join(root, f)
            with open(p) as fl:
                lines = len(fl.readlines())
                if lines > 200:
                    too_long.append((p, lines))
if too_long:
    print('VIOLATIONS (>200 lines):', too_long)
    exit(1)
else:
    print('SUCCESS: All dart files <= 200 lines!')
"
```
Expected: `SUCCESS: All dart files <= 200 lines!`

- [ ] **Step 2: Run all Flutter tests**

Run: `cd frontend && flutter test`  
Expected: All tests pass (>= 212 tests pass, 0 failures, 0 errors).

- [ ] **Step 3: Run Flutter Analyzer**

Run: `cd frontend && flutter analyze --no-fatal-infos`  
Expected: `No issues found!`

- [ ] **Step 4: Run Spring Boot backend test suite**

Run: `cd backend && mvn test`  
Expected: `Tests run: 9, Failures: 0, Errors: 0, Skipped: 0`

- [ ] **Step 5: Compile Production Web Distribution**

Run: `cd frontend && flutter build web --release`  
Expected: Build success in `frontend/build/web`.

- [ ] **Step 6: Compile Production Android Release APKs**

Run: `cd frontend && flutter build apk --release --split-per-abi`  
Expected: Clean compilation of `app-armeabi-v7a-release.apk` and `app-arm64-v8a-release.apk`.

- [ ] **Step 7: Final Branch Commit & Verification Gate**

```bash
git status
git add .
git commit -m "chore: complete comprehensive per-widget micro-animations suite and verification"
```
