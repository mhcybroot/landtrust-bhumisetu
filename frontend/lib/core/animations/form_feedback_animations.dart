import 'dart:math';
import 'package:flutter/material.dart';

/// ৫. ইনপুট এরর শেক ফিডব্যাক (Error Shake Animation)
class ErrorShakeAnimation extends StatefulWidget {
  final Widget child;
  final double shakeDistance;

  const ErrorShakeAnimation({super.key, required this.child, this.shakeDistance = 8.0});

  @override
  State<ErrorShakeAnimation> createState() => ErrorShakeAnimationState();
}

class ErrorShakeAnimationState extends State<ErrorShakeAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 360));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void shake() => _ctrl.forward(from: 0.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final val = _ctrl.value;
        final offset = sin(val * pi * 4) * (1.0 - val) * widget.shakeDistance;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// ৬. পাসওয়ার্ড আইকন ব্লিংক মর্ফ (Password Eye Morph)
class PasswordEyeMorph extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onToggle;
  final Color color;

  const PasswordEyeMorph({
    super.key,
    required this.isObscured,
    required this.onToggle,
    this.color = const Color(0xFF0B4F32),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: Icon(
          isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          key: ValueKey<bool>(isObscured),
          color: color,
          size: 20,
        ),
      ),
      onPressed: onToggle,
    );
  }
}

/// ৭. ধাপভিত্তিক ফর্ম স্টেপার পালস (Step Pulse Indicator)
class StepPulseIndicator extends StatefulWidget {
  final int stepNumber;
  final bool isCurrent;
  final bool isCompleted;

  const StepPulseIndicator({super.key, required this.stepNumber, this.isCurrent = false, this.isCompleted = false});

  @override
  State<StepPulseIndicator> createState() => _StepPulseIndicatorState();
}

class _StepPulseIndicatorState extends State<StepPulseIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    if (widget.isCurrent) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(StepPulseIndicator old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isCurrent && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0B4F32);
    if (widget.isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(color: activeColor, shape: BoxShape.circle),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    }

    final circle = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: widget.isCurrent ? activeColor : Colors.grey.shade200, shape: BoxShape.circle),
      child: Center(
        child: Text('${widget.stepNumber}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.isCurrent ? Colors.white : Colors.grey.shade700)),
      ),
    );

    if (!widget.isCurrent) return circle;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 1.0 + (_ctrl.value * 0.2),
            child: Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: activeColor.withValues(alpha: (1.0 - _ctrl.value) * 0.35))),
          ),
          child!,
        ],
      ),
      child: circle,
    );
  }
}

/// ৮. এফএবি বাটন থেকে ফর্ম মর্ফিং ট্রিগার (Morphing FAB Trigger)
class MorphingFabTrigger extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;

  const MorphingFabTrigger({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color(0xFF0B4F32),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: backgroundColor.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
            ],
          ),
        ),
      ),
    );
  }
}
