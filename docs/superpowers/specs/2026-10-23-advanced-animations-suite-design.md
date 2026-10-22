# Advanced Micro-Animations Suite Design Document

**Date:** 2026-10-23  
**Status:** In Review / Approved by Partner  
**Target Architecture:** Flutter 3.33+ / Dart 3.5+  
**Selected Approach:** Pure Native Flutter Primitives (Zero External Dependencies)

---

## 1. Intent & The Why

Building upon the baseline micro-animations (shimmer, hover-lift, count-up), this suite introduces 5 purposeful animations to make the LandApp (bdHousing) experience feel premium, reactive, and reassuring:
1. **Trust Shield Sheen Sweep:** Elevates the "যাচাইকৃত" (Verified) badge with periodic golden-green sheen sweeps.
2. **Animated Success Dialog:** Gives users clear visual satisfaction upon submitting inquiries, listings, or payments via an expanding ring and drawn checkmark.
3. **Live Pulse Beacon:** Communicates real-time presence (online officer status, active hot deals) via radiating pulse rings.
4. **Hero Image Morph Transition:** Provides smooth element expansion from listing cards into full details modals.
5. **Sliding Category Tab Pill:** Fluid indicator bar that slides beneath active category choices instead of sudden color cuts.

---

## 2. Goals, Non-Goals, & Anti-Goals

### Goals
- 60/120 FPS performance across web, iOS, and low-end Android devices.
- Pure Flutter framework implementations (`CustomPainter`, `AnimatedContainer`, `Hero`, `AnimationController`, `ShaderMask`). Zero new dependencies in `pubspec.yaml`.
- Strictly enforce $\le 200$ lines per `.dart` file.
- Zero linter warnings (`flutter analyze --no-fatal-infos`).
- Comprehensive unit and widget tests for each new component.

### Non-Goals
- Adding third-party Lottie or Rive binaries.
- Intrusive or distracting motion that slows user productivity.

### Anti-Goals
- Breaking accessibility or interfering with screen readers.
- Disrupting existing data flows or backend contracts.

---

## 3. Architecture & Components

### 3.1 `SheenSweepEffect` (`frontend/lib/core/animations/sheen_sweep_effect.dart`, $\le 85$ lines)
- A widget that periodically passes a 45-degree linear gradient sheen across its child every 3.5 seconds.
- Integrated into `VerificationBadge` in `status_badge.dart`.

### 3.2 `AnimatedSuccessDialog` (`frontend/lib/core/widgets/animated_success_dialog.dart`, $\le 130$ lines)
- A dialog featuring a custom painter checkmark drawn with `Curves.elasticOut`, an expanding emerald ring, and optional confirmation action button.

### 3.3 `PulseBeaconIndicator` (`frontend/lib/core/animations/pulse_beacon_indicator.dart`, $\le 85$ lines)
- A compact beacon widget with a core colored dot and 2 concentric expanding/fading circles (`Curves.easeOutQuad`).
- Integrated into live chat online indicators and featured badges.

### 3.4 `SlidingPillBar` (`frontend/lib/core/widgets/sliding_pill_bar.dart`, $\le 120$ lines)
- An animated selection bar that slides a rounded capsule under the active tab index via `AnimatedAlign` or `Stack` + `AnimatedPositioned`.

### 3.5 Hero Tag Standardization
- Uniform `Hero` wrapping on listing thumbnails (`'property-hero-${listing['id']}'`) across `PropertyCardWidget`, `MobilePropertyCard`, and details viewers.

---

## 4. Verification Plan
- Unit and widget tests in `frontend/test/advanced_animations_test.dart`.
- Full regression test run: `flutter test` and `mvn test`.
- Analyzer check: `flutter analyze --no-fatal-infos`.
- Web release compilation: `flutter build web --release`.
