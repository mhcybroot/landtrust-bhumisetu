import 'package:flutter/material.dart';

/// পেজ বা ট্যাব ট্রানজিশনের জন্য ফ্লুইড ফেড ও স্লাইট স্কেল ট্রানজিশন উইজেট।
class AnimatedFadeSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedFadeSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        final scaleAnimation = Tween<double>(
          begin: 0.985,
          end: 1.0,
        ).animate(fadeAnimation);

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
