# Advanced Micro-Animations Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 5 advanced micro-animations across LandApp (bdHousing): Trust Shield Sheen, Animated Success Dialog, Live Pulse Beacon, Sliding Category Pill Bar, and Hero Image Transitions.

**Architecture & Constraints:**
- Zero new third-party packages in `pubspec.yaml`.
- Strictly enforce line counts $\le 200$ lines for every modified and created `.dart` file.
- Strictly maintain 0 warnings on `flutter analyze --no-fatal-infos`.
- Verify with unit/widget tests after each task.

---

### Task 1: `SheenSweepEffect` & Verification Badge Sheen Integration

**Files to create/modify:**
- `frontend/lib/core/animations/sheen_sweep_effect.dart` ($\le 85$ lines)
- `frontend/lib/core/widgets/status_badge.dart` ($\le 160$ lines)
- `frontend/test/advanced_animations_test.dart` ($\le 180$ lines)

- [ ] **Step 1.1:** Write the failing widget tests in `frontend/test/advanced_animations_test.dart` testing `SheenSweepEffect` rendering and `VerificationBadge` with sheen animation.
- [ ] **Step 1.2:** Create `frontend/lib/core/animations/sheen_sweep_effect.dart` using `ShaderMask` and an `AnimationController` that sweeps a 45-degree highlight periodically.
- [ ] **Step 1.3:** In `frontend/lib/core/widgets/status_badge.dart`, wrap verified badges (`APPROVED_PUBLISHED` / `VERIFIED`) with `SheenSweepEffect`.
- [ ] **Step 1.4:** Run `cd frontend && flutter test test/advanced_animations_test.dart` and confirm tests pass.
- [ ] **Step 1.5:** Check line counts: `wc -l frontend/lib/core/animations/sheen_sweep_effect.dart frontend/lib/core/widgets/status_badge.dart frontend/test/advanced_animations_test.dart` (all $\le 200$).
- [ ] **Step 1.6:** Commit: `git add frontend/ && git commit -m "feat(animations): add SheenSweepEffect and wire into VerificationBadge"`

---

### Task 2: `AnimatedSuccessDialog` with Custom Drawn Checkmark

**Files to create/modify:**
- `frontend/lib/core/widgets/animated_success_dialog.dart` ($\le 140$ lines)
- `frontend/test/advanced_animations_test.dart`

- [ ] **Step 2.1:** Add widget test in `frontend/test/advanced_animations_test.dart` verifying `AnimatedSuccessDialog.show(context, ...)` renders with title, message, and animated checkmark.
- [ ] **Step 2.2:** Create `frontend/lib/core/widgets/animated_success_dialog.dart`:
  - Expanding circle ring with pulse wave.
  - `CustomPainter` that draws the checkmark stroke progressively from 0.0 to 1.0 using `PathMetric.extractPath`.
  - Static helper `AnimatedSuccessDialog.show(BuildContext context, {required String title, required String message, VoidCallback? onConfirm})`.
- [ ] **Step 2.3:** Run `cd frontend && flutter test test/advanced_animations_test.dart` and verify tests pass.
- [ ] **Step 2.4:** Check line counts: `wc -l frontend/lib/core/widgets/animated_success_dialog.dart` ($\le 200$).
- [ ] **Step 2.5:** Commit: `git add frontend/lib/core/widgets/animated_success_dialog.dart frontend/test/advanced_animations_test.dart && git commit -m "feat(ui): add AnimatedSuccessDialog with animated drawn checkmark"`

---

### Task 3: `PulseBeaconIndicator` for Live Online Status & Hot Deals

**Files to create/modify:**
- `frontend/lib/core/animations/pulse_beacon_indicator.dart` ($\le 85$ lines)
- `frontend/lib/modules/marketplace/widgets/property_card_widget.dart` ($\le 200$ lines)
- `frontend/test/advanced_animations_test.dart`

- [ ] **Step 3.1:** Add widget test in `frontend/test/advanced_animations_test.dart` for `PulseBeaconIndicator`.
- [ ] **Step 3.2:** Create `frontend/lib/core/animations/pulse_beacon_indicator.dart` rendering a solid center dot surrounded by 2 radiating and fading pulse rings (`Curves.easeOutQuad`).
- [ ] **Step 3.3:** In `frontend/lib/modules/marketplace/widgets/property_card_widget.dart`, add a `PulseBeaconIndicator` next to the "ভিডিও" or featured indicator.
- [ ] **Step 3.4:** Run `cd frontend && flutter test test/advanced_animations_test.dart` and verify all tests pass.
- [ ] **Step 3.5:** Check line count of `property_card_widget.dart` ($\le 200$).
- [ ] **Step 3.6:** Commit: `git add frontend/lib/core/animations/pulse_beacon_indicator.dart frontend/lib/modules/marketplace/widgets/property_card_widget.dart frontend/test/advanced_animations_test.dart && git commit -m "feat(animations): add PulseBeaconIndicator and integrate on featured badges"`

---

### Task 4: `SlidingPillBar` for Category Filtering & Hero Image Transitions

**Files to create/modify:**
- `frontend/lib/core/widgets/sliding_pill_bar.dart` ($\le 120$ lines)
- `frontend/lib/modules/marketplace/widgets/property_card_widget.dart` ($\le 200$ lines)
- `frontend/test/advanced_animations_test.dart`

- [ ] **Step 4.1:** Add widget test in `frontend/test/advanced_animations_test.dart` verifying `SlidingPillBar` tab switching and animated pill position.
- [ ] **Step 4.2:** Create `frontend/lib/core/widgets/sliding_pill_bar.dart` using `LayoutBuilder` and `AnimatedAlign` to smoothly glide an emerald pill capsule behind the selected tab.
- [ ] **Step 4.3:** In `frontend/lib/modules/marketplace/widgets/property_card_widget.dart`, wrap `SmartImageViewer` in `Hero(tag: 'property-hero-${listing['id']}', child: ...)`.
- [ ] **Step 4.4:** Run `cd frontend && flutter test test/advanced_animations_test.dart` and verify all tests pass.
- [ ] **Step 4.5:** Check line counts: `wc -l frontend/lib/core/widgets/sliding_pill_bar.dart frontend/lib/modules/marketplace/widgets/property_card_widget.dart` ($\le 200$).
- [ ] **Step 4.6:** Commit: `git add frontend/lib/core/widgets/sliding_pill_bar.dart frontend/lib/modules/marketplace/widgets/property_card_widget.dart frontend/test/advanced_animations_test.dart && git commit -m "feat(ui): add SlidingPillBar and Hero image transition tag"`

---

### Task 5: Full Test Suite, Analyzer Verification, and Web Release Build

- [ ] **Step 5.1:** Run all frontend tests: `cd frontend && flutter test`.
- [ ] **Step 5.2:** Run linter: `cd frontend && flutter analyze --no-fatal-infos`.
- [ ] **Step 5.3:** Run backend tests: `cd backend && mvn test`.
- [ ] **Step 5.4:** Compile web release: `cd frontend && flutter build web --release`.
- [ ] **Step 5.5:** Verify live web preview at `http://localhost:8086`.
