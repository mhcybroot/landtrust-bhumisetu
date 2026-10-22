import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable frosted glassmorphic container with backdrop blur and border styling.
class FrostedGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  const FrostedGlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);
    final effectiveBorder = border ??
        Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.0,
        );
    final effectiveBg = backgroundColor ?? Colors.white.withValues(alpha: 0.15);

    Widget content = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: effectiveRadius,
            border: effectiveBorder,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
