import 'package:flutter/material.dart';

class HorizontalScrollFadeView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final double fadeWidth;

  const HorizontalScrollFadeView({
    super.key,
    required this.child,
    this.padding,
    this.controller,
    this.fadeWidth = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final width = bounds.width;
            if (width <= fadeWidth * 2) {
              return const LinearGradient(
                colors: [Colors.white, Colors.white],
              ).createShader(bounds);
            }
            final rightStop = 1.0 - (fadeWidth / width);

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [
                0.0,
                rightStop.clamp(0.7, 0.96),
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: padding,
            child: child,
          ),
        );
      },
    );
  }
}
