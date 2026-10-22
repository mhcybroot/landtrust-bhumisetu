# Ultimate 100-Transitional-Animation Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 100 domain-specific real-estate transitional animations organized into 10 cohesive native Flutter modules with complete automated test coverage, zero analyzer warnings, and zero external packages.

**Architecture:** 10 modular Flutter libraries under `frontend/lib/core/animations/transitions/` containing 10 transitions each, strictly $\le 200$ lines per file. Tested via 10 parallel test files under `frontend/test/transitions/`, bringing test count to 200 passing tests. Pure native Flutter primitives (`PageRouteBuilder`, `TransitionsBuilders`, `SlideTransition`, `ScaleTransition`, `SizeTransition`, `FadeTransition`, `CustomPainter`, `ClipPath`, `Transform`).

**Tech Stack:** Flutter 3.33+ / Dart 3.5+, Spring Boot 3 backend (live verification).

**Spec:** `docs/superpowers/specs/2026-10-23-ultimate-100-transitional-animations-design.md`

## Global Constraints

- Flutter 3.33+, Dart 3.5+.
- Zero new third-party dependencies in `pubspec.yaml`.
- Strictly maintain line counts $\le 200$ lines for every modified and created `.dart` file.
- Zero-warning linter policy: `flutter analyze --no-fatal-infos` must report 0 issues.
- All Flutter tests must pass with `flutter test` (100 existing + 100 new = 200 tests total).
- Bengali numeral localization for dynamic counters using shared `_toBn` helpers.

## Review Focus

1. **Epicenter Out-of-Bounds:** `CircularClipRevealRoute` when tap epicenter is outside viewport or null must default gracefully to viewport center.
2. **Double AnimationController Tickers:** Stateful widgets using `SingleTickerProviderStateMixin` must instantiate controllers once in `initState` and never recreate in `didUpdateWidget`.
3. **Empty / Inflexible Children:** Layouts using `Flexible` or `Expanded` inside transition widgets must not pass negative flex factors or unconstrained infinite sizes.
4. **Ticker Leaks:** All created `AnimationController`s must be explicitly disposed in `dispose()`.
5. **Continuous Animations in Tests:** Tests must not call `pumpAndSettle()` on continuously looping animations; they must use bounded pumps (`tester.pump(const Duration(milliseconds: 150))`).

---

### Task 1: Suite 1 — Full-Screen Page Route Transitions (`route_navigation_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/route_navigation_transitions.dart`
- Create: `frontend/test/transitions/route_navigation_transitions_test.dart`

**Interfaces:**
- Produces: 10 `PageRouteBuilder<T>` classes: `SharedAxisSlideRoute`, `CircularClipRevealRoute`, `ZoomFadeRoute`, `ParallaxBackRoute`, `HorizontalCubeRotateRoute`, `VerticalCurtainSlideRoute`, `StaggeredSplitSlideRoute`, `DiagonalWipeRoute`, `FadeThroughRoute`, `ElasticPopBackRoute`.

- [ ] **Step 1.1: Write tests for Suite 1** in `frontend/test/transitions/route_navigation_transitions_test.dart` verifying all 10 route transitions build and render destination pages.
- [ ] **Step 1.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/route_navigation_transitions_test.dart`.
- [ ] **Step 1.3: Implement Suite 1** in `frontend/lib/core/animations/transitions/route_navigation_transitions.dart` ($\le 195$ lines).
- [ ] **Step 1.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/route_navigation_transitions_test.dart`.
- [ ] **Step 1.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 1.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add full-screen page route transitions suite"`.

---

### Task 2: Suite 2 — Modal, Dialog & Alert Transitions (`modal_dialog_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/modal_dialog_transitions.dart`
- Create: `frontend/test/transitions/modal_dialog_transitions_test.dart`

**Interfaces:**
- Produces: 10 modal/dialog transition widgets: `ScaleBounceDialogTransition`, `BackdropBlurRevealTransition`, `TopCurtainNotificationDrop`, `Perspective3dFlipAlert`, `CenterPopActionTransition`, `SlideUpNoticeTransition`, `RadialCornerDialogReveal`, `PencilSketchBorderDialog`, `ShutterBlindModalTransition`, `VanishDissolveDismiss`.

- [ ] **Step 2.1: Write tests for Suite 2** in `frontend/test/transitions/modal_dialog_transitions_test.dart`.
- [ ] **Step 2.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/modal_dialog_transitions_test.dart`.
- [ ] **Step 2.3: Implement Suite 2** in `frontend/lib/core/animations/transitions/modal_dialog_transitions.dart` ($\le 195$ lines).
- [ ] **Step 2.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/modal_dialog_transitions_test.dart`.
- [ ] **Step 2.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 2.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add modal dialog and alert transitions suite"`.

---

### Task 3: Suite 3 — Shared Element & Hero Morph Transitions (`shared_element_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/shared_element_transitions.dart`
- Create: `frontend/test/transitions/shared_element_transitions_test.dart`

**Interfaces:**
- Produces: 10 shared-element morph widgets: `PropertyCardToDetailMorph`, `FloatingSearchToHeaderMorph`, `MapPlotToFullscreenHero`, `AvatarToProfileBadgeMorph`, `ThumbnailGridToLightboxMorph`, `FabToSheetMorph`, `KhatiyanTileToDeedViewerMorph`, `BadgeLevelUpMorph`, `PriceTagToEscrowHero`, `PlotMarkerToBottomPreviewMorph`.

- [ ] **Step 3.1: Write tests for Suite 3** in `frontend/test/transitions/shared_element_transitions_test.dart`.
- [ ] **Step 3.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/shared_element_transitions_test.dart`.
- [ ] **Step 3.3: Implement Suite 3** in `frontend/lib/core/animations/transitions/shared_element_transitions.dart` ($\le 195$ lines).
- [ ] **Step 3.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/shared_element_transitions_test.dart`.
- [ ] **Step 3.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 3.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add shared element and hero morph transitions suite"`.

---

### Task 4: Suite 4 — Bottom Sheet & Drawer Transitions (`sheet_drawer_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/sheet_drawer_transitions.dart`
- Create: `frontend/test/transitions/sheet_drawer_transitions_test.dart`

**Interfaces:**
- Produces: 10 sheet & drawer widgets: `SmoothSheetDragSnapper`, `FilterDrawerFoldTransition`, `StickyHeaderShrinkTransition`, `AccordionShelfExpandTransition`, `RotatingChevronDropdownTransition`, `MultiTabSlideFadeTransition`, `SplitDrawerDockTransition`, `CurvedEdgePullTransition`, `FloatingDockCollapseTransition`, `FloatingActionMenuRadialUnfurl`.

- [ ] **Step 4.1: Write tests for Suite 4** in `frontend/test/transitions/sheet_drawer_transitions_test.dart`.
- [ ] **Step 4.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/sheet_drawer_transitions_test.dart`.
- [ ] **Step 4.3: Implement Suite 4** in `frontend/lib/core/animations/transitions/sheet_drawer_transitions.dart` ($\le 195$ lines).
- [ ] **Step 4.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/sheet_drawer_transitions_test.dart`.
- [ ] **Step 4.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 4.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add bottom sheet and drawer transitions suite"`.

---

### Task 5: Suite 5 — List & State-Switching Micro-Transitions (`state_micro_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/state_micro_transitions.dart`
- Create: `frontend/test/transitions/state_micro_transitions_test.dart`

**Interfaces:**
- Produces: 10 state micro-transition widgets: `ListItemDeleteCollapse`, `RefreshCrossfadeWipe`, `SkeletonToContentFadeIn`, `TabContentSlideWipe`, `BadgeCountPopTransition`, `CheckboxCrossfadeCheck`, `SortOrderArrowFlip`, `StatusPillColorShift`, `EmptyToResultsMorph`, `PaginationPageSlide`.

- [ ] **Step 5.1: Write tests for Suite 5** in `frontend/test/transitions/state_micro_transitions_test.dart`.
- [ ] **Step 5.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/state_micro_transitions_test.dart`.
- [ ] **Step 5.3: Implement Suite 5** in `frontend/lib/core/animations/transitions/state_micro_transitions.dart` ($\le 195$ lines).
- [ ] **Step 5.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/state_micro_transitions_test.dart`.
- [ ] **Step 5.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 5.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add list and state micro-transitions suite"`.

---

### Task 6: Suite 6 — Multi-Step Form & Wizard Transitions (`form_wizard_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/form_wizard_transitions.dart`
- Create: `frontend/test/transitions/form_wizard_transitions_test.dart`

**Interfaces:**
- Produces: 10 form wizard widgets: `StepSlideFadeTransition`, `StepProgressGrowthTransition`, `FieldErrorShakeTransition`, `FaceScannerFrameMorph`, `SubmitButtonLoaderToSuccess`, `CascadingDropdownTransition`, `UnitConverterSpinTransition`, `DraftAutoSaveFlash`, `PriceSliderBubblePop`, `UploadRingToCompleteTransition`.

- [ ] **Step 6.1: Write tests for Suite 6** in `frontend/test/transitions/form_wizard_transitions_test.dart`.
- [ ] **Step 6.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/form_wizard_transitions_test.dart`.
- [ ] **Step 6.3: Implement Suite 6** in `frontend/lib/core/animations/transitions/form_wizard_transitions.dart` ($\le 195$ lines).
- [ ] **Step 6.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/form_wizard_transitions_test.dart`.
- [ ] **Step 6.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 6.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add multi-step form and wizard transitions suite"`.

---

### Task 7: Suite 7 — GIS, Map & Satellite View Transitions (`gis_map_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/gis_map_transitions.dart`
- Create: `frontend/test/transitions/gis_map_transitions_test.dart`

**Interfaces:**
- Produces: 10 GIS & map widgets: `Map2dTo3dCameraTilt`, `MouzaOverlayCrossfade`, `PlotBoundaryCenterZoom`, `MarkerClusterSplitTransition`, `DrawingCursorToPenMorph`, `RoadToPlotFlipTransition`, `CompassNorthHeadingAlign`, `FloodZoneWaterRiseTransition`, `LandmarkRadarPinDrop`, `SplitMapListPanelSlide`.

- [ ] **Step 7.1: Write tests for Suite 7** in `frontend/test/transitions/gis_map_transitions_test.dart`.
- [ ] **Step 7.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/gis_map_transitions_test.dart`.
- [ ] **Step 7.3: Implement Suite 7** in `frontend/lib/core/animations/transitions/gis_map_transitions.dart` ($\le 195$ lines).
- [ ] **Step 7.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/gis_map_transitions_test.dart`.
- [ ] **Step 7.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 7.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add GIS map and satellite view transitions suite"`.

---

### Task 8: Suite 8 — Media, Gallery & 360 Tour Transitions (`media_gallery_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/media_gallery_transitions.dart`
- Create: `frontend/test/transitions/media_gallery_transitions_test.dart`

**Interfaces:**
- Produces: 10 media & gallery widgets: `GridToLightboxZoom`, `BeforeAfterSliderWipe`, `Panorama360SwipeRotate`, `DroneVideoThumbnailMorph`, `FloorPlanLevelSwitch`, `PhotoAlbumCubeTransition`, `ThumbnailStripReveal`, `VideoPipMinimizeTransition`, `VirtualTourHotspotJump`, `SatelliteTimelapseWipe`.

- [ ] **Step 8.1: Write tests for Suite 8** in `frontend/test/transitions/media_gallery_transitions_test.dart`.
- [ ] **Step 8.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/media_gallery_transitions_test.dart`.
- [ ] **Step 8.3: Implement Suite 8** in `frontend/lib/core/animations/transitions/media_gallery_transitions.dart` ($\le 195$ lines).
- [ ] **Step 8.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/media_gallery_transitions_test.dart`.
- [ ] **Step 8.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 8.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add media gallery and 360 tour transitions suite"`.

---

### Task 9: Suite 9 — Financial, Escrow & Payment Transitions (`finance_payment_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/finance_payment_transitions.dart`
- Create: `frontend/test/transitions/finance_payment_transitions_test.dart`

**Interfaces:**
- Produces: 10 finance & payment widgets: `BajnaToEscrowLockTransition`, `PaymentMethodRadioBounce`, `CommissionFilterCurtainDrop`, `DigitalReceiptPaperUnfold`, `TokenCountdownPulse`, `WalletBalanceCreditRoll`, `RefundReverseArrowTransition`, `InstallmentScheduleCardFlip`, `TaxSummarySlideUpDrawer`, `PaymentConfirmationShieldGlow`.

- [ ] **Step 9.1: Write tests for Suite 9** in `frontend/test/transitions/finance_payment_transitions_test.dart`.
- [ ] **Step 9.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/finance_payment_transitions_test.dart`.
- [ ] **Step 9.3: Implement Suite 9** in `frontend/lib/core/animations/transitions/finance_payment_transitions.dart` ($\le 195$ lines).
- [ ] **Step 9.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/finance_payment_transitions_test.dart`.
- [ ] **Step 9.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 9.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add financial escrow and payment transitions suite"`.

---

### Task 10: Suite 10 — Admin, Role-Switch & Auth Transitions (`admin_auth_transitions.dart`)

**Files:**
- Create: `frontend/lib/core/animations/transitions/admin_auth_transitions.dart`
- Create: `frontend/test/transitions/admin_auth_transitions_test.dart`

**Interfaces:**
- Produces: 10 admin & auth widgets: `BuyerToSellerFlipTransition`, `AdminTabSlidingUnderline`, `OtpPinAutoFocusHop`, `BiometricScanWaveTransition`, `InactivitySessionBlurTransition`, `DocumentRejectFlagDrop`, `PermissionToggleMorph`, `LogoutReverseZoomTransition`, `OledSunToMoonCircularReveal`, `SystemMaintenanceBannerSlide`.

- [ ] **Step 10.1: Write tests for Suite 10** in `frontend/test/transitions/admin_auth_transitions_test.dart`.
- [ ] **Step 10.2: Run test to verify failure:** `cd frontend && flutter test test/transitions/admin_auth_transitions_test.dart`.
- [ ] **Step 10.3: Implement Suite 10** in `frontend/lib/core/animations/transitions/admin_auth_transitions.dart` ($\le 195$ lines).
- [ ] **Step 10.4: Run test to verify it passes:** `cd frontend && flutter test test/transitions/admin_auth_transitions_test.dart`.
- [ ] **Step 10.5: Verify analyzer and line counts:** `flutter analyze --no-fatal-infos` and `wc -l`.
- [ ] **Step 10.6: Commit:** `git add frontend/ && git commit -m "feat(transitions): add admin role switch and auth transitions suite"`.

---

### Task 11: Whole-Suite Verification, Quality Gates & Web Release Build

**Files:**
- Review: all 10 created modules and 10 test files.

- [ ] **Step 11.1:** Run all frontend tests: `cd frontend && flutter test` (verifying 200/200 tests pass).
- [ ] **Step 11.2:** Run Flutter analyzer: `cd frontend && flutter analyze --no-fatal-infos` (0 issues).
- [ ] **Step 11.3:** Run backend unit tests: `cd backend && mvn test` (9/9 pass).
- [ ] **Step 11.4:** Compile Flutter web release: `cd frontend && flutter build web --release`.
- [ ] **Step 11.5:** Perform Senior Code Review, finalize execution ledger, and merge feature branch to `main`.
