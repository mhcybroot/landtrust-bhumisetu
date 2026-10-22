import 'package:flutter/material.dart';

/// ১১. সরকারি বিশ্বস্ততা সিলমোহর (Trust Seal Stamp)
class TrustSealStamp extends StatelessWidget {
  final double size;
  const TrustSealStamp({super.key, this.size = 48});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD97706), width: 2.5), color: const Color(0xFFFEF3C7)),
      child: const Center(child: Icon(Icons.verified_user_rounded, color: Color(0xFFD97706), size: 26)),
    );
  }
}

/// ১২. খতিয়ান পৃষ্ঠা বাঁকানো কার্ল (Khatiyan Page Curl)
class KhatiyanPageCurl extends StatelessWidget {
  const KhatiyanPageCurl({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16))));
  }
}

/// ১৩. মালিকানা চেইন ট্রি প্রসারিত হওয়া (Ownership Chain Tree)
class OwnershipChainTree extends StatelessWidget {
  final List<String> steps;
  const OwnershipChainTree({super.key, required this.steps});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: steps.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(6)), child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))).toList());
  }
}

/// ১৪. ডকুমেন্ট স্ক্যানার লেজার বার (Document Scanner Laser)
class DocumentScannerLaser extends StatefulWidget {
  const DocumentScannerLaser({super.key});
  @override
  State<DocumentScannerLaser> createState() => _DocumentScannerLaserState();
}

class _DocumentScannerLaserState extends State<DocumentScannerLaser> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(offset: Offset(0, _ctrl.value * 60), child: child),
      child: Container(height: 2.5, width: 140, decoration: const BoxDecoration(color: Colors.greenAccent, boxShadow: [BoxShadow(color: Colors.green, blurRadius: 4)])),
    );
  }
}

/// ১৫. দলিলের নিরাপত্তা জলছাপ (Watermark Sheen Wave)
class WatermarkSheenWave extends StatelessWidget {
  final String text;
  const WatermarkSheenWave({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: 0.14, child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4)));
  }
}

/// ১৬. সাব-রেজিস্ট্রি দলিলের ফিতা ও গালা মোহর (Deed Ribbon Unfurl)
class DeedRibbonUnfurl extends StatelessWidget {
  const DeedRibbonUnfurl({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(width: 14, height: 42, decoration: const BoxDecoration(color: Color(0xFFB91C1C), borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))));
  }
}

/// ১৭. কিউআর কোড স্ক্যান ফ্রেম পালস (QR Code Scan Frame)
class QrCodeScanFrame extends StatelessWidget {
  const QrCodeScanFrame({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(width: 50, height: 50, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF0B4F32), width: 2), borderRadius: BorderRadius.circular(8)));
  }
}

/// ১৮. মামলা ও বিরোধ সতর্কতা বিকন (Injunction Warning Beacon)
class InjunctionWarningBeacon extends StatelessWidget {
  final String warningText;
  const InjunctionWarningBeacon({super.key, required this.warningText});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.shade100, border: Border.all(color: Colors.amber.shade800), borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber.shade900),
        const SizedBox(width: 4),
        Text(warningText, style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

/// ১৯. নামজারি খতিয়ান ফ্লিপ বোর্ড (Mutation Ledger Flip)
class MutationLedgerFlip extends StatelessWidget {
  final String mutationNo;
  const MutationLedgerFlip({super.key, required this.mutationNo});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
      child: Text(mutationNo, style: const TextStyle(color: Colors.yellowAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

/// ২০. ডিজিটাল স্বাক্ষর স্ট্রোক (Digital Signature Stroke)
class DigitalSignatureStroke extends StatelessWidget {
  const DigitalSignatureStroke({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(80, 24),
      painter: _SignaturePainter(),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()..moveTo(5, 18)..quadraticBezierTo(25, 2, 45, 14)..quadraticBezierTo(60, 22, 75, 8);
    canvas.drawPath(p, Paint()..color = const Color(0xFF1E3A8A)..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_SignaturePainter o) => false;
}
