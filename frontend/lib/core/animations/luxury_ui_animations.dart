import 'dart:ui';
import 'package:flutter/material.dart';

/// ৪১. থিম স্যুইচ সার্কুলার রিভিল (Theme Circular Reveal)
class ThemeCircularReveal extends StatelessWidget {
  final Widget child;
  const ThemeCircularReveal({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, val, c) => ClipOval(clipper: _CircleClipper(val), child: c),
      child: child,
    );
  }
}

class _CircleClipper extends CustomClipper<Rect> {
  final double fraction;
  _CircleClipper(this.fraction);
  @override
  Rect getClip(Size size) => Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: (size.width + size.height) * fraction);
  @override
  bool shouldReclip(_CircleClipper old) => old.fraction != fraction;
}

/// ৪২. ওলেড ডার্ক মোড শিমার (OLED Dark Shimmer)
class OledDarkShimmer extends StatelessWidget {
  final Widget child;
  const OledDarkShimmer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF1E2022), Color(0xFF2C3034), Color(0xFF1E2022)], stops: [0.0, 0.5, 1.0]).createShader(b),
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}

String _toBn(int n) {
  var s = '$n';
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  for (int i = 0; i < 10; i++) { s = s.replaceAll(en[i], bn[i]); }
  return s;
}

/// ৪৩. প্রপার্টি তুলনা ড্রয়ার মর্ফ (Comparison Drawer Morph)
class ComparisonDrawerMorph extends StatelessWidget {
  final int itemCount;
  final VoidCallback? onCompare;
  const ComparisonDrawerMorph({super.key, required this.itemCount, this.onCompare});
  @override
  Widget build(BuildContext context) {
    final bn = _toBn(itemCount);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text('$bnটি জমি তুলনার জন্য নির্বাচিত', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }
}

/// ৪৪. ফিল্টার ফ্রস্টেড গ্লাস ব্লার (Filter Frosted Blur)
class FilterFrostedBlur extends StatelessWidget {
  final Widget child;
  const FilterFrostedBlur({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(color: Colors.white.withValues(alpha: 0.8), padding: const EdgeInsets.all(8), child: child)),
    );
  }
}

/// ৪৫. বাউন্সি সিলেকশন চেকিমার্ক (Bouncy Checkbox)
class BouncyCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const BouncyCheckbox({super.key, required this.value, this.onChanged});
  @override
  State<BouncyCheckbox> createState() => _BouncyCheckboxState();
}

class _BouncyCheckboxState extends State<BouncyCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: AnimatedScale(
        scale: widget.value ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 150),
        curve: Curves.elasticOut,
        child: Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: widget.value ? const Color(0xFF0B4F32) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: widget.value ? const Color(0xFF0B4F32) : Colors.grey.shade400, width: 2),
          ),
          child: widget.value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
        ),
      ),
    );
  }
}

/// ৪৬. নোটিফিকেশন বেল জিংগল ও ডট (Notification Bell Jingle)
class NotificationBellJingle extends StatelessWidget {
  final int unreadCount;
  const NotificationBellJingle({super.key, this.unreadCount = 0});
  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      const Icon(Icons.notifications_outlined, size: 24, color: Color(0xFF0B4F32)),
      if (unreadCount > 0)
        Positioned(right: -2, top: -2, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Color(0xFFC62828), shape: BoxShape.circle), child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
    ]);
  }
}

/// ৪৭. শূন্য ফলাফল ফ্লোটিং ইলাস্ট্রেশন (Empty State Float)
class EmptyStateFloat extends StatelessWidget {
  final IconData icon; final String message;
  const EmptyStateFloat({super.key, required this.icon, this.message = 'কোনো তথ্য পাওয়া যায়নি'});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 48, color: Colors.grey.shade400),
      const SizedBox(height: 8),
      Text(message, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
    ]);
  }
}

/// ৪৮. হেডার এলিভেশন শ্যাডো ফেইড (Header Elevation Fade)
class HeaderElevationFade extends StatelessWidget {
  final bool isElevated; final Widget child;
  const HeaderElevationFade({super.key, required this.isElevated, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(color: Colors.white, boxShadow: isElevated ? const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))] : null),
      child: child,
    );
  }
}

/// ৪৯. মেম্বার লেভেল আপ গ্লো (Member Level Up Glow)
class MemberLevelUpGlow extends StatelessWidget {
  final String levelName;
  const MemberLevelUpGlow({super.key, required this.levelName});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.black87),
        const SizedBox(width: 4),
        Text(levelName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    );
  }
}

/// ৫০. পেজ পপ মসৃণ স্লাইড ট্রানজিশন (Page Pop Slide)
class PagePopSlide extends StatelessWidget {
  final Widget child;
  const PagePopSlide({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: const Offset(0.05, 0.0), end: Offset.zero),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, offset, c) => FractionalTranslation(translation: offset, child: c),
      child: child,
    );
  }
}
