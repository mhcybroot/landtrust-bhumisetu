import 'package:flutter/material.dart';
import 'bouncing_pressable.dart';

/// Wraps cards with desktop hover lift & shadow, and tactile touch-spring scaling.
class HoverLiftCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double liftDistance;
  final Duration duration;
  final Curve curve;
  final BorderRadius? borderRadius;
  final Color? shadowColor;
  final List<BoxShadow>? defaultShadow;

  const HoverLiftCard({
    super.key,
    required this.child,
    this.onTap,
    this.liftDistance = 4.0,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
    this.borderRadius,
    this.shadowColor,
    this.defaultShadow,
  });

  @override
  State<HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<HoverLiftCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hoverShadow = [
      BoxShadow(
        color: (widget.shadowColor ?? Colors.black).withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 8),
        spreadRadius: 1,
      ),
    ];

    final animatedCard = AnimatedContainer(
      duration: widget.duration,
      curve: widget.curve,
      transform: Matrix4.translationValues(
        0,
        _isHovered ? -widget.liftDistance : 0,
        0,
      ),
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(14),
        boxShadow: _isHovered ? hoverShadow : widget.defaultShadow,
      ),
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: BouncingPressable(
        onTap: widget.onTap,
        scaleFactor: 0.975,
        child: animatedCard,
      ),
    );
  }
}
