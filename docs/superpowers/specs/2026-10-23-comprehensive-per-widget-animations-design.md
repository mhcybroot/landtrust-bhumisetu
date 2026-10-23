# Design Spec: Comprehensive Per-Widget Micro-Animations & Tactile Polish Suite

**Document ID:** `2026-10-23-comprehensive-per-widget-animations-design`  
**Date:** 2026-10-23  
**Status:** REVIEWED & PENDING FINAL APPROVAL  
**Author:** Antigravity Team & Human Partner  
**Target Repository:** `Work/LandApp` (`frontend/lib/modules/` & `frontend/lib/core/animations/`)  

---

## 1. Intent & The Why

bdHousing (বিডি হাউজিং) is Bangladesh's premier trusted land and real estate marketplace. While the core platform features robust verification, transparent revenue escrow models, and a 100-transitional-animation library, user interactions on individual screens, dialogs, and cards still contain static components.

The objective of this project is to implement **Approach 2 (Component-by-Component Polish)** across **all 70 user-facing UI widgets** across the 7 feature modules (`shell`, `marketplace`, `auth`, `member_portal`, `admin`, `nrb`, `chat`). Every visible component, button, card, header, and list item will feature purposeful, tactile micro-animations (physical spring tap, desktop hover lift, rolling odometers, icon morphs, and state feedback), ensuring that **no widget on screen feels static or lifeless**, while maintaining 60fps performance and zero battery drain.

---

## 2. Goals, Non-Goals & Anti-Goals

### Goals
- **100% Interactive Coverage:** Every interactive button, chip, card, dialog, and list row across the 70 user-facing widget files must feature tactile micro-interactions (`BouncingPressable`, `HoverLiftCard`, `SubmitButtonLoaderToSuccess`, `PulseBeaconIndicator`, etc.).
- **Domain-Tailored Polish:** Align animations to real-estate domains (e.g. ৳ odometer roll on prices, seal stamp on legal deeds, laser scan on documents, biometric ripple on authentication, and staggered cascades on admin cards).
- **Strict File Discipline:** Every modified and newly created `.dart` file must strictly adhere to the project's $\le 200$ line cap.
- **Zero External Dependencies:** Built purely with native Flutter primitives (`AnimatedBuilder`, `TweenAnimationBuilder`, `AnimatedSwitcher`, `Transform`, `ClipRect`, `PathMetric`).
- **Flawless Quality Gates:** `flutter analyze --no-fatal-infos` must report 0 issues, and all automated unit/widget tests must pass (existing 204 tests + new widget integration tests).

### Non-Goals
- Adding heavy 3D rendering engines (ThreeJS, Unity, Filament) or external animation runtimes (Lottie, Rive).
- Redesigning the underlying database schema, REST API contracts, or Spring Boot backend logic.
- Continuous unconstrained looping animations that exhaust battery or cause cognitive fatigue.

### Anti-Goals
- **Slop animations:** Animations that delay user actions or block UI clicks with artificial sleep timers.
- **Breaking line limits:** Letting any UI file grow beyond 200 lines to fit an animation.
- **Linter degradation:** Introducing deprecated APIs (e.g. `withOpacity`) or wildcards triggering Dart 3.5+ warnings.

---

## 3. Constraints

- **Language & Framework:** Flutter 3.33+, Dart 3.5+.
- **File Length Limit:** Strict hard limit of $\le 200$ lines per `.dart` file. Complex components exceeding 200 lines must be cleanly split into focused sub-widgets.
- **Zero-Warning Policy:** `flutter analyze --no-fatal-infos` must report 0 warnings, 0 errors, 0 hints.
- **Performance:** Micro-animations must run at 60fps (or 120fps on ProMotion displays) with zero frame drops (`Curves.easeOutCubic`, `Curves.fastOutSlowIn`, or `Curves.bounceOut`).

---

## 4. Approaches Considered

### Approach 1: Global Decorator/Theme Wrapper Pattern (Universal Decorator)
- **Concept:** Inject animated wrappers at the root theme level for `ElevatedButtonThemeData`, `CardThemeData`, and `ChipThemeData`.
- **Trade-offs:** Fast to implement, ensures 100% button consistency, but lacks bespoke domain flair (every card reacts identically regardless of whether it's an escrow ledger, mouza map, or property card).

### Approach 2: Component-by-Component Systematic Polish (Per-Widget Bespoke Suite) [SELECTED]
- **Concept:** Manually audit and tailor custom micro-interactions across all 70 user-facing UI widget files across the 7 modules.
- **Trade-offs:** Maximum visual polish and contextual domain delight (odometer for ৳, shield snap for security, laser scan for documents, stamp slam for approvals). Requires careful line-limit management across 70 files. Selected by human partner.

### Approach 3: Hybrid Universal Foundation + Domain Highlights
- **Concept:** Combine a theme-level wrapper for generic buttons with direct injections on hero cards.
- **Trade-offs:** Good balance, but human partner explicitly chose Approach 2 for tailored per-component control.

---

## 5. Architectural Blueprint: 70 Widgets Across 7 Modules

### Module 1: Shell & Navigation (7 Widgets)
1. [`MainShellScreen`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/views/main_shell_screen.dart): Tab view coordination with `AnimatedFadeSwitcher` & `MultiTabSlideFadeTransition`.
2. [`MobileShellView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/views/mobile/mobile_shell_view.dart): App bar with `HeaderElevationFade` and menu button touch spring.
3. [`WebShellView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/views/web/web_shell_view.dart): Sticky header shrink transition and smooth footer reveal.
4. [`ShellHeaderBar`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/widgets/shell_header_bar.dart): Nav links with `ActiveTabIndicatorGlide` and `NotificationBellJingle` on alerts.
5. [`ShellBottomNav`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/widgets/shell_bottom_nav.dart): Active tab icon bouncing bubble jump (`BottomNavBubbleJump`).
6. [`ShellDrawer`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/widgets/shell_drawer.dart): Slide-and-push drawer animation with staggered items entrance (`StaggeredSheetItemsSlide`).
7. [`ShellHelplineDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/shell/widgets/shell_helpline_dialog.dart): Backdrop blur reveal and dial icon pulse beacon (`PulseBeaconIndicator`).

### Module 2: Marketplace & Public Browsing (20 Widgets)
8. [`HomeMarketplaceView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/home_marketplace_view.dart): Pull-to-refresh spinner with compass alignment (`CompassRefreshSpinner`).
9. [`HomeMarketplaceWebView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/web/home_marketplace_web_view.dart): Hero headline float animation (`EmptyStateFloat`) and staggered grid waterfall.
10. [`HomeMarketplaceMobileView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/mobile/home_marketplace_mobile_view.dart): Filter chip horizontal sliding animation (`SearchFilterTagSlide`).
11. [`BuyerDemandsPublicView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/buyer_demands_public_view.dart): Demand cards with `HoverLiftCard` and budget odometer roll (`RollingDigitCounter`).
12. [`BuyerDemandsMobileView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/mobile/buyer_demands_mobile_view.dart): Floating filter pill morph (`FilterPillToFilterPanelMorph`) and tactile pressable buttons.
13. [`RulesAndFeesView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/rules_and_fees_view.dart): Accordion collapsible fee breakdown sections (`CollapsibleFormSectionAccordion`).
14. [`PrivacyPolicyView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/views/privacy_policy_view.dart): Top reading progress bar indicator (`InvoiceProgressBar`) and shared-axis slide push.
15. [`PropertyCardWidget`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/property_card_widget.dart): 3D hover lift, live video beacon pulse, and ৳ odometer price counter.
16. [`MobilePropertyCard`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/mobile/mobile_property_card.dart): Bouncing touch press (`BouncingPressable`) and price odometer roll.
17. [`MobileSearchHeader`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/mobile/mobile_search_header.dart): Search pill to search bar morph (`SearchBoxToResultsViewMorph`).
18. [`MobileFilterBottomSheet`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/mobile/mobile_filter_bottom_sheet.dart): Curved corner sheet pull-to-dismiss (`CurvedCornerSheetReveal`) & price slider bubble pop.
19. [`PropertyDetailsDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/property_details_dialog.dart): Backdrop blur reveal, elastic scale bounce, filmstrip slide crossfade, and ৳ odometer.
20. [`MobilePropertyDetailsSheet`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/mobile/mobile_property_details_sheet.dart): Velocity dismiss sheet with price odometer counter and WhatsApp CTA ripple.
21. [`ContactInquiryDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/contact_inquiry_dialog.dart): Backdrop blur spring bounce with `SubmitButtonLoaderToSuccess` button.
22. [`SellerOfferDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/seller_offer_dialog.dart): Sliding commission split bar (`CommissionSplitSlidingBar`) and morphing loader button.
23. [`SafetyWarningCard`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/marketplace/widgets/safety_warning_card.dart): Security shield lock snap animation (`SecurityShieldLockSnap`) and animated e-porcha guidance.
24. `MarketplaceSearchBar`: Search icon spin and active query tag insertion.
25. `MarketplaceFilterBar`: Sliding pill category selector (`SlidingPillBar`) and cascading dropdown menu unroll.
26. `MarketplaceStatsRow`: Live count-up animation for all 4 metrics (`AnimatedCountText`).
27. `MarketplacePagination`: Smooth animated page indicator / jump-to-top control (`PaginationPageSlide`) during continuous scrolling, preserving reactive listing state and existing tests.

### Module 3: Authentication & Onboarding (8 Widgets)
28. [`AuthScreen`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/views/auth_screen.dart): Tab crossfade between Login and Register (`RoleSwitchCrossfadeTransition`).
29. [`AuthWebView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/views/web/auth_web_view.dart): Illustration float animation (`EmptyStateFloat`) and responsive card entrance.
30. [`AuthMobileView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/views/mobile/auth_mobile_view.dart): Compact slide-up form entrance and animated keyboard offset.
31. [`LoginFormCard`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/widgets/login_form_card.dart): Password eye morph transition (`PasswordEyeMorph`) and validation shake (`ErrorShakeAnimation`).
32. [`RegisterFormCard`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/widgets/register_form_card.dart): Stepper progress bar growth (`StepProgressGrowthTransition`) and field error shake.
33. [`DemoAccountsBar`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/widgets/demo_accounts_bar.dart): Quick-fill account chip tap spring bounce (`BouncingPressable`) with sheen sweep.
34. [`PaymentInfoBox`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/auth/widgets/payment_info_box.dart): Registration fee TrxID input box pulse focus highlight (`OtpDigitBoxPulseTransition`) and account copy button spring tap (`BouncingPressable`), keeping live phone+password authentication reliable and untouched.
35. `RoleSelectionCard`: 3D perspective flip between Buyer, Seller, and Marketing Officer perspectives (`RoadToPlotFlipTransition`).

### Module 4: Member Portal & Dashboard (12 Widgets)
36. [`MemberDashboardScreen`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/views/member_dashboard_screen.dart): Role switch crossfade and profile header elevation fade.
37. [`MemberDashboardMobileView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/views/mobile/member_dashboard_mobile_view.dart): Metric cards cascade stagger slide (`AdminDashboardCardStaggerSlide`).
38. [`MemberDashboardWebView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/views/web/member_dashboard_web_view.dart): Multi-tab content slide wipe (`TabContentSlideWipe`).
39. [`ListingFormDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/listing_form_dialog.dart): Multi-step form step slide (`FormStepSlideTransition`) and upload progress ring fill.
40. [`RequirementFormDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/requirement_form_dialog.dart): Budget slider bubble pop (`PriceSliderBubblePop`) and cascading dropdowns.
41. [`DigitalIdCardDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/digital_id_card_dialog.dart): Marketing officer ID card 3D flip (`BankCardFlipCvvTransition`) and holographic trust seal stamp (`TrustSealStamp`).
42. [`AgreementCertificateDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/agreement_certificate_dialog.dart): Digital legal certificate ribbon unfurl (`DeedRibbonUnfurl`) and digital signature stroke (`DigitalSignatureStroke`).
43. [`AddCustomProposalDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/add_custom_proposal_dialog.dart): Currency calculation split bar (`CommissionSplitBar`) and loader to success morph.
44. [`PrivateDocumentPreviewDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/private_document_preview_dialog.dart): Document scanner laser sweep effect (`DocumentScannerLaser`) and 3D deed page turn (`DocumentPdfPageTurnTransition`).
45. [`PayoutAndResubmitDialogs`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/payout_and_resubmit_dialogs.dart): Money transfer flying arrow animation (`PayoutTransferFlyArrow`) and coin drop celebration on success.
46. [`MemberNotificationsDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/member_notifications_dialog.dart): Unread badge count pop (`BadgeCountPopTransition`) and dismiss item collapse (`ListItemDeleteCollapse`).
47. [`ProfileAndSecurityDialogs`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/member_portal/widgets/profile_and_security_dialogs.dart): Biometric sensor ripple wave (`BiometricScanRippleTransition`) and animated checkmark confirmation.

### Module 5: Admin Management Panel (18 Widgets)
48. [`AdminPanelScreen`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_panel_screen.dart): Central dashboard refresh pulse and role permissions crossfade.
49. [`AdminPanelMobileView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/mobile/admin_panel_mobile_view.dart): Horizontal chip scroll fade and tab switch slide wipe.
50. [`AdminPanelWebView`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/web/admin_panel_web_view.dart): Split navigation sidebar dock transition (`SplitDrawerDockTransition`).
51. [`AdminOverviewTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_overview_tab.dart): Fund bucket cards waterfall slide (`AdminDashboardCardStaggerSlide`) and live currency balance counters (`WalletBalanceCreditRoll`).
52. [`AdminUsersTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_users_tab.dart): User status badge morph (`UserStatusBadgeMorphTransition`) and ban/suspend strikethrough transition (`PermissionRevokeStrikeTransition`).
53. [`AdminListingsTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_listings_tab.dart): Listing approval rubber stamp slam (`AdminApprovalStampSlam`) and rejection flag drop.
54. [`AdminDemandsInquiriesTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_demands_inquiries_tab.dart): Status pill color shift (`StatusPillColorShift`) and inquiry cards entrance.
55. [`AdminCommissionsTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_commissions_tab.dart): Commission split sliding bar (`CommissionSplitSlidingBar`) and payout checkmark morph.
56. [`AdminFinanceProposalsTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_finance_proposals_tab.dart): Escrow vault lock animation (`EscrowVaultLock`) and bank note counter roll.
57. [`AdminSettingsTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_settings_tab.dart): Settings toggle switch morph (`PermissionToggleMorph`) and keystroke protection indicator.
58. [`AdminChatInboxTab`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_chat_inbox_tab.dart): Unread message bubble float and live chat typing wave (`ChatTypingWave`).
59. [`AdminNrbDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/views/admin_nrb_dialog.dart): World map plane flight transition (`GpsVehicleMove`) and diaspora document laser scanner.
60. [`AdminUserDialogs`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/widgets/admin_user_dialogs.dart): User role badge morphing and account status lock snap.
61. [`AwardCommissionDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/widgets/award_commission_dialog.dart): Milestone path glow (`MilestonePathGlow`) and confetti burst celebration (`ConfettiCelebration`).
62. [`AdminFinanceDialogs`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/widgets/admin_finance_dialogs.dart): Invoice QR code zoom reveal (`InvoiceQrCodeZoomReveal`) and digital receipt unfold (`DigitalReceiptFoldUnfoldTransition`).
63. [`AdminSettingsDialogs`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/widgets/admin_settings_dialogs.dart): Platform commission rate gauge fill (`RadialGaugeFill`) and fee speedometer needle.
64. [`AdminCommunicationDialogs`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/widgets/admin_communication_dialogs.dart): Announcement banner drop (`TopCurtainNotificationDrop`) and broadcast ripple wave.
65. [`AdminListingFeesCard`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/admin/widgets/admin_listing_fees_card.dart): Listing fee adjustment stepper pulse and save button loader to success checkmark.

### Module 6: NRB Diaspora Services (3 Widgets)
66. [`NrbServiceDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/nrb/widgets/nrb_service_dialog.dart): Power of Attorney legal stamp animation (`TrustSealStamp`) and currency converter spin (`UnitConverterSpinTransition`).
67. [`MyNrbRequestsDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/nrb/widgets/my_nrb_requests_dialog.dart): Application timeline progress step transition (`EscrowStatusProgressStepTransition`) and tracking status pulse beacon.
68. `NrbApplicationCard`: Embassy verification sheen sweep and document review card flip (`ReviewSummaryCardFlip`).

### Module 7: Live Chat & Communication (2 Widgets)
69. [`ChatConversationScreen`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/chat/views/chat_conversation_screen.dart): Message flight curve animation on send (`MessageFlightCurve`) and chat typing wave indicator (`ChatTypingWave`).
70. [`MyChatThreadsDialog`](file:///home/mhcybroot/Work/LandApp/frontend/lib/modules/chat/views/my_chat_threads_dialog.dart): Thread list item slide entrance and unread count bounce bubble (`BadgeCountPopTransition`).

---

## 6. Builder Check Review & Settled Architectural Decisions

Following the project builder check, three key architectural decisions were categorized and settled:

1. **Widget #34 Resolution (`PaymentInfoBox` & TrxID Polish) [Settled by Human Partner]:**
   - The backend authentication architecture operates strictly on phone + password without an SMS gateway.
   - The human partner confirmed: Polish `PaymentInfoBox` & the registration fee TrxID input card using `OtpDigitBoxPulseTransition` for payment transaction ID digit inputs, plus tactile spring feedback on account copy actions.
   - Live phone+password authentication and registration pipelines remain fast, reliable, and untouched by fake timers.

2. **Scope of Interactive Child Widgets [Settled as Assistant's Call]:**
   - To strictly fulfill Goal 1 ("100% Interactive Coverage: Every interactive button, chip, card..."), micro-animations will directly wrap the interactive child cards where user touch and hover physically occur (e.g., `AdminListingCard`, `AdminUserCard`, `ChatMessageBubble`, `HeroBannerWidget`, `NrbRequestCard`).
   - The implementation plan will budget and maintain the project's $\le 200$ line cap across both parent containers and their respective child widgets.

3. **Continuous Browsing vs. Pagination [Settled as Assistant's Call]:**
   - In `MarketplaceViewModel`, listings are fetched reactively and rendered via continuous sliver/grid scrolling.
   - `MarketplacePagination` (#27) will serve as an animated page indicator / jump-to-top control (`PaginationPageSlide`) for smooth continuous scrolling, rather than breaking the reactive listings state or introducing client-side slicing that would regress existing widget tests.

---

## 7. What's Left to the Builder

- The exact duration offsets (e.g. 250ms vs 300ms) for micro-animations to ensure smooth 60fps across varying GPU profiles.
- Splitting large widgets into clean sub-components whenever adding animation logic threatens the $\le 200$ line cap.
- Writing unit and widget tests for newly wired interactions to maintain 100% test passing baseline.

---

## 8. Verification & Quality Gates

1. **Automated Widget Tests:** Every module will have dedicated test cases verifying that animated widgets mount, trigger, and render properly without throwing `Ticker` or `setState` exceptions.
2. **Line Count Audit:** `wc -l` check ensuring every modified and created `.dart` file is $\le 200$ lines.
3. **Flutter Analyzer:** `flutter analyze --no-fatal-infos` must report 0 issues.
4. **Backend Continuity:** `cd backend && mvn test` must report 9/9 tests pass.
5. **Web Release Build:** `flutter build web --release` must compile cleanly without tree-shaking errors.
