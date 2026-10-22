import 'package:flutter/material.dart';

String _toBn(int n) {
  var s = '$n';
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  for (int i = 0; i < 10; i++) { s = s.replaceAll(en[i], bn[i]); }
  return s;
}

/// ৪১. লিস্ট আইটেম ডিলিট কোলাপস ট্রানজিশন (List Item Delete Collapse)
class ListItemDeleteCollapse extends StatelessWidget {
  final bool isDeleted; final Widget child;
  const ListItemDeleteCollapse({super.key, required this.isDeleted, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: isDeleted ? const SizedBox.shrink() : child,
    );
  }
}

/// ৪২. রিফ্রেশ ক্রসফেড ওয়াইপ ট্রানজিশন (Refresh Crossfade Wipe)
class RefreshCrossfadeWipe extends StatelessWidget {
  final bool isRefreshing; final Widget child;
  const RefreshCrossfadeWipe({super.key, required this.isRefreshing, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isRefreshing ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}

/// ৪৩. স্কেলিটন-টু-রিয়েল কন্টেন্ট ফেড-ইন (Skeleton to Content Fade In)
class SkeletonToContentFadeIn extends StatelessWidget {
  final bool isLoading; final Widget skeleton; final Widget content;
  const SkeletonToContentFadeIn({super.key, required this.isLoading, required this.skeleton, required this.content});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: skeleton, secondChild: content,
      crossFadeState: isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 280),
    );
  }
}

/// ৪৪. ট্যাব কন্টেন্ট ডাইরেকশনাল ওয়াইপ (Tab Content Slide Wipe)
class TabContentSlideWipe extends StatelessWidget {
  final int tabIndex; final Widget child;
  const TabContentSlideWipe({super.key, required this.tabIndex, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (w, a) => SlideTransition(position: Tween<Offset>(begin: const Offset(0.04, 0.0), end: Offset.zero).animate(a), child: FadeTransition(opacity: a, child: w)),
      child: KeyedSubtree(key: ValueKey(tabIndex), child: child),
    );
  }
}

/// ৪৫. ব্যাজ কাউন্টার পপ ট্রানজিশন (Badge Count Pop Transition)
class BadgeCountPopTransition extends StatelessWidget {
  final int count;
  const BadgeCountPopTransition({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: count > 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(10)),
        child: Text(_toBn(count), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// ৪৬. সার্কুলার চেকবক্স ক্রসফেড চেক (Checkbox Crossfade Check)
class CheckboxCrossfadeCheck extends StatelessWidget {
  final bool isChecked;
  const CheckboxCrossfadeCheck({super.key, required this.isChecked});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFF0B4F32) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: isChecked ? const Color(0xFF0B4F32) : Colors.grey.shade400, width: 2),
      ),
      child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
    );
  }
}

/// ৪৭. সর্ট অর্ডার অ্যারো ফ্লিপ ট্রানজিশন (Sort Order Arrow Flip)
class SortOrderArrowFlip extends StatelessWidget {
  final bool isAscending;
  const SortOrderArrowFlip({super.key, required this.isAscending});
  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: isAscending ? 0.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: const Icon(Icons.arrow_upward_rounded, size: 18, color: Color(0xFF0B4F32)),
    );
  }
}

/// ৪৮. স্ট্যাটাস পিল কালার শিফট ট্রানজিশন (Status Pill Color Shift)
class StatusPillColorShift extends StatelessWidget {
  final bool isApproved; final String statusText;
  const StatusPillColorShift({super.key, required this.isApproved, required this.statusText});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved ? const Color(0xFFD8F3DC) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(statusText, style: TextStyle(color: isApproved ? const Color(0xFF0B4F32) : const Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

/// ৪৯. এম্পটি স্টেট টু রেজাল্ট মর্ফ (Empty to Results Morph)
class EmptyToResultsMorph extends StatelessWidget {
  final bool hasData; final Widget emptyView; final Widget resultsView;
  const EmptyToResultsMorph({super.key, required this.hasData, required this.emptyView, required this.resultsView});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: emptyView, secondChild: resultsView,
      crossFadeState: hasData ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 250),
    );
  }
}

/// ৫০. পেজিনেশন গ্রিড হরিজন্টাল স্লাইড (Pagination Page Slide)
class PaginationPageSlide extends StatelessWidget {
  final int pageNumber; final Widget child;
  const PaginationPageSlide({super.key, required this.pageNumber, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (w, a) => SlideTransition(position: Tween<Offset>(begin: const Offset(0.08, 0.0), end: Offset.zero).animate(a), child: FadeTransition(opacity: a, child: w)),
      child: KeyedSubtree(key: ValueKey(pageNumber), child: child),
    );
  }
}
