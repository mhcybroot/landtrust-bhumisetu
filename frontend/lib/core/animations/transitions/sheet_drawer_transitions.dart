import 'package:flutter/material.dart';

/// ৩১. ড্র্যাগেবল বটম শিট স্ন্যাপার (Smooth Sheet Drag Snapper)
class SmoothSheetDragSnapper extends StatelessWidget {
  final Widget child;
  const SmoothSheetDragSnapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 8), width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        child,
      ]),
    );
  }
}

/// ৩২. ফিল্টার ড্রয়ার ফোল্ড ট্রানজিশন (Filter Drawer Fold Transition)
class FilterDrawerFoldTransition extends StatelessWidget {
  final bool isOpen; final Widget child;
  const FilterDrawerFoldTransition({super.key, required this.isOpen, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: isOpen ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (_, val, c) => FractionalTranslation(
        translation: Offset(1.0 - val, 0.0),
        child: Opacity(opacity: val.clamp(0.0, 1.0), child: c),
      ),
      child: child,
    );
  }
}

/// ৩৩. স্টিকি হেডার শ্রাঙ্ক ট্রানজিশন (Sticky Header Shrink Transition)
class StickyHeaderShrinkTransition extends StatelessWidget {
  final String title; final bool isShrunk;
  const StickyHeaderShrinkTransition({super.key, required this.title, required this.isShrunk});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isShrunk ? 8 : 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: isShrunk ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isShrunk ? 15 : 18, color: const Color(0xFF0B4F32))),
    );
  }
}

/// ৩৪. অ্যাকর্ডিয়ন শেলফ এক্সপ্যান্ড ট্রানজিশন (Accordion Shelf Expand)
class AccordionShelfExpandTransition extends StatelessWidget {
  final bool isExpanded; final Widget child;
  const AccordionShelfExpandTransition({super.key, required this.isExpanded, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: isExpanded ? child : const SizedBox.shrink(),
    );
  }
}

/// ৩৫. রোটেটিং শেভরন ড্রপডাউন ট্রানজিশন (Rotating Chevron Dropdown)
class RotatingChevronDropdownTransition extends StatelessWidget {
  final bool isDropped; final String title;
  const RotatingChevronDropdownTransition({super.key, required this.isDropped, required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(width: 6),
      AnimatedRotation(turns: isDropped ? 0.5 : 0.0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20)),
    ]);
  }
}

/// ৩৬. মাল্টি-ট্যাব স্লাইড ফেড ট্রানজিশন (Multi-Tab Slide Fade Transition)
class MultiTabSlideFadeTransition extends StatelessWidget {
  final int activeTab; final Widget child;
  const MultiTabSlideFadeTransition({super.key, required this.activeTab, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (w, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.05, 0.0), end: Offset.zero).animate(a), child: w)),
      child: KeyedSubtree(key: ValueKey(activeTab), child: child),
    );
  }
}

/// ৩৭. স্প্লিট ড্রয়ার ডক ট্রানজিশন (Split Drawer Dock Transition)
class SplitDrawerDockTransition extends StatelessWidget {
  final bool isDocked; final Widget child;
  const SplitDrawerDockTransition({super.key, required this.isDocked, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: isDocked ? 280 : 0,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Colors.grey.shade200))),
      child: child,
    );
  }
}

/// ৩৮. কার্ভড এজ পুল-টু-রিফ্রেশ ট্রানজিশন (Curved Edge Pull Transition)
class CurvedEdgePullTransition extends StatelessWidget {
  final double pullDistance; final Widget child;
  const CurvedEdgePullTransition({super.key, required this.pullDistance, required this.child});
  @override
  Widget build(BuildContext context) {
    return Transform.translate(offset: Offset(0, pullDistance.clamp(0.0, 80.0)), child: child);
  }
}

/// ৩৯. ফ্লোটিং ডক কোলাপস ট্রানজিশন (Floating Dock Collapse Transition)
class FloatingDockCollapseTransition extends StatelessWidget {
  final bool isVisible; final Widget child;
  const FloatingDockCollapseTransition({super.key, required this.isVisible, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

/// ৪০. ফ্লোটিং অ্যাকশন মেনু রেডিয়াল আনফার্ল (Radial Menu Unfurl)
class FloatingActionMenuRadialUnfurl extends StatelessWidget {
  final bool isOpen; final Widget child;
  const FloatingActionMenuRadialUnfurl({super.key, required this.isOpen, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.elasticOut,
      child: child,
    );
  }
}
