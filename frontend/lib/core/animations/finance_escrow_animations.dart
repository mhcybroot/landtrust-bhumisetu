import 'dart:math';
import 'package:flutter/material.dart';

/// ২১. এসক্রো ভল্ট লক ও সেফগার্ড (Escrow Vault Lock)
class EscrowVaultLock extends StatelessWidget {
  final bool isLocked;
  const EscrowVaultLock({super.key, required this.isLocked});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(10)),
      child: Icon(isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded, color: Colors.white, size: 20),
    );
  }
}

/// ২২. ব্যাংক নোট কাউন্টার মেশিন (Bank Note Counter)
class BankNoteCounter extends StatelessWidget {
  final int notesCount;
  const BankNoteCounter({super.key, required this.notesCount});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.payments_outlined, color: Color(0xFF10B981), size: 18),
      const SizedBox(width: 4),
      Text('$notesCount বান্ডিল (৫০ বান্ডিল)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
    ]);
  }
}

/// ২৩. বায়না জামানতের সুরক্ষা বর্ম (Deposit Shield Pulse)
class DepositShieldPulse extends StatelessWidget {
  const DepositShieldPulse({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
      child: const Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 22),
    );
  }
}

/// ২৪. সরকারি ট্যাক্স ও ফি স্প্লিট বার (Tax Breakdown Split)
class TaxBreakdownSplit extends StatelessWidget {
  final double stampDutyPercent; final double regFeePercent; final double localTaxPercent;
  const TaxBreakdownSplit({super.key, required this.stampDutyPercent, required this.regFeePercent, required this.localTaxPercent});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(height: 8, child: Row(children: [
        Flexible(flex: (stampDutyPercent * 10).toInt(), child: Container(color: const Color(0xFF0B4F32))),
        Flexible(flex: (regFeePercent * 10).toInt(), child: Container(color: const Color(0xFF1E88E5))),
        Flexible(flex: (localTaxPercent * 10).toInt(), child: Container(color: const Color(0xFFE65100))),
      ])),
    );
  }
}

/// ২৫. কিস্তি পরিশোধের পথ ও মাইলস্টোন (Milestone Path Glow)
class MilestonePathGlow extends StatelessWidget {
  final int totalInstallments; final int paidInstallments;
  const MilestonePathGlow({super.key, required this.totalInstallments, required this.paidInstallments});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(totalInstallments, (i) {
      final isPaid = i < paidInstallments;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 16, height: 16,
        decoration: BoxDecoration(shape: BoxShape.circle, color: isPaid ? const Color(0xFF10B981) : Colors.grey.shade300),
        child: isPaid ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
      );
    }));
  }
}

/// ২৬. বায়না বাতিল ও রিফান্ড প্রবাহ (Refund Reversal Arrow)
class RefundReversalArrow extends StatelessWidget {
  const RefundReversalArrow({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
      child: const Icon(Icons.assignment_return_outlined, color: Colors.red, size: 16),
    );
  }
}

/// ২৭. লেজার এন্ট্রি স্লাইড-ইন রো (Ledger Slide Entry)
class LedgerSlideEntry extends StatelessWidget {
  final Widget child;
  const LedgerSlideEntry({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      builder: (_, val, c) => Opacity(opacity: val, child: Transform.translate(offset: Offset(0, (1.0 - val) * 12), child: c)),
      child: child,
    );
  }
}

/// ২৮. ইনস্ট্যান্ট ক্যাশব্যাক বলয় (Cashback Glow Ripple)
class CashbackGlowRipple extends StatelessWidget {
  final num amountTaka;
  const CashbackGlowRipple({super.key, required this.amountTaka});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), border: Border.all(color: const Color(0xFFF59E0B)), borderRadius: BorderRadius.circular(12)),
      child: Text('৳$amountTaka বোনাস', style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

/// ২৯. ইনভয়েস ও রসিদ ডাউনলোড প্রগ্রেস (Invoice Progress Bar)
class InvoiceProgressBar extends StatelessWidget {
  final double progress;
  const InvoiceProgressBar({super.key, required this.progress});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 6, color: const Color(0xFF0B4F32), backgroundColor: Colors.grey.shade200),
    );
  }
}

/// ৩০. ফি নির্ণায়ক স্পিডোমিটার (Fee Speedo Meter)
class FeeSpeedoMeter extends StatelessWidget {
  final double valueRatio;
  const FeeSpeedoMeter({super.key, required this.valueRatio});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(60, 32), painter: _MeterPainter(ratio: valueRatio.clamp(0.0, 1.0)));
  }
}

class _MeterPainter extends CustomPainter {
  final double ratio;
  _MeterPainter({required this.ratio});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height);
    canvas.drawArc(Rect.fromCircle(center: c, radius: size.height - 2), pi, pi, false, Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawArc(Rect.fromCircle(center: c, radius: size.height - 2), pi, pi * ratio, false, Paint()..color = const Color(0xFF0B4F32)..style = PaintingStyle.stroke..strokeWidth = 4);
  }
  @override
  bool shouldRepaint(_MeterPainter o) => o.ratio != ratio;
}
