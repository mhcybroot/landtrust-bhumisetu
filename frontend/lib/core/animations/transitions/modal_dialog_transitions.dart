import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// ১১. স্কেল-বাউন্স কনফার্মেশন ডায়ালগ (Scale Bounce Dialog)
class ScaleBounceDialogTransition extends StatelessWidget {
  final Widget child;
  const ScaleBounceDialogTransition({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.elasticOut,
      builder: (_, val, c) => Transform.scale(scale: val, child: c),
      child: child,
    );
  }
}

/// ১২. ব্যাকড্রপ ব্লার মোডাল রিভিল (Backdrop Blur Reveal)
class BackdropBlurRevealTransition extends StatelessWidget {
  final Widget child;
  const BackdropBlurRevealTransition({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      builder: (_, val, c) => ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8 * val, sigmaY: 8 * val),
          child: Opacity(opacity: val.clamp(0.0, 1.0), child: c),
        ),
      ),
      child: child,
    );
  }
}

/// ১৩. টপ-কার্টেন নোটিফিকেশন ড্রপ (Top Curtain Notification Drop)
class TopCurtainNotificationDrop extends StatelessWidget {
  final String message;
  const TopCurtainNotificationDrop({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0.0, -1.0), end: Offset.zero),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (_, off, c) => FractionalTranslation(translation: off, child: c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))]),
        child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

/// ১৪. থ্রি-ডি পার্সপেক্টিভ ফ্লিপ অ্যালার্ট (Perspective 3D Flip Alert)
class Perspective3dFlipAlert extends StatelessWidget {
  final Widget child;
  const Perspective3dFlipAlert({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (_, val, c) => Transform(
        transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX((1.0 - val) * (pi / 6)),
        alignment: Alignment.topCenter,
        child: Opacity(opacity: val.clamp(0.0, 1.0), child: c),
      ),
      child: child,
    );
  }
}

/// ১৫. সেন্টার-পপ অ্যাকশন ট্রানজিশন (Center Pop Action Transition)
class CenterPopActionTransition extends StatelessWidget {
  final Widget child;
  const CenterPopActionTransition({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.2, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (_, val, c) => Transform.scale(scale: val, child: c),
      child: child,
    );
  }
}

/// ১৬. বটম স্লাইড-আপ নোটিশ বার (Slide Up Notice Transition)
class SlideUpNoticeTransition extends StatelessWidget {
  final String notice;
  const SlideUpNoticeTransition({super.key, required this.notice});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (_, off, c) => FractionalTranslation(translation: off, child: c),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF1E2022), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
          const SizedBox(width: 8),
          Text(notice, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

/// ১৭. রেডিয়াল কর্নার মোডাল রিভিল (Radial Corner Dialog Reveal)
class RadialCornerDialogReveal extends StatelessWidget {
  final Widget child;
  const RadialCornerDialogReveal({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (_, val, c) => ClipOval(clipper: _CornerClipper(val), child: c),
      child: child,
    );
  }
}

class _CornerClipper extends CustomClipper<Rect> {
  final double progress;
  _CornerClipper(this.progress);
  @override
  Rect getClip(Size size) => Rect.fromCircle(center: Offset(size.width, 0), radius: (size.width + size.height) * progress);
  @override
  bool shouldReclip(_CornerClipper old) => old.progress != progress;
}

/// ১৮. পেনসিল স্কেচ বর্ডার ডায়ালগ (Pencil Sketch Border Dialog)
class PencilSketchBorderDialog extends StatelessWidget {
  final Widget child;
  const PencilSketchBorderDialog({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF0B4F32), width: 1.5), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: child,
    );
  }
}

/// ১৯. শাটার ব্লাইন্ড মোডাল রিভিল (Shutter Blind Modal Transition)
class ShutterBlindModalTransition extends StatelessWidget {
  final Widget child;
  const ShutterBlindModalTransition({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutQuad,
      builder: (_, val, c) => Align(alignment: Alignment.topCenter, heightFactor: val.clamp(0.0, 1.0), child: c),
      child: child,
    );
  }
}

/// ২০. ভ্যানিশ ডিজলভ ডিসমিস ট্রানজিশন (Vanish Dissolve Dismiss)
class VanishDissolveDismiss extends StatelessWidget {
  final Widget child;
  const VanishDissolveDismiss({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (_, val, c) => Opacity(opacity: val.clamp(0.0, 1.0), child: c),
      child: child,
    );
  }
}
