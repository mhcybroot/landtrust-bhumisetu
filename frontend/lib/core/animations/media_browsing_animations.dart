import 'package:flutter/material.dart';

/// ১. ক্যারোজেল পেজার ডট স্ট্রেচ (Worm Page Indicator)
class WormPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color dotColor;

  const WormPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor = const Color(0xFF0B4F32),
    this.dotColor = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (idx) {
        final isSelected = idx == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isSelected ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : dotColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// ২. ডাবল-ট্যাপ স্মার্ট স্প্রিং জুম (Smart Interactive Zoom)
class SmartInteractiveZoom extends StatefulWidget {
  final Widget child;
  final double maxScale;

  const SmartInteractiveZoom({super.key, required this.child, this.maxScale = 2.5});

  @override
  State<SmartInteractiveZoom> createState() => _SmartInteractiveZoomState();
}

class _SmartInteractiveZoomState extends State<SmartInteractiveZoom> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _scaleAnimation;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final target = _currentScale > 1.0 ? 1.0 : widget.maxScale;
    _scaleAnimation = Tween<double>(begin: _currentScale, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    )..addListener(() => setState(() => _currentScale = _scaleAnimation.value));
    _ctrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Transform.scale(scale: _currentScale, child: widget.child),
    );
  }
}

/// ৩. জমির উন্নয়নের আগের ও পরের ইন্টারেক্টিভ স্লাইডার (Before/After Slider)
class BeforeAfterSlider extends StatefulWidget {
  final Widget before;
  final Widget after;
  final double initialSplit;

  const BeforeAfterSlider({
    super.key,
    required this.before,
    required this.after,
    this.initialSplit = 0.5,
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  late double _split = widget.initialSplit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final splitX = (w * _split).clamp(0.0, w);

        return Stack(
          children: [
            Positioned.fill(child: widget.after),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: splitX,
              child: ClipRect(child: OverflowBox(maxWidth: w, maxHeight: h, alignment: Alignment.centerLeft, child: widget.before)),
            ),
            Positioned(
              left: splitX - 1.5,
              top: 0,
              bottom: 0,
              child: Container(width: 3, color: Colors.white),
            ),
            Positioned(
              left: splitX - 16,
              top: (h / 2) - 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (d) {
                  setState(() {
                    _split = ((splitX + d.delta.dx) / w).clamp(0.05, 0.95);
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4F32),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.code, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ৪. ইমেজ টিল্ট ও ৩D প্যারাল্যাক্স (Tilt Parallax Wrapper)
class TiltParallaxWrapper extends StatefulWidget {
  final Widget child;

  const TiltParallaxWrapper({super.key, required this.child});

  @override
  State<TiltParallaxWrapper> createState() => _TiltParallaxWrapperState();
}

class _TiltParallaxWrapperState extends State<TiltParallaxWrapper> {
  Offset _tilt = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final size = box.size;
        final local = e.localPosition;
        final dx = (local.dx / size.width) - 0.5;
        final dy = (local.dy / size.height) - 0.5;
        setState(() => _tilt = Offset(dx, dy));
      },
      onExit: (_) => setState(() => _tilt = Offset.zero),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(_tilt.dx * 0.12)
          ..rotateX(-_tilt.dy * 0.12),
        child: widget.child,
      ),
    );
  }
}
