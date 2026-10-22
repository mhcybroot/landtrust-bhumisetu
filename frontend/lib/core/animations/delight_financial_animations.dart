import 'dart:math';
import 'package:flutter/material.dart';

/// ১৩. চ্যাট টাইপিং ওয়েভ ডটস (Chat Typing Wave)
class ChatTypingWave extends StatefulWidget {
  final Color dotColor;
  const ChatTypingWave({super.key, this.dotColor = const Color(0xFF0B4F32)});
  @override
  State<ChatTypingWave> createState() => _ChatTypingWaveState();
}

class _ChatTypingWaveState extends State<ChatTypingWave> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final dy = sin((_ctrl.value * 2 * pi) + (i * 1.1)) * 3.5;
          return Container(margin: const EdgeInsets.symmetric(horizontal: 2.5), child: Transform.translate(offset: Offset(0, dy), child: Container(width: 5.5, height: 5.5, decoration: BoxDecoration(color: widget.dotColor, shape: BoxShape.circle))));
        }),
      ),
    );
  }
}

/// ১৪. মেসেজ সেন্ট উড়ে যাওয়ার ট্রানজিশন (Message Flight Curve)
class MessageFlightCurve extends StatelessWidget {
  final Widget child;
  const MessageFlightCurve({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      builder: (_, val, c) => Opacity(opacity: val, child: Transform.translate(offset: Offset(0, (1.0 - val) * 16), child: c)),
      child: child,
    );
  }
}

/// ১৫. রেজিস্ট্রেশন ফি রেডিয়াল গজ (Radial Gauge Fill)
class RadialGaugeFill extends StatelessWidget {
  final double percent;
  final Color activeColor;
  final double size;
  const RadialGaugeFill({super.key, required this.percent, this.activeColor = const Color(0xFF0B4F32), this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _GaugePainter(percent: percent.clamp(0.0, 1.0), color: activeColor),
        child: Center(child: Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: size * 0.22, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent; final Color color;
  _GaugePainter({required this.percent, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2), r = (size.width - 8) / 2;
    canvas.drawCircle(c, r, Paint()..color = Colors.grey.shade200..style = PaintingStyle.stroke..strokeWidth = 6);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, 2 * pi * percent, false, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_GaugePainter o) => o.percent != percent;
}

/// ১৬. টাকার ডিজিট রোলিং কাউন্টার (Rolling Digit Counter)
class RollingDigitCounter extends StatelessWidget {
  final num value;
  final String prefix;
  const RollingDigitCounter({super.key, required this.value, this.prefix = ''});
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, anim) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(anim), child: FadeTransition(opacity: anim, child: child)),
      child: Text('$prefix$value', key: ValueKey<num>(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}

/// ১৭. কমিশন বণ্টন ইন্টারঅ্যাকটিভ বার (Commission Split Bar)
class CommissionSplitBar extends StatelessWidget {
  final int fieldShare; final int upazilaShare; final int districtShare;
  const CommissionSplitBar({super.key, required this.fieldShare, required this.upazilaShare, required this.districtShare});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(children: [
          Flexible(flex: fieldShare, child: Container(color: const Color(0xFF0B4F32))),
          Flexible(flex: upazilaShare, child: Container(color: const Color(0xFF1E88E5))),
          Flexible(flex: districtShare, child: Container(color: const Color(0xFFE65100))),
        ]),
      ),
    );
  }
}

/// ১৮. ওয়ালেট ডিপোজিট কয়েন ড্রপ (Coin Drop Visual)
class CoinDropVisual extends StatefulWidget {
  final double size;
  const CoinDropVisual({super.key, this.size = 28});
  @override
  State<CoinDropVisual> createState() => _CoinDropVisualState();
}

class _CoinDropVisualState extends State<CoinDropVisual> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550))..forward();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final val = CurvedAnimation(parent: _ctrl, curve: Curves.bounceOut).value;
        return Transform.translate(offset: Offset(0, (1.0 - val) * -24), child: child);
      },
      child: Container(
        width: widget.size, height: widget.size,
        decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
        child: const Center(child: Text('৳', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
      ),
    );
  }
}

/// ১৯. বটম ন্যাভ বাবল বাউন্স (Bottom Nav Bubble Jump)
class BottomNavBubbleJump extends StatelessWidget {
  final IconData icon; final bool isSelected;
  const BottomNavBubbleJump({super.key, required this.icon, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      padding: EdgeInsets.all(isSelected ? 6 : 4),
      decoration: BoxDecoration(color: isSelected ? const Color(0xFF0B4F32).withValues(alpha: 0.12) : Colors.transparent, shape: BoxShape.circle),
      child: Icon(icon, color: isSelected ? const Color(0xFF0B4F32) : Colors.grey.shade600, size: isSelected ? 24 : 22),
    );
  }
}

/// ২০. অফিসার অনুমোদন কনফেটি রেইন (Confetti Celebration)
class ConfettiCelebration extends StatefulWidget {
  final Duration duration;
  const ConfettiCelebration({super.key, this.duration = const Duration(milliseconds: 1600)});
  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: widget.duration)..forward();
  final _particles = List.generate(16, (i) => Point(Random(i).nextDouble() * 280, Random(i * 2).nextDouble() * 120));
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => CustomPaint(size: const Size(300, 150), painter: _ConfettiPainter(progress: _ctrl.value, points: _particles)),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress; final List<Point<double>> points;
  _ConfettiPainter({required this.progress, required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [const Color(0xFF0B4F32), const Color(0xFFF59E0B), const Color(0xFF1E88E5), const Color(0xFFE53935)];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final dy = (p.y + (progress * 100)) % size.height;
      canvas.drawCircle(Offset(p.x, dy), 3.5, Paint()..color = colors[i % colors.length].withValues(alpha: (1.0 - progress).clamp(0.0, 1.0)));
    }
  }
  @override
  bool shouldRepaint(_ConfettiPainter o) => o.progress != progress;
}
