import 'package:flutter/material.dart';

/// ২১. প্রোপার্টি কার্ড থেকে ফুল ডিটেইলস মর্ফ (Property Card to Detail Morph)
class PropertyCardToDetailMorph extends StatelessWidget {
  final bool isExpanded; final Widget collapsed; final Widget expanded; final String? heroTag;
  const PropertyCardToDetailMorph({super.key, required this.isExpanded, required this.collapsed, required this.expanded, this.heroTag});
  @override
  Widget build(BuildContext context) {
    final w = AnimatedCrossFade(
      firstChild: collapsed, secondChild: expanded,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
    return heroTag != null ? Hero(tag: heroTag!, child: w) : w;
  }
}

/// ২২. ফ্লোটিং সার্চ পিল থেকে হেডার মর্ফ (Floating Search to Header Morph)
class FloatingSearchToHeaderMorph extends StatelessWidget {
  final bool isExpanded; final Widget searchBar; final Widget headerBar;
  const FloatingSearchToHeaderMorph({super.key, required this.isExpanded, required this.searchBar, required this.headerBar});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: searchBar, secondChild: headerBar,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 280),
    );
  }
}

/// ২৩. মিনি প্লট বাউন্ডারি থেকে ফুল ম্যাপ হিরো (Map Plot to Fullscreen Hero)
class MapPlotToFullscreenHero extends StatelessWidget {
  final bool isExpanded; final Widget miniPlot; final Widget fullscreenPlot;
  const MapPlotToFullscreenHero({super.key, required this.isExpanded, required this.miniPlot, required this.fullscreenPlot});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: miniPlot, secondChild: fullscreenPlot,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 320),
    );
  }
}

/// ২৪. সার্কুলার অবতার থেকে প্রোফাইল কার্ড মর্ফ (Avatar to Profile Badge Morph)
class AvatarToProfileBadgeMorph extends StatelessWidget {
  final bool isExpanded; final Widget avatar; final Widget badge;
  const AvatarToProfileBadgeMorph({super.key, required this.isExpanded, required this.avatar, required this.badge});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: avatar, secondChild: badge,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 250),
    );
  }
}

/// ২৫. গ্রিড থাম্বনেইল থেকে লাইটবক্স মর্ফ (Thumbnail Grid to Lightbox Morph)
class ThumbnailGridToLightboxMorph extends StatelessWidget {
  final bool isExpanded; final Widget thumbnail; final Widget lightbox;
  const ThumbnailGridToLightboxMorph({super.key, required this.isExpanded, required this.thumbnail, required this.lightbox});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: thumbnail, secondChild: lightbox,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}

/// ২৬. এফএবি বাটন থেকে শিট মর্ফ (FAB to Sheet Morph)
class FabToSheetMorph extends StatelessWidget {
  final bool isExpanded; final Widget fab; final Widget sheet;
  const FabToSheetMorph({super.key, required this.isExpanded, required this.fab, required this.sheet});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: fab, secondChild: sheet,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 280),
    );
  }
}

/// ২৭. খতিয়ান টাইল থেকে দলিল রিডার মর্ফ (Khatiyan Tile to Deed Viewer Morph)
class KhatiyanTileToDeedViewerMorph extends StatelessWidget {
  final bool isExpanded; final Widget tile; final Widget viewer;
  const KhatiyanTileToDeedViewerMorph({super.key, required this.isExpanded, required this.tile, required this.viewer});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: tile, secondChild: viewer,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}

/// ২৮. মেম্বারশিপ ব্যাজ লেভেল আপ মর্ফ (Badge Level Up Morph)
class BadgeLevelUpMorph extends StatelessWidget {
  final bool isLevelUp; final Widget initialBadge; final Widget upgradedBadge;
  const BadgeLevelUpMorph({super.key, required this.isLevelUp, required this.initialBadge, required this.upgradedBadge});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: initialBadge, secondChild: upgradedBadge,
      crossFadeState: isLevelUp ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 350),
    );
  }
}

/// ২৯. প্রাইস ট্যাগ থেকে এসক্রো ফর্ম হিরো (Price Tag to Escrow Hero)
class PriceTagToEscrowHero extends StatelessWidget {
  final bool isEscrowActive; final Widget priceTag; final Widget escrowField;
  const PriceTagToEscrowHero({super.key, required this.isEscrowActive, required this.priceTag, required this.escrowField});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: priceTag, secondChild: escrowField,
      crossFadeState: isEscrowActive ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 280),
    );
  }
}

/// ৩০. প্লট মার্কার থেকে বটম প্রিভিউ মর্ফ (Plot Marker to Bottom Preview Morph)
class PlotMarkerToBottomPreviewMorph extends StatelessWidget {
  final bool isSelected; final Widget marker; final Widget preview;
  const PlotMarkerToBottomPreviewMorph({super.key, required this.isSelected, required this.marker, required this.preview});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: marker, secondChild: preview,
      crossFadeState: isSelected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 260),
    );
  }
}
