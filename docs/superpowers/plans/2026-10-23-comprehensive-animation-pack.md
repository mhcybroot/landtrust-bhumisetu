# Comprehensive 20-Animation Suite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all 20 brainstormed real-estate marketplace animations as modular, native, zero-dependency Flutter primitives, organized into 4 focused modules with comprehensive tests.

**Architecture & Constraints:**
- Zero new third-party packages in `pubspec.yaml`.
- Strictly enforce line counts $\le 200$ lines for every modified and created `.dart` file.
- Strictly maintain 0 warnings on `flutter analyze --no-fatal-infos`.
- Verify with unit and widget tests after each task.

---

### Task 1: Module 1 — Media & Browsing Suite

**Files to create/modify:**
- `frontend/lib/core/animations/media_browsing_animations.dart` ($\le 190$ lines)
- `frontend/test/media_browsing_animations_test.dart` ($\le 150$ lines)

- [ ] **Step 1.1:** Write the failing widget tests in `frontend/test/media_browsing_animations_test.dart` for:
  - `WormPageIndicator` (renders dots and expands active dot into pill)
  - `SmartInteractiveZoom` (handles double tap to scale to 2.5x)
  - `BeforeAfterSlider` (renders split view with drag handle)
  - `TiltParallaxWrapper` (handles hover pointer offset)
- [ ] **Step 1.2:** Implement `frontend/lib/core/animations/media_browsing_animations.dart`.
- [ ] **Step 1.3:** Run `cd frontend && flutter test test/media_browsing_animations_test.dart` and confirm all tests pass.
- [ ] **Step 1.4:** Check line counts: `wc -l frontend/lib/core/animations/media_browsing_animations.dart frontend/test/media_browsing_animations_test.dart` ($\le 200$).
- [ ] **Step 1.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add media and browsing animation suite"`

---

### Task 2: Module 2 — Form, Validation & Security Feedback Suite

**Files to create/modify:**
- `frontend/lib/core/animations/form_feedback_animations.dart` ($\le 190$ lines)
- `frontend/test/form_feedback_animations_test.dart` ($\le 150$ lines)

- [ ] **Step 2.1:** Write failing tests in `frontend/test/form_feedback_animations_test.dart` for:
  - `ErrorShakeAnimation` (shakes horizontally on trigger)
  - `PasswordEyeMorph` (toggles eye open/closed icon with crossfade)
  - `StepPulseIndicator` (displays step number, pulse ring, or checkmark)
  - `MorphingFabTrigger` (expands on press)
- [ ] **Step 2.2:** Implement `frontend/lib/core/animations/form_feedback_animations.dart`.
- [ ] **Step 2.3:** Run `cd frontend && flutter test test/form_feedback_animations_test.dart` and confirm all tests pass.
- [ ] **Step 2.4:** Check line counts: `wc -l frontend/lib/core/animations/form_feedback_animations.dart frontend/test/form_feedback_animations_test.dart` ($\le 200$).
- [ ] **Step 2.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add form validation and security feedback animation suite"`

---

### Task 3: Module 3 — Card, Document & List Micro-Interactions

**Files to create/modify:**
- `frontend/lib/core/animations/card_document_animations.dart` ($\le 190$ lines)
- `frontend/test/card_document_animations_test.dart` ($\le 150$ lines)

- [ ] **Step 3.1:** Write failing tests in `frontend/test/card_document_animations_test.dart` for:
  - `HeartBurstAnimation` (renders heart and emits particles on tap)
  - `AccordionTile` (smoothly expands and collapses content)
  - `SwipeActionReveal` (slides child to reveal action background)
  - `CompassRefreshSpinner` (rotates compass needle)
- [ ] **Step 3.2:** Implement `frontend/lib/core/animations/card_document_animations.dart`.
- [ ] **Step 3.3:** Run `cd frontend && flutter test test/card_document_animations_test.dart` and confirm all tests pass.
- [ ] **Step 3.4:** Check line counts: `wc -l frontend/lib/core/animations/card_document_animations.dart frontend/test/card_document_animations_test.dart` ($\le 200$).
- [ ] **Step 3.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add card, document and list animation suite"`

---

### Task 4: Module 4 — Financial, Messaging & Celebration Suite

**Files to create/modify:**
- `frontend/lib/core/animations/delight_financial_animations.dart` ($\le 195$ lines)
- `frontend/test/delight_financial_animations_test.dart` ($\le 160$ lines)

- [ ] **Step 4.1:** Write failing tests in `frontend/test/delight_financial_animations_test.dart` for:
  - `ChatTypingWave` (animates 3 oscillating dots)
  - `MessageFlightCurve` (fades and slides sent message upwards)
  - `RadialGaugeFill` (draws circular arc matching percentage value)
  - `RollingDigitCounter` (animates value change vertically)
  - `CommissionSplitBar` (animates 3 proportional slices 70/20/10)
  - `CoinDropVisual` (animates falling coin)
  - `BottomNavBubbleJump` (animates selected bubble bounce)
  - `ConfettiCelebration` (renders canvas particle rain)
- [ ] **Step 4.2:** Implement `frontend/lib/core/animations/delight_financial_animations.dart`.
- [ ] **Step 4.3:** Run `cd frontend && flutter test test/delight_financial_animations_test.dart` and confirm all tests pass.
- [ ] **Step 4.4:** Check line counts: `wc -l frontend/lib/core/animations/delight_financial_animations.dart frontend/test/delight_financial_animations_test.dart` ($\le 200$).
- [ ] **Step 4.5:** Commit: `git add frontend/ && git commit -m "feat(animations): add financial, messaging, and celebration animation suite"`

---

### Task 5: Full Test Suite, Analyzer Verification, and Web Release Build

- [ ] **Step 5.1:** Run all frontend tests: `cd frontend && flutter test`.
- [ ] **Step 5.2:** Run linter: `cd frontend && flutter analyze --no-fatal-infos`.
- [ ] **Step 5.3:** Run backend tests: `cd backend && mvn test`.
- [ ] **Step 5.4:** Compile web release: `cd frontend && flutter build web --release`.
- [ ] **Step 5.5:** Whole-branch review and merge into `main`.
