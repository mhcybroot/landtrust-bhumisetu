import 'package:flutter/material.dart';
import '../animations/bouncing_pressable.dart';

/// ব্যবহারকারীর লেনদেন বা আবেদন সফল হওয়ার পর স্মুথ ড্র-ইন টিকমার্ক ও পালস ডায়ালগ।
class AnimatedSuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const AnimatedSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AnimatedSuccessDialog(title: title, message: message, onConfirm: onConfirm),
    );
  }

  @override
  State<AnimatedSuccessDialog> createState() => _AnimatedSuccessDialogState();
}

class _AnimatedSuccessDialogState extends State<AnimatedSuccessDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    _scaleAnimation = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45, curve: Curves.elasticOut));
    _checkAnimation = CurvedAnimation(parent: _ctrl, curve: const Interval(0.40, 1.0, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) => ScaleTransition(
                  scale: _scaleAnimation,
                  child: CustomPaint(
                    size: const Size(80, 80),
                    painter: _SuccessCheckPainter(progress: _checkAnimation.value),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B4F32)),
              ),
              const SizedBox(height: 10),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 24),
              BouncingPressable(
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onConfirm?.call();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4F32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('ঠিক আছে', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessCheckPainter extends CustomPainter {
  final double progress;
  _SuccessCheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ব্যাকগ্রাউন্ড হালকা গ্রিন ফিল ও রিং
    final bgPaint = Paint()..color = const Color(0xFFD8F3DC)..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, borderPaint);

    if (progress <= 0.0) return;

    // টিকমার্ক পাথ তৈরি
    final path = Path();
    path.moveTo(size.width * 0.28, size.height * 0.52);
    path.lineTo(size.width * 0.44, size.height * 0.68);
    path.lineTo(size.width * 0.72, size.height * 0.36);

    // প্রগ্রেস অনুযায়ী পাথ এক্সট্র্যাকশন
    final checkPaint = Paint()
      ..color = const Color(0xFF0B4F32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      final extract = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extract, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_SuccessCheckPainter oldDelegate) => oldDelegate.progress != progress;
}
