import 'dart:math' show pi;
import 'package:flutter/material.dart';

/// 81. Payment Success Coin Drop Transition
class PaymentSuccessCoinDropTransition extends StatelessWidget {
  final bool isSuccess;
  final Widget child;
  const PaymentSuccessCoinDropTransition({super.key, required this.isSuccess, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: isSuccess ? -50.0 : 0.0, end: 0.0),
    duration: const Duration(milliseconds: 500),
    curve: Curves.bounceOut,
    builder: (_, y, ch) => Transform.translate(offset: Offset(0, y), child: ch),
    child: child,
  );
}

/// 82. Escrow Status Progress Step Transition
class EscrowStatusProgressStepTransition extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const EscrowStatusProgressStepTransition({super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(totalSteps, (i) => Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 6,
        decoration: BoxDecoration(color: i < currentStep ? Colors.teal : Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
      ),
    )),
  );
}

/// 83. Bank Card 3D Flip CVV Transition
class BankCardFlipCvvTransition extends StatelessWidget {
  final bool showBack;
  final Widget front;
  final Widget back;
  const BankCardFlipCvvTransition({super.key, required this.showBack, required this.front, required this.back});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: showBack ? pi : 0.0),
    duration: const Duration(milliseconds: 400),
    builder: (_, angle, _) => Transform(
      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
      alignment: Alignment.center,
      child: angle > pi / 2 ? Transform(transform: Matrix4.identity()..rotateY(pi), alignment: Alignment.center, child: back) : front,
    ),
  );
}

/// 84. BDT Tk Currency Rolling Odometer Transition
class TkCurrencyRollingOdometerTransition extends StatelessWidget {
  final int amount;
  const TkCurrencyRollingOdometerTransition({super.key, required this.amount});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<int>(
    tween: IntTween(begin: 0, end: amount),
    duration: const Duration(milliseconds: 600),
    curve: Curves.easeOutCubic,
    builder: (_, val, _) => Text('৳ ${_formatNumber(val)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  );

  String _formatNumber(int val) {
    final s = val.toString();
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final code = s.codeUnitAt(i) - 48;
      sb.write(code >= 0 && code <= 9 ? bn[code] : s[i]);
    }
    return sb.toString();
  }
}

/// 85. OTP Digit Box Pulse Focus Transition
class OtpDigitBoxPulseTransition extends StatelessWidget {
  final bool isFocused;
  final Widget child;
  const OtpDigitBoxPulseTransition({super.key, required this.isFocused, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      border: Border.all(color: isFocused ? Colors.teal : Colors.grey.shade400, width: isFocused ? 2 : 1),
      borderRadius: BorderRadius.circular(8),
      boxShadow: isFocused ? [BoxShadow(color: Colors.teal.withValues(alpha: 0.2), blurRadius: 6)] : null,
    ),
    child: child,
  );
}

/// 86. Digital Receipt Fold/Unfold Transition
class DigitalReceiptFoldUnfoldTransition extends StatelessWidget {
  final bool isUnfolded;
  final Widget child;
  const DigitalReceiptFoldUnfoldTransition({super.key, required this.isUnfolded, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOutCubic,
    child: isUnfolded ? child : const SizedBox.shrink(),
  );
}

/// 87. Commission Split Sliding Bar
class CommissionSplitSlidingBar extends StatelessWidget {
  final double platformRatio;
  const CommissionSplitSlidingBar({super.key, required this.platformRatio});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: platformRatio.clamp(0.0, 1.0)),
    duration: const Duration(milliseconds: 400),
    builder: (_, ratio, _) => ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(flex: (ratio * 100).toInt(), child: Container(color: Colors.teal)),
            Expanded(flex: ((1.0 - ratio) * 100).toInt(), child: Container(color: Colors.amber)),
          ],
        ),
      ),
    ),
  );
}

/// 88. Security Shield Lock Snap
class SecurityShieldLockSnap extends StatelessWidget {
  final bool isLocked;
  const SecurityShieldLockSnap({super.key, required this.isLocked});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (ch, anim) => ScaleTransition(scale: anim, child: ch),
    child: Icon(
      isLocked ? Icons.verified_user : Icons.lock_open,
      key: ValueKey<bool>(isLocked),
      color: isLocked ? Colors.teal : Colors.grey,
      size: 30,
    ),
  );
}

/// 89. Payout Transfer Flying Arrow
class PayoutTransferFlyArrow extends StatelessWidget {
  final bool isTransferring;
  const PayoutTransferFlyArrow({super.key, required this.isTransferring});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.0, end: isTransferring ? 1.0 : 0.0),
    duration: const Duration(milliseconds: 500),
    builder: (_, factor, _) => Transform.translate(
      offset: Offset(30 * factor, 0),
      child: Opacity(
        opacity: (1.0 - factor * 0.5).clamp(0.0, 1.0),
        child: const Icon(Icons.send_rounded, color: Colors.teal, size: 26),
      ),
    ),
  );
}

/// 90. Invoice QR Code Zoom Reveal
class InvoiceQrCodeZoomReveal extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  const InvoiceQrCodeZoomReveal({super.key, required this.isVisible, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: isVisible ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutBack,
    child: AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: child,
    ),
  );
}
