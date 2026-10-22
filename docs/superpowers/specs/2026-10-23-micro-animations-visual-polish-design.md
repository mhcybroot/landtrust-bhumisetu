# Micro-Animations & Visual Polish Design Document

**Date:** 2026-10-23  
**Status:** In Review / Approved by Partner  
**Target Architecture:** Flutter 3.33+ / Dart 3.5+  
**Selected Approach:** Approach 1 — Pure Native Flutter (Zero External Dependencies)

---

## 1. Intent & The Why

The core functionality, business logic, security, and responsive layouts of the LandApp (bdHousing) are fully implemented and verified. However, static metric transitions, sudden image pop-ins, and plain loading spinners give the app an overly mechanical feel. 

By introducing lightweight, buttery-smooth micro-animations (animated count-up metrics, shimmering skeleton card placeholders, interactive hover-lift/press feedback, and frosted glass translucency), the platform will feel alive, modern, and trustworthy (reminiscent of top-tier consumer apps like Airbnb and Apple Design Award winners) without sacrificing performance or adding bundle bloat.

---

## 2. Goals, Non-Goals, & Anti-Goals

### Goals
- **Buttery 60/120 FPS Performance:** All animations must execute smoothly on low-end Android mobile devices and Chrome/Safari web without frame drops.
- **Zero Third-Party Animation Dependencies:** Leverage only Flutter's built-in animation primitives (`AnimationController`, `TweenAnimationBuilder`, `ShaderMask`, `BackdropFilter`, `MouseRegion`, `Transform`).
- **Dynamic Count-Up Numbers:** Animate numbers in dashboard stats cards (`HomeStatsRow`, `StatCardWidget`, Admin/Officer stats) from 0 to the target value with ease-out curves upon appearing.
- **Web Hover Lift & Mobile Touch Response:** Provide tactile feedback—desktop cards smoothly lift (-4px) with deeper shadow; mobile elements spring-scale (0.97x).
- **Graceful Network Image Loading:** Add smooth fade-in and shimmer placeholder to `SmartImageViewer` during image network download.
- **Web Skeleton Loading Grid:** In `HomeMarketplaceWebView`, replace generic circular progress spinners with a responsive grid of `ShimmerCardPlaceholder` widgets during data retrieval.
- **Strict Project Health:** Maintain zero linter warnings (`flutter analyze --no-fatal-infos`) and keep all `.dart` files $\le 200$ lines.

### Non-Goals
- Adding heavy Lottie JSON animation files or 3D canvas renderers.
- Over-animating every element (which leads to visual fatigue and reduced accessibility).
- Redesigning existing database schemas or backend APIs.

### Anti-Goals
- Adding external packages like `flutter_animate` or `shimmer` that could lead to version mismatches with newer Flutter SDKs.
- Creating blocking animations that delay user navigation or form submissions.

---

## 3. Constraints

- **Language & SDK:** Dart 3.5+, Flutter 3.33+.
- **File Length Constraint:** Every modified and newly created `.dart` file must strictly stay $\le 200$ lines.
- **Zero Linter Warning Policy:** Must pass `flutter analyze --no-fatal-infos` with 0 issues.
- **Accessibility:** Animation durations kept concise (150ms–800ms) with gentle easing (`Curves.easeOutCubic`).
- **Ponytail Rule:** Solve the problem with the least new code. Re-use existing components (`ShimmerEffect`, `StaggeredSlideFade`, `BouncingPressable`) rather than duplicating.

---

## 4. Approaches Considered & Tradeoffs

### Approach 1 (Selected): Pure Native Flutter Primitives (Zero Dependencies)
- **Description:** Implement custom lightweight widgets (`AnimatedCountText`, `HoverLiftCard`, `FrostedGlassContainer`) using native Flutter classes: `TweenAnimationBuilder`, `MouseRegion`, `BackdropFilter`. Wire existing `ShimmerCardPlaceholder` and `StaggeredSlideFade` into web and stats views.
- **Pros:** 0KB added bundle size, zero third-party dependency conflicts, rock-solid 60/120 FPS performance, complete styling control.
- **Tradeoffs:** Requires writing ~150 lines of tested utility code.
- **Decision:** Picked by partner for maximum performance, clean codebase, and zero bloat.

### Approach 2: Third-Party Animation Libraries (`flutter_animate` + `shimmer`)
- **Description:** Add `flutter_animate` and `shimmer` to `pubspec.yaml` and chain animations.
- **Pros:** Fast declarative chaining syntax.
- **Cons:** External dependency baggage, risk of breaking in future Flutter updates, violates Ponytail simplicity principles.
- **Decision:** Rejected.

### Approach 3: Lottie Vector Animations
- **Description:** Bundle `.json` animation files for empty states, loaders, and badges.
- **Pros:** Cartoon/vector visual flair.
- **Cons:** Significantly increases bundle size, high RAM and CPU usage on low-end phones and web.
- **Decision:** Rejected.

---

## 5. Architectural Specification & Components

### 5.1 `AnimatedCountText` (`frontend/lib/core/animations/animated_count_text.dart`)
- **Purpose:** Parse formatted strings like `"45 টি"`, `"৳ 1,50,000"`, `"14 জন"` or plain integers, and smoothly count up from 0 to the target number over 750ms.
- **Implementation:** `ImplicitlyAnimatedWidget` or `StatefulWidget` with `TweenAnimationBuilder<double>`.
- **Formatting:** Preserves non-numeric prefixes (e.g. `"৳ "`) and suffixes (e.g. `" টি"`, `" জন"`), formats numbers with locale or commas.

### 5.2 `HoverLiftCard` (`frontend/lib/core/animations/hover_lift_card.dart`)
- **Purpose:** Responsive hover & touch wrapper. On desktop/web mouse hover: smoothly translates `Offset(0, -4)` with enhanced ambient shadow. On touch/click: springs down to `0.975` scale via `BouncingPressable`.
- **Implementation:** Combines `MouseRegion`, `AnimatedContainer`, and `GestureDetector` / `BouncingPressable`.

### 5.3 `FrostedGlassContainer` (`frontend/lib/core/widgets/frosted_glass_container.dart`)
- **Purpose:** Reusable glassmorphic card/header container.
- **Implementation:** `ClipRRect` wrapping `BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10))` with translucent fill (`color.withValues(alpha: 0.15)`) and delicate 1px border.

### 5.4 Screen & Widget Enhancements
1. **`SmartImageViewer` (`frontend/lib/core/widgets/smart_image_viewer.dart`):**
   - Add `frameBuilder` to `Image.network` and `Image.memory` with smooth fade-in curve and shimmer placeholder while loading.
2. **`StatCardWidget` (`frontend/lib/core/widgets/status_badge.dart`):**
   - Replace static value text with `AnimatedCountText`.
3. **`HomeMarketplaceWebView` (`frontend/lib/modules/marketplace/views/web/home_marketplace_web_view.dart`):**
   - Show responsive grid of 6 `ShimmerCardPlaceholder` widgets during `isLoading == true`.
   - Wrap loaded listings in `StaggeredSlideFade` with `HoverLiftCard`.
4. **`PropertyCardWidget` (`frontend/lib/modules/marketplace/widgets/property_card_widget.dart`):**
   - Wrap card in `HoverLiftCard` for delightful desktop interaction.

---

## 6. Verification & Automated Testing Plan

1. **Unit & Widget Tests (`frontend/test/micro_animations_test.dart`):**
   - Test `AnimatedCountText` parses prefix, number, and suffix accurately and increments.
   - Test `HoverLiftCard` handles hover enter/exit without crashing.
   - Test `FrostedGlassContainer` renders child with blur filter.
2. **Linter Verification:**
   - Run `flutter analyze --no-fatal-infos` — must report 0 issues.
3. **Line Count Verification:**
   - All touched and new `.dart` files verified with `wc -l` $\le 200$.
4. **End-to-End Build Verification:**
   - Execute `flutter build web --release` to ensure compilation and assets integrity.
