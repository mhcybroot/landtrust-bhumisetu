import 'package:flutter/material.dart';
import '../animations/animated_count_text.dart';
import '../animations/sheen_sweep_effect.dart';

class StatusBadge extends StatelessWidget {
  final String? status;

  const StatusBadge({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final t = status ?? 'PENDING';
    final isSuccess = t.contains('ACTIVE') ||
        t.contains('APPROVED') ||
        t.contains('VERIFIED') ||
        t.contains('PAID') ||
        t.contains('AGREED') ||
        t.contains('CLOSED');
    final isDanger = t.contains('SUSPENDED') || t.contains('REJECTED');

    final color = isSuccess
        ? Colors.green.shade700
        : (isDanger ? Colors.red.shade700 : Colors.orange.shade800);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        t,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class VerificationBadge extends StatelessWidget {
  final String? status;

  const VerificationBadge({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final s = status ?? 'PENDING';
    final isVerified = s == 'FIELD_VERIFIED' || s == 'DOC_CHECKED' || s.contains('VERIFIED') || s.contains('APPROVED');
    Widget badge;
    if (s == 'FIELD_VERIFIED') {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Text('🟢 সরেজমিনে যাচাইকৃত',
            style: TextStyle(color: Colors.green.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    } else if (s == 'DOC_CHECKED') {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.shade300),
        ),
        child: Text('🔵 কাগজপত্র যাচাইকৃত',
            style: TextStyle(color: Colors.blue.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    } else if (s.contains('APPROVED') || s.contains('VERIFIED')) {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: Text('🟢 যাচাইকৃত বিজ্ঞাপন',
            style: TextStyle(color: Colors.green.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Text('🟡 যাচাই প্রক্রিয়াধীন',
            style: TextStyle(color: Colors.orange.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
      );
    }

    return isVerified ? SheenSweepEffect(child: badge) : badge;
  }
}

class StatCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final double? width;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 285,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: AnimatedCountText(text: value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
