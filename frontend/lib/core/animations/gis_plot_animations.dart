import 'dart:math';
import 'package:flutter/material.dart';

/// ১. স্যাটেলাইট প্লট সীমানা ট্রেসার (Plot Boundary Vector Tracer)
class PlotBoundaryTracer extends StatefulWidget {
  final Size size;
  const PlotBoundaryTracer({super.key, this.size = const Size(120, 80)});
  @override
  State<PlotBoundaryTracer> createState() => _PlotBoundaryTracerState();
}

class _PlotBoundaryTracerState extends State<PlotBoundaryTracer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(size: widget.size, painter: _TracerPainter(progress: _ctrl.value)),
    );
  }
}

class _TracerPainter extends CustomPainter {
  final double progress;
  _TracerPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(10, 10)..lineTo(size.width - 15, 12)..lineTo(size.width - 10, size.height - 15)..lineTo(15, size.height - 10)..close();
    canvas.drawPath(path, Paint()..color = Colors.green.withValues(alpha: 0.15)..style = PaintingStyle.fill);
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * progress), Paint()..color = const Color(0xFF0B4F32)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
  }
  @override
  bool shouldRepaint(_TracerPainter o) => o.progress != progress;
}

/// ২. রাস্তার পরিমাপক ফিতা (Road Width Tape)
class RoadWidthTape extends StatelessWidget {
  final double widthFeet;
  const RoadWidthTape({super.key, required this.widthFeet});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.straighten_rounded, size: 14, color: Colors.white),
        const SizedBox(width: 4),
        Text('${widthFeet.toStringAsFixed(0)} ফুট রাস্তা (২৪ ফুট)', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

/// ৩. কম্পাস উত্তর দিক সূচক (Compass North Lock)
class CompassNorthLock extends StatelessWidget {
  final double headingDegrees;
  const CompassNorthLock({super.key, required this.headingDegrees});
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -headingDegrees * (pi / 180),
      child: const Icon(Icons.navigation_rounded, color: Colors.redAccent, size: 24),
    );
  }
}

/// ৪. জিপিএস পিন ড্রপ বাউন্স (GPS Pin Drop Bounce)
class GpsPinDropBounce extends StatefulWidget {
  const GpsPinDropBounce({super.key});
  @override
  State<GpsPinDropBounce> createState() => _GpsPinDropBounceState();
}

class _GpsPinDropBounceState extends State<GpsPinDropBounce> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 650))..forward();
  late final Animation<double> _anim = CurvedAnimation(parent: _ctrl, curve: Curves.bounceOut);
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(offset: Offset(0, (1.0 - _anim.value) * -30), child: child),
      child: const Icon(Icons.location_on, color: Color(0xFF0B4F32), size: 28),
    );
  }
}

/// ৫. নিকটবর্তী ল্যান্ডমার্ক রাডার ওয়েভ (Landmark Radar Wave)
class LandmarkRadarWave extends StatefulWidget {
  final IconData icon;
  const LandmarkRadarWave({super.key, required this.icon});
  @override
  State<LandmarkRadarWave> createState() => _LandmarkRadarWaveState();
}

class _LandmarkRadarWaveState extends State<LandmarkRadarWave> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Stack(alignment: Alignment.center, children: [
        Transform.scale(scale: 1.0 + (_ctrl.value * 0.8), child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue.withValues(alpha: 1.0 - _ctrl.value), width: 1.5)))),
        child!,
      ]),
      child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle), child: Icon(widget.icon, color: Colors.white, size: 16)),
    );
  }
}

/// ৬. মৌজা শিট ওভারলে ক্রসফেড (Mouza Sheet Overlay)
class MouzaSheetOverlay extends StatelessWidget {
  final double opacity; final Widget child;
  const MouzaSheetOverlay({super.key, required this.opacity, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(duration: const Duration(milliseconds: 250), opacity: opacity.clamp(0.0, 1.0), child: child);
  }
}

/// ৭. উচ্চতা প্রোফাইল বার (Elevation Profile Bar)
class ElevationProfileBar extends StatelessWidget {
  final double heightFeet;
  const ElevationProfileBar({super.key, required this.heightFeet});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 14, height: 36, decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(3))),
      const SizedBox(height: 2),
      Text('${heightFeet.toStringAsFixed(1)} ফুট উঁচু (৬.৫ ফুট)', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    ]);
  }
}

/// ৮. প্লাবন স্তর সিমুলেশন ওয়েভ (Flood Level Wave)
class FloodLevelWave extends StatelessWidget {
  final double waterLevelPercent;
  const FloodLevelWave({super.key, required this.waterLevelPercent});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18, width: 60,
      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
      child: FractionallySizedBox(alignment: Alignment.bottomCenter, heightFactor: waterLevelPercent.clamp(0.0, 1.0), child: Container(color: Colors.blue.shade600)),
    );
  }
}

/// ৯. সূর্যের আলো ও ছায়া সুইপ (Sun Shadow Sweep)
class SunShadowSweep extends StatelessWidget {
  final int timeOfDayHour;
  const SunShadowSweep({super.key, required this.timeOfDayHour});
  @override
  Widget build(BuildContext context) {
    final angle = ((timeOfDayHour - 6) / 12) * pi;
    return Transform.rotate(angle: angle.clamp(0.0, pi), child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFF59E0B), size: 20));
  }
}

/// ১০. সীমানা পিলার ৩D ফ্লিপ (Corner Pillar Flip)
class CornerPillarFlip extends StatelessWidget {
  final String pillarLabel;
  const CornerPillarFlip({super.key, required this.pillarLabel});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey.shade800, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white, width: 1)),
      child: Text(pillarLabel, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
