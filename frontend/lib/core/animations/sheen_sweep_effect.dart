import 'package:flutter/material.dart';

/// ব্যাজ ও কার্ডের উপর দিয়ে একটি মৃদু আলোর ঝলকানি অতিক্রমকারী প্রিমিয়াম অ্যানিমেশন উইজেট।
class SheenSweepEffect extends StatefulWidget {
  final Widget child;
  final Color sheenColor;
  final Duration cycleDuration;
  final bool enabled;

  const SheenSweepEffect({
    super.key,
    required this.child,
    this.sheenColor = Colors.white,
    this.cycleDuration = const Duration(milliseconds: 3200),
    this.enabled = true,
  });

  @override
  State<SheenSweepEffect> createState() => _SheenSweepEffectState();
}

class _SheenSweepEffectState extends State<SheenSweepEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.cycleDuration);
    if (widget.enabled) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(SheenSweepEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.enabled && _ctrl.isAnimating) {
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
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        // প্রথম ২৫% সময়ে শাইন সোয়াইপ হবে এবং বাকি ৭৫% সময় স্থির থাকবে
        final val = _ctrl.value;
        final sweepPercent = val < 0.28 ? (val / 0.28) : -1.0;

        if (sweepPercent < 0) return child!;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double xOffset = bounds.width * (sweepPercent * 2.2 - 0.6);
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                widget.sheenColor.withValues(alpha: 0.5),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _OffsetGradientTransform(offset: xOffset),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _OffsetGradientTransform extends GradientTransform {
  final double offset;
  const _OffsetGradientTransform({required this.offset});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(offset, 0, 0);
  }
}
