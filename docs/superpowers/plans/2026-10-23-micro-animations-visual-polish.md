# Micro-Animations & Visual Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Elevate the visual appeal, interactivity, and perceived responsiveness of the LandApp (bdHousing) with native, zero-dependency micro-animations: animated count-up metrics, tactile hover-lift/press feedback, frosted glass styling, and smooth image/shimmer skeleton loading.

**Architecture & Constraints:**
- Pure Native Flutter primitives (`TweenAnimationBuilder`, `MouseRegion`, `BackdropFilter`, `ShaderMask`, `ClipRRect`). Zero new dependencies in `pubspec.yaml`.
- Strictly enforce line counts $\le 200$ lines for every modified and created `.dart` file.
- Strictly maintain zero linter warnings on `flutter analyze --no-fatal-infos`.
- Fully preserve Bengali localization and responsive layouts.

---

### Task 1: Core Animation Primitives (`AnimatedCountText`, `HoverLiftCard`, `FrostedGlassContainer`)

**Files to create:**
- `frontend/lib/core/animations/animated_count_text.dart` ($\le 95$ lines)
- `frontend/lib/core/animations/hover_lift_card.dart` ($\le 90$ lines)
- `frontend/lib/core/widgets/frosted_glass_container.dart` ($\le 70$ lines)
- `frontend/test/micro_animations_test.dart` ($\le 160$ lines)

- [ ] **Step 1.1:** Write the failing unit and widget tests in `frontend/test/micro_animations_test.dart` testing:
  - `AnimatedCountText` parses prefix, suffix, and numeric values (e.g. `"45 টি"`, `"৳ 1,50,000"`, `"14 জন"`), animating up from 0.
  - `HoverLiftCard` renders child and responds to hover state.
  - `FrostedGlassContainer` renders child with blur filter and border.
- [ ] **Step 1.2:** Run `cd frontend && flutter test test/micro_animations_test.dart` and confirm tests fail as files do not exist yet.
- [ ] **Step 1.3:** Create `frontend/lib/core/animations/animated_count_text.dart` using `TweenAnimationBuilder<double>` with `Curves.easeOutCubic`, parsing prefixes (e.g., `"৳ "`), numeric values, and suffixes (e.g., `" টি"`, `" জন"`).
- [ ] **Step 1.4:** Create `frontend/lib/core/animations/hover_lift_card.dart` with `MouseRegion` for desktop hover translateY (-4px) + elevation shadow, and `BouncingPressable` for mobile touch springs.
- [ ] **Step 1.5:** Create `frontend/lib/core/widgets/frosted_glass_container.dart` with `ClipRRect` and `BackdropFilter` (sigma 10).
- [ ] **Step 1.6:** Run `cd frontend && flutter test test/micro_animations_test.dart` and confirm all tests pass.
- [ ] **Step 1.7:** Verify line counts: `wc -l frontend/lib/core/animations/animated_count_text.dart frontend/lib/core/animations/hover_lift_card.dart frontend/lib/core/widgets/frosted_glass_container.dart frontend/test/micro_animations_test.dart` (all must be $\le 200$).
- [ ] **Step 1.8:** Commit: `git add frontend/ && git commit -m "feat(animations): add native animated count, hover lift, and frosted glass primitives"`

---

### Task 2: Graceful Network Image Loading & Shimmer in `SmartImageViewer`

**Files to modify:**
- `frontend/lib/core/widgets/smart_image_viewer.dart` ($\le 120$ lines)
- `frontend/test/micro_animations_test.dart`

- [ ] **Step 2.1:** Add test cases in `frontend/test/micro_animations_test.dart` to verify `SmartImageViewer` handles fallback, memory images, and network image builders.
- [ ] **Step 2.2:** Update `frontend/lib/core/widgets/smart_image_viewer.dart`:
  - Enhance `Image.network` with `frameBuilder` to provide a subtle 300ms fade-in transition when the image finishes loading.
  - Add `loadingBuilder` with `ShimmerEffect` placeholder while bytes are being streamed from network.
- [ ] **Step 2.3:** Run `cd frontend && flutter test test/micro_animations_test.dart` and confirm all tests pass.
- [ ] **Step 2.4:** Run `cd frontend && flutter analyze --no-fatal-infos` and ensure 0 issues.
- [ ] **Step 2.5:** Commit: `git add frontend/lib/core/widgets/smart_image_viewer.dart frontend/test/micro_animations_test.dart && git commit -m "feat(ui): add smooth fade-in and shimmer placeholder to SmartImageViewer"`

---

### Task 3: Stats Row & Metric Cards Count-Up Integration

**Files to modify:**
- `frontend/lib/core/widgets/status_badge.dart` ($\le 160$ lines)
- `frontend/lib/modules/marketplace/widgets/home_stats_row.dart` ($\le 60$ lines)
- `frontend/test/micro_animations_test.dart`

- [ ] **Step 3.1:** Add a widget test in `frontend/test/micro_animations_test.dart` verifying `StatCardWidget` smoothly renders `AnimatedCountText` with values like `'45 টি'` or `'৳ 50,000'`.
- [ ] **Step 3.2:** Update `frontend/lib/core/widgets/status_badge.dart` in `StatCardWidget`:
  - Replace static `Text(value, ...)` with `AnimatedCountText(text: value, style: TextStyle(...))`.
- [ ] **Step 3.3:** Run `cd frontend && flutter test test/micro_animations_test.dart` and verify all tests pass.
- [ ] **Step 3.4:** Check line counts: `wc -l frontend/lib/core/widgets/status_badge.dart` ($\le 200$).
- [ ] **Step 3.5:** Commit: `git add frontend/lib/core/widgets/status_badge.dart frontend/test/micro_animations_test.dart && git commit -m "feat(ui): integrate animated count-up numbers in StatCardWidget"`

---

### Task 4: Web Marketplace Skeleton Loading & Property Card Hover Integration

**Files to modify:**
- `frontend/lib/modules/marketplace/views/web/home_marketplace_web_view.dart` ($\le 200$ lines)
- `frontend/lib/modules/marketplace/widgets/property_card_widget.dart` ($\le 200$ lines)

- [ ] **Step 4.1:** Update `HomeMarketplaceWebView`:
  - Replace `if (vm.isLoading) CircularProgressIndicator()` with a responsive 6-item `ShimmerCardPlaceholder` grid matching the loaded layout.
  - Wrap loaded listings in `StaggeredSlideFade` for a cascaded entrance.
- [ ] **Step 4.2:** Update `PropertyCardWidget`:
  - Wrap the outermost card in `HoverLiftCard(onTap: onDetailsClick)` so web users get a subtle hover translateY (-4px) + deeper shadow, and mobile users get spring touch feedback.
- [ ] **Step 4.3:** Run `cd frontend && flutter analyze --no-fatal-infos` and ensure 0 issues.
- [ ] **Step 4.4:** Check line counts: `wc -l frontend/lib/modules/marketplace/views/web/home_marketplace_web_view.dart frontend/lib/modules/marketplace/widgets/property_card_widget.dart` (both must be $\le 200$).
- [ ] **Step 4.5:** Commit: `git add frontend/lib/modules/marketplace/views/web/home_marketplace_web_view.dart frontend/lib/modules/marketplace/widgets/property_card_widget.dart && git commit -m "feat(ui): integrate skeleton shimmer and hover lift on web marketplace"`

---

### Task 5: Comprehensive Verification, Full Test Suite, and Web Build Release

- [ ] **Step 5.1:** Run all frontend tests: `cd frontend && flutter test`.
- [ ] **Step 5.2:** Run linter: `cd frontend && flutter analyze --no-fatal-infos`.
- [ ] **Step 5.3:** Run backend tests to ensure zero regressions: `cd backend && mvn test`.
- [ ] **Step 5.4:** Compile production web client: `cd frontend && flutter build web --release`.
- [ ] **Step 5.5:** Verify live web preview at `http://localhost:8086`.
- [ ] **Step 5.6:** Final whole-branch review and merge.
