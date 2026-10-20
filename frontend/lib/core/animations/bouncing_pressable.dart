import 'package:flutter/material.dart';

/// বাটন ও কার্ডের জন্য ন্যাচারাল স্প্রিং প্রেস ফিডব্যাক উইজেট।
/// ব্যবহারকারী টাচ করলে এটি ০.৯৭x স্কেলে সংকুচিত হয় এবং রিলিজ করলে স্মুথলি স্প্রিং বাউন্স করে।
class BouncingPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  const BouncingPressable({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.965,
    this.duration = const Duration(milliseconds: 110),
  });

  @override
  State<BouncingPressable> createState() => _BouncingPressableState();
}

class _BouncingPressableState extends State<BouncingPressable> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
      value: 1.0,
      lowerBound: widget.scaleFactor,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
