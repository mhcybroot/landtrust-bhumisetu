import 'dart:convert';
import 'package:flutter/material.dart';
import '../animations/shimmer_effect.dart';

class SmartImageViewer extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableZoom;

  const SmartImageViewer({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableZoom = false,
  });

  Widget _buildShimmerPlaceholder() {
    return ShimmerEffect(
      child: Container(
        height: height,
        width: width,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      width: width,
      color: const Color(0xFFD8F3DC),
      child: const Center(
        child: Icon(Icons.landscape_rounded, size: 40, color: Color(0xFF1B5E20)),
      ),
    );

    Widget img = fallback;
    final trimmed = url?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      if (trimmed.startsWith('data:image/')) {
        try {
          final commaIdx = trimmed.indexOf(',');
          if (commaIdx != -1) {
            final bytes = base64Decode(trimmed.substring(commaIdx + 1));
            img = Image.memory(
              bytes,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (_, _, _) => fallback,
            );
          }
        } catch (_) {
          img = fallback;
        }
      } else {
        img = Image.network(
          trimmed,
          height: height,
          width: width,
          fit: fit,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              child: child,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildShimmerPlaceholder();
          },
          errorBuilder: (_, _, _) => fallback,
        );
      }
    }

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }

    if (enableZoom) {
      return InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.5,
        child: img,
      );
    }

    return img;
  }
}
