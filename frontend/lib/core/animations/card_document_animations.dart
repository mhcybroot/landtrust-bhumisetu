import 'dart:math';
import 'package:flutter/material.dart';

/// ৯. ফেভারিট হার্ট স্পার্কল বার্স্ট (Heart Burst Animation)
class HeartBurstAnimation extends StatefulWidget {
  final bool isFavorite;
  final ValueChanged<bool> onChanged;

  const HeartBurstAnimation({super.key, required this.isFavorite, required this.onChanged});

  @override
  State<HeartBurstAnimation> createState() => _HeartBurstAnimationState();
}

class _HeartBurstAnimationState extends State<HeartBurstAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.onChanged(!widget.isFavorite);
    if (!widget.isFavorite) _ctrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => Transform.scale(
          scale: widget.isFavorite ? (1.0 + sin(_ctrl.value * pi) * 0.25) : 1.0,
          child: Icon(
            widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: widget.isFavorite ? const Color(0xFFE53935) : Colors.grey.shade600,
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// ১০. খতিয়ান ও লিগ্যাল ডকুমেন্ট অ্যাকর্ডিয়ন (Accordion Expansion Tile)
class AccordionTile extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;

  const AccordionTile({super.key, required this.title, required this.content, this.initiallyExpanded = false});

  @override
  State<AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<AccordionTile> with SingleTickerProviderStateMixin {
  late bool _expanded = widget.initiallyExpanded;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 240), value: _expanded ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: widget.title),
                  RotationTransition(turns: Tween(begin: 0.0, end: 0.5).animate(_ctrl), child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20)),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
            child: Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 12), child: widget.content),
          ),
        ],
      ),
    );
  }
}

/// ১১. নোটিফিকেশন সোয়াইপ-টু-অ্যাকশন কালার রিভিল (Swipe Action Reveal)
class SwipeActionReveal extends StatelessWidget {
  final Widget child;
  final String actionText;
  final VoidCallback? onDismissed;
  final Key? itemKey;

  const SwipeActionReveal({super.key, required this.child, required this.actionText, this.onDismissed, this.itemKey});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey ?? key ?? ValueKey(actionText),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        decoration: BoxDecoration(color: Colors.red.shade600, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(actionText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// ১২. কাস্টম কম্পাস রিফ্রেশ স্পিনার (Compass Refresh Spinner)
class CompassRefreshSpinner extends StatefulWidget {
  final double size;
  final Color color;

  const CompassRefreshSpinner({super.key, this.size = 28.0, this.color = const Color(0xFF0B4F32)});

  @override
  State<CompassRefreshSpinner> createState() => _CompassRefreshSpinnerState();
}

class _CompassRefreshSpinnerState extends State<CompassRefreshSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Icon(Icons.explore_outlined, size: widget.size, color: widget.color),
    );
  }
}
