import 'dart:math' show pi;
import 'package:flutter/material.dart';

/// 61. 2D to 3D Map Perspective Camera Tilt
class Map2dTo3dCameraTilt extends StatelessWidget {
  final Widget child;
  final bool is3d;
  final Duration duration;
  const Map2dTo3dCameraTilt({super.key, required this.child, required this.is3d, this.duration = const Duration(milliseconds: 400)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: is3d ? 0.6 : 0.0),
    duration: duration,
    curve: Curves.easeOutCubic,
    builder: (_, angle, ch) => Transform(
      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(angle),
      alignment: Alignment.center,
      child: ch,
    ),
    child: child,
  );
}

/// 62. Mouza Overlay Sheet Crossfade
class MouzaOverlayCrossfade extends StatelessWidget {
  final Widget child;
  final double opacity;
  final Duration duration;
  const MouzaOverlayCrossfade({super.key, required this.child, required this.opacity, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) => AnimatedOpacity(opacity: opacity.clamp(0.0, 1.0), duration: duration, child: child);
}

/// 63. Plot Boundary Center Zoom
class PlotBoundaryCenterZoom extends StatelessWidget {
  final Widget child;
  final bool isFocused;
  final Duration duration;
  const PlotBoundaryCenterZoom({super.key, required this.child, required this.isFocused, this.duration = const Duration(milliseconds: 350)});

  @override
  Widget build(BuildContext context) => AnimatedScale(scale: isFocused ? 1.15 : 1.0, duration: duration, curve: Curves.easeOutBack, child: child);
}

/// 64. Marker Cluster Split Transition
class MarkerClusterSplitTransition extends StatelessWidget {
  final bool isSplit;
  final Duration duration;
  const MarkerClusterSplitTransition({super.key, required this.isSplit, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: isSplit ? 1.0 : 0.0),
    duration: duration,
    builder: (_, f, _) => SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(offset: Offset(-14 * f, -10 * f), child: const Icon(Icons.location_on, color: Colors.teal, size: 24)),
          Transform.translate(offset: Offset(14 * f, 10 * f), child: const Icon(Icons.location_on, color: Colors.blueAccent, size: 24)),
        ],
      ),
    ),
  );
}

/// 65. Drawing Cursor To Pen Morph
class DrawingCursorToPenMorph extends StatelessWidget {
  final bool isDrawing;
  final Duration duration;
  const DrawingCursorToPenMorph({super.key, required this.isDrawing, this.duration = const Duration(milliseconds: 250)});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: duration,
    transitionBuilder: (ch, anim) => ScaleTransition(scale: anim, child: ch),
    child: Icon(
      isDrawing ? Icons.edit : Icons.pan_tool,
      key: ValueKey<bool>(isDrawing),
      color: isDrawing ? Colors.teal : Colors.blueGrey,
      size: 26,
    ),
  );
}

/// 66. Road To Plot View 3D Flip
class RoadToPlotFlipTransition extends StatelessWidget {
  final bool isPlotView;
  final Duration duration;
  const RoadToPlotFlipTransition({super.key, required this.isPlotView, this.duration = const Duration(milliseconds: 400)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: isPlotView ? pi : 0.0),
    duration: duration,
    builder: (_, val, _) => Transform(
      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(val),
      alignment: Alignment.center,
      child: val > pi / 2
          ? Transform(transform: Matrix4.identity()..rotateY(pi), alignment: Alignment.center, child: const Icon(Icons.crop_landscape, color: Colors.teal, size: 36))
          : const Icon(Icons.add_road, color: Colors.amber, size: 36),
    ),
  );
}

/// 67. Compass North Heading Alignment
class CompassNorthHeadingAlign extends StatelessWidget {
  final double heading;
  final Duration duration;
  const CompassNorthHeadingAlign({super.key, required this.heading, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: heading * (pi / 180)),
    duration: duration,
    builder: (_, rad, _) => Transform.rotate(angle: rad, child: const Icon(Icons.navigation, color: Colors.redAccent, size: 28)),
  );
}

/// 68. Flood Zone Water Level Rise
class FloodZoneWaterRiseTransition extends StatelessWidget {
  final double waterLevel;
  final Duration duration;
  const FloodZoneWaterRiseTransition({super.key, required this.waterLevel, this.duration = const Duration(milliseconds: 350)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: waterLevel.clamp(0.0, 1.0)),
    duration: duration,
    builder: (_, lvl, _) => Container(
      height: 60 * lvl,
      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.3 * lvl), borderRadius: BorderRadius.circular(4)),
    ),
  );
}

/// 69. Landmark Radar Pin Drop
class LandmarkRadarPinDrop extends StatelessWidget {
  final IconData icon;
  final Duration duration;
  const LandmarkRadarPinDrop({super.key, required this.icon, this.duration = const Duration(milliseconds: 450)});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: -40.0, end: 0.0),
    duration: duration,
    curve: Curves.bounceOut,
    builder: (_, y, _) => Transform.translate(offset: Offset(0, y), child: Icon(icon, color: Colors.deepOrange, size: 28)),
  );
}

/// 70. Split Map List Panel Slide
class SplitMapListPanelSlide extends StatelessWidget {
  final double splitRatio;
  final Widget leftChild;
  final Widget rightChild;
  const SplitMapListPanelSlide({super.key, required this.splitRatio, required this.leftChild, required this.rightChild});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(flex: (splitRatio * 100).toInt(), child: leftChild),
      Expanded(flex: ((1.0 - splitRatio) * 100).toInt(), child: rightChild),
    ],
  );
}
