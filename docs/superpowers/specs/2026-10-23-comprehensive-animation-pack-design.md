# Comprehensive Animation Pack Design Document

**Date:** 2026-10-23  
**Status:** In Review / Approved by Partner  
**Target Architecture:** Flutter 3.33+ / Dart 3.5+  
**Execution Mode:** `executing-plans` (Inline Execution) with `ponytail` (Minimal, highly-leveraged native code)

---

## 1. Intent & Scope

This package implements the 20 real estate marketplace animations brainstormed with the partner, synthesized into 5 highly-leveraged, zero-dependency native Flutter animation modules:

1. **Module 1: Media & Browsing Suite**
   - `WormPageIndicator`: Expanding rubber dot pager for property photo carousels.
   - `SmartInteractiveZoom`: Double-tap 2.5x spring zoom for plot maps and khatiyan scans.
   - `BeforeAfterSlider`: Interactive drag split comparison for land development.
   - `TiltParallaxWrapper`: Pointer/gyro micro-tilt depth effect on property images.

2. **Module 2: Form Feedback & Security Suite**
   - `ErrorShakeAnimation`: 3-cycle horizontal shake for form errors and empty required fields.
   - `PasswordEyeMorph`: Eye blink animation for password reveal/hide.
   - `StepPulseIndicator`: Pulse ring on the active form step with completion checkmark.
   - `MorphingFabTrigger`: Expanding circle animation for adding new listings.

3. **Module 3: Card & Document Micro-Interactions**
   - `HeartBurstAnimation`: Gold/emerald particle burst on bookmarking a property.
   - `AccordionTile`: Zero-jank spring expander for legal documents (CS, SA, RS khatiyan).
   - `SwipeActionReveal`: Directional swipe with color reveal for notifications.
   - `CompassRefreshSpinner`: Thematic rotating land compass for pull-to-refresh.

4. **Module 4: Financial, Messaging & Celebration Suite**
   - `ChatTypingWave`: 3-dot harmonic wave for officer live chat typing.
   - `MessageFlightCurve`: Floating flight curve transition for sent chat messages.
   - `RadialGaugeFill`: Animated circular percentage fill for tax & fee breakdown.
   - `RollingDigitCounter`: Vertical roll transition for price-per-decimal metrics.
   - `CommissionSplitBar`: Animated proportional bars (70%/20%/10%) for officer earnings.
   - `CoinDropVisual`: Gold coin drop animation for wallet top-ups.
   - `BottomNavBubbleJump`: Floating bubble jump on bottom navigation switches.
   - `ConfettiCelebration`: Lightweight canvas particle burst for verified listing approvals.

---

## 2. Technical Constraints

- **Pure Native Flutter Primitives:** `CustomPainter`, `AnimationController`, `AnimatedContainer`, `Transform`, `ShaderMask`. Zero new packages in `pubspec.yaml`.
- **Line Count Cap:** Every `.dart` file strictly $\le 200$ lines.
- **Zero Warnings:** Pass `flutter analyze --no-fatal-infos` with 0 issues.
- **Automated Verification:** Unit & widget tests for every component.
