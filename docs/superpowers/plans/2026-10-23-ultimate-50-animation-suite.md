# Ultimate 50-Animation Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the complete 50-animation real-estate marketplace suite across 5 cohesive, high-leverage modules (10 animations each) with zero external packages, strictly $\le 200$ lines per file, zero linter warnings, and comprehensive automated test coverage.

---

### Task 1: Module 1 — GIS, Map & Plot Boundary Suite

**Files to create:**
- `frontend/lib/core/animations/gis_plot_animations.dart` ($\le 195$ lines)
- `frontend/test/gis_plot_animations_test.dart` ($\le 120$ lines)

- [ ] **Step 1.1:** Write failing tests in `frontend/test/gis_plot_animations_test.dart` for all 10 GIS animations:
  - `PlotBoundaryTracer`, `RoadWidthTape`, `CompassNorthLock`, `GpsPinDropBounce`, `LandmarkRadarWave`
  - `MouzaSheetOverlay`, `ElevationProfileBar`, `FloodLevelWave`, `SunShadowSweep`, `CornerPillarFlip`
- [ ] **Step 1.2:** Implement `frontend/lib/core/animations/gis_plot_animations.dart`.
- [ ] **Step 1.3:** Run `cd frontend && flutter test test/gis_plot_animations_test.dart` and confirm all tests pass.
- [ ] **Step 1.4:** Check line counts: `wc -l frontend/lib/core/animations/gis_plot_animations.dart frontend/test/gis_plot_animations_test.dart` ($\le 200$).
- [ ] **Step 1.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add GIS map and plot boundary animation module"`

---

### Task 2: Module 2 — Legal, Khatiyan & Verification Suite

**Files to create:**
- `frontend/lib/core/animations/legal_verification_animations.dart` ($\le 195$ lines)
- `frontend/test/legal_verification_animations_test.dart` ($\le 120$ lines)

- [ ] **Step 2.1:** Write failing tests in `frontend/test/legal_verification_animations_test.dart` for all 10 Legal animations:
  - `TrustSealStamp`, `KhatiyanPageCurl`, `OwnershipChainTree`, `DocumentScannerLaser`, `WatermarkSheenWave`
  - `DeedRibbonUnfurl`, `QrCodeScanFrame`, `InjunctionWarningBeacon`, `MutationLedgerFlip`, `DigitalSignatureStroke`
- [ ] **Step 2.2:** Implement `frontend/lib/core/animations/legal_verification_animations.dart`.
- [ ] **Step 2.3:** Run `cd frontend && flutter test test/legal_verification_animations_test.dart` and confirm all tests pass.
- [ ] **Step 2.4:** Check line counts: `wc -l frontend/lib/core/animations/legal_verification_animations.dart frontend/test/legal_verification_animations_test.dart` ($\le 200$).
- [ ] **Step 2.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add legal khatiyan and verification animation module"`

---

### Task 3: Module 3 — Finance, Escrow & Payment Suite

**Files to create:**
- `frontend/lib/core/animations/finance_escrow_animations.dart` ($\le 195$ lines)
- `frontend/test/finance_escrow_animations_test.dart` ($\le 120$ lines)

- [ ] **Step 3.1:** Write failing tests in `frontend/test/finance_escrow_animations_test.dart` for all 10 Finance animations:
  - `EscrowVaultLock`, `BankNoteCounter`, `DepositShieldPulse`, `TaxBreakdownSplit`, `MilestonePathGlow`
  - `RefundReversalArrow`, `LedgerSlideEntry`, `CashbackGlowRipple`, `InvoiceProgressBar`, `FeeSpeedoMeter`
- [ ] **Step 3.2:** Implement `frontend/lib/core/animations/finance_escrow_animations.dart`.
- [ ] **Step 3.3:** Run `cd frontend && flutter test test/finance_escrow_animations_test.dart` and confirm all tests pass.
- [ ] **Step 3.4:** Check line counts: `wc -l frontend/lib/core/animations/finance_escrow_animations.dart frontend/test/finance_escrow_animations_test.dart` ($\le 200$).
- [ ] **Step 3.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add finance escrow and payment animation module"`

---

### Task 4: Module 4 — Field Visits & Live Communication Suite

**Files to create:**
- `frontend/lib/core/animations/field_visit_animations.dart` ($\le 195$ lines)
- `frontend/test/field_visit_animations_test.dart` ($\le 120$ lines)

- [ ] **Step 4.1:** Write failing tests in `frontend/test/field_visit_animations_test.dart` for all 10 Visit & Communication animations:
  - `GpsVehicleMove`, `VoiceNoteWaveform`, `AppointmentCalendarFlip`, `ReadReceiptCheckMorph`, `BannerNoticeBounce`
  - `OfficerStarRatingFill`, `VideoCallHalo`, `EmojiReactionFloat`, `VisitChecklistCircle`, `CtaRippleWave`
- [ ] **Step 4.2:** Implement `frontend/lib/core/animations/field_visit_animations.dart`.
- [ ] **Step 4.3:** Run `cd frontend && flutter test test/field_visit_animations_test.dart` and confirm all tests pass.
- [ ] **Step 4.4:** Check line counts: `wc -l frontend/lib/core/animations/field_visit_animations.dart frontend/test/field_visit_animations_test.dart` ($\le 200$).
- [ ] **Step 4.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add field visit and live communication animation module"`

---

### Task 5: Module 5 — Luxury UI, OLED Dark & Micro-Interactions Suite

**Files to create:**
- `frontend/lib/core/animations/luxury_ui_animations.dart` ($\le 195$ lines)
- `frontend/test/luxury_ui_animations_test.dart` ($\le 120$ lines)

- [ ] **Step 5.1:** Write failing tests in `frontend/test/luxury_ui_animations_test.dart` for all 10 UI animations:
  - `ThemeCircularReveal`, `OledDarkShimmer`, `ComparisonDrawerMorph`, `FilterFrostedBlur`, `BouncyCheckbox`
  - `NotificationBellJingle`, `EmptyStateFloat`, `HeaderElevationFade`, `MemberLevelUpGlow`, `PagePopSlide`
- [ ] **Step 5.2:** Implement `frontend/lib/core/animations/luxury_ui_animations.dart`.
- [ ] **Step 5.3:** Run `cd frontend && flutter test test/luxury_ui_animations_test.dart` and confirm all tests pass.
- [ ] **Step 5.4:** Check line counts: `wc -l frontend/lib/core/animations/luxury_ui_animations.dart frontend/test/luxury_ui_animations_test.dart` ($\le 200$).
- [ ] **Step 5.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add luxury UI and micro-interactions animation module"`

---

### Task 6: Full Verification, Analyzer Check, and Web Release Build

- [ ] **Step 6.1:** Run all frontend tests: `cd frontend && flutter test`.
- [ ] **Step 6.2:** Run linter: `cd frontend && flutter analyze --no-fatal-infos`.
- [ ] **Step 6.3:** Run backend tests: `cd backend && mvn test`.
- [ ] **Step 6.4:** Compile web release: `cd frontend && flutter build web --release`.
- [ ] **Step 6.5:** Whole-branch review and merge into `main`.
