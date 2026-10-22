# Ultimate 100-Transitional-Animation Suite Design Document

**Date:** 2026-10-23  
**Status:** In Review / Approved by Partner  
**Target Architecture:** Flutter 3.33+ / Dart 3.5+  
**Execution Mode:** `brainstorming` -> `writing-plans` -> `executing-plans` with `ponytail`

---

## 1. Intent & Context

The LandApp (bdHousing) platform requires a comprehensive suite of 100 domain-specific transitional animations. Transitional animations manage the visual continuum during state shifts: navigating between routes, opening and dismissing modals, expanding shared elements, swiping bottom sheets, and switching workflow stages in multi-step real estate procedures (land surveying, legal deeds, escrow payments, and property browsing).

---

## 2. Goals, Non-Goals & Anti-Goals

### Goals
- Deliver 100 high-performance, native transitional animations tailored to real estate workflows in Bangladesh.
- Maintain seamless 60/120 FPS performance on both low-end mobile devices and modern desktop web browsers.
- Structure into 10 cohesive modules (10 animations per file) keeping every `.dart` file strictly $\le 200$ lines.
- Achieve 100% automated test coverage across all 100 transitions.
- Zero linter warnings (`flutter analyze --no-fatal-infos` reporting 0 issues).

### Non-Goals
- Adding external animation dependencies (e.g., `flutter_animate`, `animations`, `lottie`).
- Rewriting the underlying business logic of existing navigation routes or controllers.
- Bloating bundle size with heavy video assets or external spritesheets.

### Anti-Goals
- Hardcoding display strings or numerical values into animation widgets.
- Creating long, disorienting transitions (>500ms) that delay user productivity.
- Memory leaks caused by unmanaged `AnimationController`s or orphaned ticker listeners.

---

## 3. Constraints & Technical Boundaries

- **Zero Third-Party Packages:** Pure native Flutter primitives (`PageRouteBuilder`, `TransitionsBuilders`, `SlideTransition`, `ScaleTransition`, `SizeTransition`, `FadeTransition`, `AnimatedSwitcher`, `CustomPainter`, `ClipPath`, `Transform`).
- **Strict File Limit:** Every `.dart` file must remain strictly $\le 200$ lines.
- **Dart 3.5+ / Flutter 3.33+ Compliant:** Use modern APIs (e.g., `withValues(alpha: ...)` instead of deprecated `withOpacity`).
- **Bengali Localization Ready:** All numeric counters and labels within transitions must render with proper Bengali numerals.

---

## 4. Architectural Approaches

1. **Approach 1: Monolithic Route Engine**
   - Single or dual centralized transition classes.
   - *Rejected:* Violates the strict $\le 200$ line cap, hard to maintain and test.
2. **Approach 2: 10 Modular Native Suites (10 files, 10 animations each $\le 200$ lines) [SELECTED]**
   - Clean domain separation across 10 native Flutter files under `lib/core/animations/transitions/`.
   - Accompanied by 10 automated test files in `test/transitions/`.
   - Zero new dependencies in `pubspec.yaml`.
3. **Approach 3: External Animation Packages**
   - Adding community packages (`flutter_animate`, `animations`).
   - *Rejected:* Bloats bundle size and breaks repo's zero-dependency philosophy.

---

## 5. Detailed Breakdown: 10 Suites (100 Transitional Animations)

### Suite 1: Full-Screen Page Route Transitions (`route_navigation_transitions.dart`)
1. `SharedAxisSlideRoute`: Horizontal shared-axis route push with smooth deceleration.
2. `CircularClipRevealRoute`: Expanding circular clip transition originating from tap offset.
3. `ZoomFadeRoute`: Gentle scale-up (0.92 to 1.0) with crossfade.
4. `ParallaxBackRoute`: Cupertino-style pop where background page subtly parallax shifts.
5. `HorizontalCubeRotateRoute`: 3D perspective cube rotation for major section shifts.
6. `VerticalCurtainSlideRoute`: Top-to-bottom or bottom-to-top sheet route cover.
7. `StaggeredSplitSlideRoute`: Two halves of the screen slide in from opposite sides.
8. `DiagonalWipeRoute`: Slanted geometric wipe revealing destination page.
9. `FadeThroughRoute`: Material 3 fade-through transition with slight scale change.
10. `ElasticPopBackRoute`: Physics-based bouncy bounce back transition on dismiss.

### Suite 2: Modal, Dialog & Alert Transitions (`modal_dialog_transitions.dart`)
11. `ScaleBounceDialogTransition`: Elastic spring scale-up for critical action confirmations.
12. `BackdropBlurRevealTransition`: Background blurs smoothly from 0 to 10px while dialog fades in.
13. `TopCurtainNotificationDrop`: Toast/banner sliding down smoothly from status bar with gentle bounce.
14. `Perspective3dFlipAlert`: Dialog flips around horizontal axis (X-axis) like a folding legal card.
15. `CenterPopActionTransition`: Quick scale-pop (0.0 to 1.0) with overshooting curve.
16. `SlideUpNoticeTransition`: Crisp slide-up bottom notice bar with elevation shadow fade.
17. `RadialCornerDialogReveal`: Modal expands from top-right or bottom-right action button.
18. `PencilSketchBorderDialog`: Dialog container outlines animate inward before content appears.
19. `ShutterBlindModalTransition`: Venetian-blind slat reveal effect for detailed disclaimer dialogs.
20. `VanishDissolveDismiss`: Particle/opacity dissolve when dialog is dismissed.

### Suite 3: Shared Element & Hero Morph Transitions (`shared_element_transitions.dart`)
21. `PropertyCardToDetailMorph`: Property card seamlessly transforms into header of listing details.
22. `FloatingSearchToHeaderMorph`: Floating search pill expands into sticky top search filter bar.
23. `MapPlotToFullscreenHero`: Mini plot boundary preview expands to fill entire GIS map canvas.
24. `AvatarToProfileBadgeMorph`: User circular avatar expands into full profile credentials card.
25. `ThumbnailGridToLightboxMorph`: Image grid thumbnail blooms smoothly into full-screen gallery viewer.
26. `FabToSheetMorph`: Floating Action Button morphs into interactive action sheet.
27. `KhatiyanTileToDeedViewerMorph`: Document preview list tile expands into full legal reader.
28. `BadgeLevelUpMorph`: Bronze membership badge expands and transforms into Gold badge.
29. `PriceTagToEscrowHero`: Listing price tag flies smoothly into escrow payment form input.
30. `PlotMarkerToBottomPreviewMorph`: Map pin tap morphs directly into hovering property summary card.

### Suite 4: Bottom Sheet & Drawer Transitions (`sheet_drawer_transitions.dart`)
31. `SmoothSheetDragSnapper`: Draggable bottom sheet with spring physics snapping at 25%, 50%, 90%.
32. `FilterDrawerFoldTransition`: Right-hand side drawer unfolding like a 3D folded pamphlet.
33. `StickyHeaderShrinkTransition`: Sliver header gracefully compresses title and hides subtitle on scroll.
34. `AccordionShelfExpandTransition`: Collapsible FAQ/criteria shelf smoothly animating height.
35. `RotatingChevronDropdownTransition`: Dropdown header rotates chevron 180° while content unrolls.
36. `MultiTabSlideFadeTransition`: Tab bar contents slide and fade symmetrically when toggling tabs.
37. `SplitDrawerDockTransition`: iPad/tablet landscape drawer sliding into fixed split dock.
38. `CurvedEdgePullTransition`: Pull-to-refresh transition with a curved canvas wave at the top edge.
39. `FloatingDockCollapseTransition`: Bottom navigation bar slides down and hides during map inspection.
40. `FloatingActionMenuRadialUnfurl`: Sub-action buttons blossom radially from a speed-dial FAB.

### Suite 5: List & State-Switching Micro-Transitions (`state_micro_transitions.dart`)
41. `ListItemDeleteCollapse`: Dismissed list tile collapses vertical height to zero with ease-out curve.
42. `RefreshCrossfadeWipe`: Pull-to-refresh spinner crossfades cleanly into updated property dataset.
43. `SkeletonToContentFadeIn`: Shimmer skeleton boxes smoothly crossfade into loaded text/image data.
44. `TabContentSlideWipe`: Tab content changes with directional directional wipe (left or right).
45. `BadgeCountPopTransition`: Counter pill pops (scales 1.3x -> 1.0x) whenever badge count changes.
46. `CheckboxCrossfadeCheck`: Circular outline crossfades smoothly into green solid check icon.
47. `SortOrderArrowFlip`: Sort button arrow flips 180° vertically when ascending/descending toggles.
48. `StatusPillColorShift`: Property state pill morphs color (e.g., Orange 'Pending' to Green 'Verified').
49. `EmptyToResultsMorph`: Empty illustration shrinks and crossfades cleanly into populated grid.
50. `PaginationPageSlide`: Listing grid gently shifts horizontally during next/prev page transition.

### Suite 6: Multi-Step Form & Wizard Transitions (`form_wizard_transitions.dart`)
51. `StepSlideFadeTransition`: Step 1 smoothly slides left while Step 2 slides in from right.
52. `StepProgressGrowthTransition`: Progress indicator line expands width with elastic overshoot.
53. `FieldErrorShakeTransition`: Invalid form input field executes a 3-cycle horizontal shake with red glow.
54. `FaceScannerFrameMorph`: Rectangular document box morphs into oval biometric face guide.
55. `SubmitButtonLoaderToSuccess`: Full-width CTA button shrinks into spinner, then transforms into checkmark.
56. `CascadingDropdownTransition`: Division selection cascades into District dropdown with vertical drop.
57. `UnitConverterSpinTransition`: Property measurement unit toggle (Decimal/Katha) spins 360° on switch.
58. `DraftAutoSaveFlash`: Subtle green border pulse indicating background draft persistence.
59. `PriceSliderBubblePop`: Floating tooltip bubble pops up above slider thumb during drag.
60. `UploadRingToCompleteTransition`: Radial circular progress ring snaps into solid green checkmark.

### Suite 7: GIS, Map & Satellite View Transitions (`gis_map_transitions.dart`)
61. `Map2dTo3dCameraTilt`: Map tilts from 90° top-down to 45° perspective oblique view.
62. `MouzaOverlayCrossfade`: Official government cadastral mouza sheet fades over satellite raster.
63. `PlotBoundaryCenterZoom`: Camera animates smoothly to center and zoom on tapped plot perimeter.
64. `MarkerClusterSplitTransition`: Single cluster marker smoothly splits into individual plot pins.
65. `DrawingCursorToPenMorph`: Map interaction cursor transforms into precision polygon drawing stylus.
66. `RoadToPlotFlipTransition`: Road width perspective flips into parcel boundary view.
67. `CompassNorthHeadingAlign`: Compass needle smoothly springs to magnetic north on tap.
68. `FloodZoneWaterRiseTransition`: Translucent blue flood contour layer rises smoothly from ground level.
69. `LandmarkRadarPinDrop`: Landmark points (schools, hospitals) drop with gravity bounce.
70. `SplitMapListPanelSlide`: Desktop split-view divider slides smoothly between 50/50 and 70/30 layout.

### Suite 8: Media, Gallery & 360 Tour Transitions (`media_gallery_transitions.dart`)
71. `GridToLightboxZoom`: Grid thumbnail expands seamlessly into high-resolution modal image viewer.
72. `BeforeAfterSliderWipe`: Interactive comparison curtain sliding horizontally between raw/developed land.
73. `Panorama360SwipeRotate`: Virtual 360° spherical view rotates smoothly following finger velocity.
74. `DroneVideoThumbnailMorph`: Video thumbnail card morphs directly into active video playback canvas.
75. `FloorPlanLevelSwitch`: Ground floor plan slides out vertically while First Floor plan slides in.
76. `PhotoAlbumCubeTransition`: Swiping photos performs realistic 3D cube rotation transition.
77. `ThumbnailStripReveal`: Gallery bottom thumbnail carousel slides up upon screen tap.
78. `VideoPipMinimizeTransition`: Fullscreen drone video collapses into floating Picture-in-Picture corner widget.
79. `VirtualTourHotspotJump`: Tap on virtual door hotspot zooms into doorway and fades into next room.
80. `SatelliteTimelapseWipe`: Timeline slider animates historic satellite image crossfades across years.

### Suite 9: Financial, Escrow & Payment Transitions (`finance_payment_transitions.dart`)
81. `BajnaToEscrowLockTransition`: Token contract card slides smoothly into heavy locked escrow vault container.
82. `PaymentMethodRadioBounce`: bKash/Nagad/Bank radio button bounces elastically when selected.
83. `CommissionFilterCurtainDrop`: Officer commission filter bar unrolls downwards like a silk curtain.
84. `DigitalReceiptPaperUnfold`: Payment receipt expands vertically with subtle skeuomorphic paper unfolding creases.
85. `TokenCountdownPulse`: Escrow holding countdown timer pulses softly as expiration approaches.
86. `WalletBalanceCreditRoll`: Digital wallet balance digits roll upwards like an odometer on payment credit.
87. `RefundReverseArrowTransition`: Green forward transaction arrow flips into red reverse refund arrow.
88. `InstallmentScheduleCardFlip`: EMI installment card flips horizontally to reveal payment history.
89. `TaxSummarySlideUpDrawer`: Government stamp duty and registration tax summary slides up from bottom.
90. `PaymentConfirmationShieldGlow`: Completed payment badge emits golden radial glow with particle burst.

### Suite 10: Admin, Role-Switch & Auth Transitions (`admin_auth_transitions.dart`)
91. `BuyerToSellerFlipTransition`: App shell performs full 360° vertical card flip when switching user roles.
92. `AdminTabSlidingUnderline`: Admin control tab indicator smoothly slides under active navigation tab.
93. `OtpPinAutoFocusHop`: OTP input cursor springs to next input box automatically upon single-digit entry.
94. `BiometricScanWaveTransition`: Fingerprint sensor visual emits concentric ripple waves during authentication.
95. `InactivitySessionBlurTransition`: Inactive screen gently blurs and displays security re-authentication prompt.
96. `DocumentRejectFlagDrop`: Officer document rejection flag drops into place with red warning vibration.
97. `PermissionToggleMorph`: User permission toggle switch morphs icon from lock to key.
98. `LogoutReverseZoomTransition`: Dashboard zooms out and fades to clean login screen on logout.
99. `OledSunToMoonCircularReveal`: Sun icon morphs into crescent moon while dark palette blooms radially.
100. `SystemMaintenanceBannerSlide`: Emergency administrative announcement banner slides down from top app bar.

---

## 6. Architectural & API Standards (Builder Check Decisions)

1. **Integration Scope:**
   - Standalone design-system transition framework under `lib/core/animations/transitions/` with dedicated automated unit/widget tests in `test/transitions/`.
   - Zero modifications to existing feature screens during initial library construction, guaranteeing 100% safety and zero regression risk across the platform.

2. **Suite 1 Route Contract:**
   - Concrete `PageRouteBuilder<T>` classes (e.g. `Navigator.push(context, SharedAxisSlideRoute(page: ...))`).
   - Each class also provides a static `Widget buildTransition(BuildContext, Animation<double>, Animation<double>, Widget)` to enable plugging into GoRouter or standard routes if needed.
   - For `CircularClipRevealRoute`, an optional `Offset? epicenter` parameter is accepted, defaulting to the viewport center.

3. **Suite 3 Shared-Element Morphs:**
   - Implemented as declarative in-place expandable morphs accepting `collapsedChild`, `expandedChild`, and `isExpanded` boolean state, while optionally accepting a `heroTag` string for pairing across separate routes.

4. **Animation Driver Model for Suites 2 and 4–10:**
   - Declarative state widgets (`TweenAnimationBuilder`, `AnimatedContainer`, `AnimatedScale`, `AnimatedOpacity`) driven by simple boolean/numerical inputs.
   - Modals in Suite 2 provide static `.show(context, ...)` helper methods alongside the embeddable transition widget.

---

## 7. Verification & Testing Strategy

- **10 Modular Test Files:** Every suite has a corresponding test file in `test/transitions/`:
  - `route_navigation_transitions_test.dart`
  - `modal_dialog_transitions_test.dart`
  - `shared_element_transitions_test.dart`
  - `sheet_drawer_transitions_test.dart`
  - `state_micro_transitions_test.dart`
  - `form_wizard_transitions_test.dart`
  - `gis_map_transitions_test.dart`
  - `media_gallery_transitions_test.dart`
  - `finance_payment_transitions_test.dart`
  - `admin_auth_transitions_test.dart`
- **Execution & Quality Gates:**
  - `cd frontend && flutter test` passes with 100% passing tests (existing 100 tests + 100 new tests = 200 total).
  - `cd frontend && flutter analyze --no-fatal-infos` yields 0 warnings/errors.
  - `cd backend && mvn test` passes (9/9 tests).
  - `cd frontend && flutter build web --release` builds cleanly without warnings.

---

## 8. What's Left to the Implementer
- Exact duration tuning (defaulting to 250ms–350ms for micro-interactions, 350ms–450ms for full-screen route shifts).
- Cubic Bezier curve selection (`Curves.fastOutSlowIn`, `Curves.easeOutCubic`, `Curves.elasticOut`).
- Bengali number formatters and localized labels across financial and multi-step forms.
