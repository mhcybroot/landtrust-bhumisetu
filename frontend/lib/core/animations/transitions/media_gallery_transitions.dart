import 'dart:math' show pi;
import 'package:flutter/material.dart';

/// 71. Thumbnail to Fullscreen Lightbox Morph
class ThumbnailToLightboxMorph extends StatelessWidget {
  final bool isExpanded;
  final Widget collapsedChild;
  final Widget expandedChild;
  final Duration duration;
  const ThumbnailToLightboxMorph({super.key, required this.isExpanded, required this.collapsedChild, required this.expandedChild, this.duration = const Duration(milliseconds: 350)});

  @override
  Widget build(BuildContext context) => AnimatedCrossFade(
    firstChild: collapsedChild,
    secondChild: expandedChild,
    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    duration: duration,
  );
}

/// 72. 360-Degree Panorama Spin Transition
class Panorama360SpinTransition extends StatelessWidget {
  final double angle;
  final Widget child;
  const Panorama360SpinTransition({super.key, required this.angle, required this.child});

  @override
  Widget build(BuildContext context) => Transform(
    transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
    alignment: Alignment.center,
    child: child,
  );
}

/// 73. Filmstrip Thumbnail Slide Crossfade
class FilmstripSlideCrossfade extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  const FilmstripSlideCrossfade({super.key, required this.index, required this.child, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: duration,
    transitionBuilder: (ch, anim) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(anim),
      child: FadeTransition(opacity: anim, child: ch),
    ),
    child: KeyedSubtree(key: ValueKey<int>(index), child: child),
  );
}

/// 74. Video Play Pulse Overlay
class VideoPlayPulseOverlay extends StatelessWidget {
  final bool isPlaying;
  final Widget child;
  const VideoPlayPulseOverlay({super.key, required this.isPlaying, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      child,
      if (!isPlaying)
        Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
        ),
    ],
  );
}

/// 75. Architectural Blueprint To Floor Plan Crossfade
class BlueprintFloorPlanCrossfade extends StatelessWidget {
  final bool showBlueprint;
  final Widget floorPlan;
  final Widget blueprint;
  final Duration duration;
  const BlueprintFloorPlanCrossfade({super.key, required this.showBlueprint, required this.floorPlan, required this.blueprint, this.duration = const Duration(milliseconds: 350)});

  @override
  Widget build(BuildContext context) => AnimatedCrossFade(
    firstChild: floorPlan,
    secondChild: blueprint,
    crossFadeState: showBlueprint ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    duration: duration,
  );
}

/// 76. Drone Aerial View Scale Zoom Reveal
class DroneAerialZoomReveal extends StatelessWidget {
  final bool isZoomed;
  final Widget child;
  final Duration duration;
  const DroneAerialZoomReveal({super.key, required this.isZoomed, required this.child, this.duration = const Duration(milliseconds: 500)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: isZoomed ? 1.0 : 1.3),
    duration: duration,
    curve: Curves.easeOutCubic,
    builder: (_, scale, ch) => Transform.scale(scale: scale, child: ch),
    child: child,
  );
}

/// 77. Image Watermark Sheen Swipe
class ImageWatermarkSheenSwipe extends StatelessWidget {
  final Widget child;
  const ImageWatermarkSheenSwipe({super.key, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: -1.0, end: 2.0),
    duration: const Duration(milliseconds: 1200),
    builder: (_, offset, ch) => Stack(
      children: [
        ch!,
        Positioned.fill(
          child: ClipRect(
            child: Transform.translate(
              offset: Offset(offset * 200, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withValues(alpha: 0.25), Colors.transparent]),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    child: child,
  );
}

/// 78. Before & After Renovation Curtain Wipe
class BeforeAfterCurtainWipe extends StatelessWidget {
  final double splitRatio;
  final Widget beforeChild;
  final Widget afterChild;
  const BeforeAfterCurtainWipe({super.key, required this.splitRatio, required this.beforeChild, required this.afterChild});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      afterChild,
      ClipRect(clipper: _HorizontalClipper(splitRatio.clamp(0.0, 1.0)), child: beforeChild),
    ],
  );
}

class _HorizontalClipper extends CustomClipper<Rect> {
  final double ratio;
  _HorizontalClipper(this.ratio);
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * ratio, size.height);
  @override
  bool shouldReclip(_HorizontalClipper old) => old.ratio != ratio;
}

/// 79. Audio Waveform Bar Expand
class AudioWaveformBarExpand extends StatelessWidget {
  final bool isExpanded;
  final Widget child;
  const AudioWaveformBarExpand({super.key, required this.isExpanded, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutBack,
    child: isExpanded ? child : const SizedBox.shrink(),
  );
}

/// 80. Document & Deed 3D Page Turn Transition
class DocumentPdfPageTurnTransition extends StatelessWidget {
  final bool isFlipped;
  final Widget front;
  final Widget back;
  const DocumentPdfPageTurnTransition({super.key, required this.isFlipped, required this.front, required this.back});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: isFlipped ? pi : 0.0),
    duration: const Duration(milliseconds: 400),
    builder: (_, angle, _) => Transform(
      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
      alignment: Alignment.center,
      child: angle > pi / 2 ? Transform(transform: Matrix4.identity()..rotateY(pi), alignment: Alignment.center, child: back) : front,
    ),
  );
}
