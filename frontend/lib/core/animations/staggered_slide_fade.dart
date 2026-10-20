import 'package:flutter/material.dart';

/// লিস্ট আইটেমের ওয়াটারফল এন্ট্রান্স অ্যানিমেশন উইজেট।
/// ইনডেক্স অনুযায়ী ক্রমান্বয়ে (Staggered) আইটেমগুলো নিচ থেকে স্লাইড ও ফেড হয়ে আসে।
class StaggeredSlideFade extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration itemDuration;
  final int delayPerItemMs;
  final Offset slideOffset;

  const StaggeredSlideFade({
    super.key,
    required this.child,
    required this.index,
    this.itemDuration = const Duration(milliseconds: 320),
    this.delayPerItemMs = 45,
    this.slideOffset = const Offset(0, 0.06),
  });

  @override
  State<StaggeredSlideFade> createState() => _StaggeredSlideFadeState();
}

class _StaggeredSlideFadeState extends State<StaggeredSlideFade> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.itemDuration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(curved);

    // প্রথম ৬টি আইটেমে ওয়াটারফল বিলম্ব এবং পরবর্তী আইটেমগুলোতে ইনস্ট্যান্ট বা ফিক্সড অল্প বিলম্ব
    final effectiveDelayMs = (widget.index < 8 ? widget.index : 8) * widget.delayPerItemMs;

    if (effectiveDelayMs == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: effectiveDelayMs), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
