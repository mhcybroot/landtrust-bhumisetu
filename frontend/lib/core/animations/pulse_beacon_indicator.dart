import 'package:flutter/material.dart';

/// লাইভ স্ট্যাটাস, হট ডিল বা সক্রিয় নির্দেশক অ্যানিমেটেড পালস বিকন উইজেট।
class PulseBeaconIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulseBeaconIndicator({
    super.key,
    this.color = const Color(0xFF10B981),
    this.size = 8.0,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<PulseBeaconIndicator> createState() => _PulseBeaconIndicatorState();
}

class _PulseBeaconIndicatorState extends State<PulseBeaconIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.6,
      height: widget.size * 2.6,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _PulseBeaconPainter(
              progress: _ctrl.value,
              color: widget.color,
              dotSize: widget.size,
            ),
          );
        },
      ),
    );
  }
}

class _PulseBeaconPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double dotSize;

  _PulseBeaconPainter({
    required this.progress,
    required this.color,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // ১ম পালস রিং
    final ring1Radius = dotSize / 2 + (maxRadius - dotSize / 2) * progress;
    final ring1Opacity = ((1.0 - progress) * 0.7).clamp(0.0, 1.0);
    final ring1Paint = Paint()
      ..color = color.withValues(alpha: ring1Opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, ring1Radius, ring1Paint);

    // ২য় ইন্টারমিডিয়েট পালস রিং (অর্ধেক সাইকেল পর শুরু)
    final progress2 = (progress + 0.5) % 1.0;
    final ring2Radius = dotSize / 2 + (maxRadius - dotSize / 2) * progress2;
    final ring2Opacity = ((1.0 - progress2) * 0.5).clamp(0.0, 1.0);
    final ring2Paint = Paint()
      ..color = color.withValues(alpha: ring2Opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, ring2Radius, ring2Paint);

    // কেন্দ্রস্থ সলিড ডট
    final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawCircle(center, dotSize / 2, dotPaint);
  }

  @override
  bool shouldRepaint(_PulseBeaconPainter old) => old.progress != progress;
}
