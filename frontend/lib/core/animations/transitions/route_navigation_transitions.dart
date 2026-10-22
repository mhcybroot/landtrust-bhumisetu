import 'dart:math';
import 'package:flutter/material.dart';

/// ১. শেয়ার্ড-অ্যাক্সিস হরাইজন্টাল স্লাইড রাউট (Shared Axis Slide Route)
class SharedAxisSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SharedAxisSlideRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.fastOutSlowIn)),
      child: c,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// ২. সার্কুলার ক্লিপ রিভিল রাউট (Circular Clip Reveal Route)
class CircularClipRevealRoute<T> extends PageRouteBuilder<T> {
  final Widget page; final Offset? epicenter;
  CircularClipRevealRoute({required this.page, this.epicenter}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => ClipPath(clipper: _CircleRevealClipper(a.value, epicenter), child: c),
    transitionDuration: const Duration(milliseconds: 350),
  );
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final double progress; final Offset? center;
  _CircleRevealClipper(this.progress, this.center);
  @override
  Path getClip(Size size) {
    final epic = center ?? Offset(size.width / 2, size.height / 2);
    final maxRadius = (size.width + size.height) * progress;
    return Path()..addOval(Rect.fromCircle(center: epic, radius: maxRadius.clamp(0.0, 5000.0)));
  }
  @override
  bool shouldReclip(_CircleRevealClipper old) => old.progress != progress;
}

/// ৩. জুম-ফেড সফট এন্ট্রান্স রাউট (Zoom Fade Route)
class ZoomFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  ZoomFadeRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: FadeTransition(opacity: a, child: c),
    ),
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// ৪. প্যারাল্যাক্স ব্যাক-স্লাইড রাউট (Parallax Back Route)
class ParallaxBackRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  ParallaxBackRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, sec, c) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: const Offset(-0.25, 0.0)).animate(CurvedAnimation(parent: sec, curve: Curves.easeOutCubic)),
        child: c,
      ),
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// ৫. থ্রি-ডি হরিজন্টাল কিউব রোটেশন রাউট (Horizontal Cube Rotate Route)
class HorizontalCubeRotateRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  HorizontalCubeRotateRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => Transform(
      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY((1.0 - a.value) * (pi / 4)),
      alignment: Alignment.centerLeft,
      child: FadeTransition(opacity: a, child: c),
    ),
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// ৬. ভার্টিক্যাল কার্টেন স্লাইড-আপ রাউট (Vertical Curtain Slide Route)
class VerticalCurtainSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  VerticalCurtainSlideRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: c,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// ৭. স্ট্যাগার্ড স্প্লিট স্লাইড রাউট (Staggered Split Slide Route)
class StaggeredSplitSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  StaggeredSplitSlideRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
      child: FadeTransition(opacity: a, child: c),
    ),
    transitionDuration: const Duration(milliseconds: 280),
  );
}

/// ৮. ডায়াগোনাল জিওমেট্রিক ওয়াইপ রাউট (Diagonal Wipe Route)
class DiagonalWipeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  DiagonalWipeRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1.0, 1.0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: c,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// ৯. মেটেরিয়াল ফেড-থ্রু রাউট (Fade Through Route)
class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeThroughRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: const Interval(0.2, 1.0)),
      child: ScaleTransition(scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)), child: c),
    ),
    transitionDuration: const Duration(milliseconds: 250),
  );
}

/// ১০. ইলাস্টিক পপ ব্যাক রাউট (Elastic Pop Back Route)
class ElasticPopBackRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  ElasticPopBackRoute({required this.page}) : super(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, c) => ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.elasticOut)),
      child: c,
    ),
    transitionDuration: const Duration(milliseconds: 350),
  );
}
