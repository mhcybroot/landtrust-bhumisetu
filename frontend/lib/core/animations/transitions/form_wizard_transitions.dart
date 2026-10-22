import 'package:flutter/material.dart';

/// ৫১. স্টেপ স্লাইড ফেড ট্রানজিশন (Step Slide Fade Transition)
class StepSlideFadeTransition extends StatelessWidget {
  final int currentStep; final Widget child;
  const StepSlideFadeTransition({super.key, required this.currentStep, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (w, a) => SlideTransition(position: Tween<Offset>(begin: const Offset(0.06, 0.0), end: Offset.zero).animate(a), child: FadeTransition(opacity: a, child: w)),
      child: KeyedSubtree(key: ValueKey(currentStep), child: child),
    );
  }
}

/// ৫২. স্টেপ প্রগ্রেস গ্রোথ ট্রানজিশন (Step Progress Growth Transition)
class StepProgressGrowthTransition extends StatelessWidget {
  final double progress;
  const StepProgressGrowthTransition({super.key, required this.progress});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6, width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(3)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(3))),
      ),
    );
  }
}

/// ৫৩. ফিল্ড এরর শেক ট্রানজিশন (Field Error Shake Transition)
class FieldErrorShakeTransition extends StatelessWidget {
  final bool hasError; final Widget child;
  const FieldErrorShakeTransition({super.key, required this.hasError, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: hasError ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticIn,
      builder: (_, val, c) => Transform.translate(offset: Offset(hasError ? (val * 4) : 0, 0), child: c),
      child: child,
    );
  }
}

/// ৫৪. ফেস স্ক্যানার ফ্রেম মর্ফ (Face Scanner Frame Morph)
class FaceScannerFrameMorph extends StatelessWidget {
  final bool isBiometricMode;
  const FaceScannerFrameMorph({super.key, required this.isBiometricMode});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isBiometricMode ? 140 : 180,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isBiometricMode ? 70 : 12),
        border: Border.all(color: const Color(0xFF10B981), width: 2),
      ),
      child: Icon(isBiometricMode ? Icons.face_rounded : Icons.badge_outlined, color: const Color(0xFF10B981), size: 40),
    );
  }
}

/// ৫৫. সাবমিট বাটন লোডার টু সাকসেস (Submit Button Loader to Success)
class SubmitButtonLoaderToSuccess extends StatelessWidget {
  final bool isLoading; final bool isSuccess; final String label;
  const SubmitButtonLoaderToSuccess({super.key, required this.isLoading, required this.isSuccess, required this.label});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: isSuccess ? const Color(0xFF10B981) : const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: isSuccess ? const Icon(Icons.check, color: Colors.white, size: 20) : (isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

/// ৫৬. ক্যাসকেডিং ড্রপডাউন ট্রানজিশন (Cascading Dropdown Transition)
class CascadingDropdownTransition extends StatelessWidget {
  final bool isVisible; final Widget child;
  const CascadingDropdownTransition({super.key, required this.isVisible, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: isVisible ? child : const SizedBox.shrink(),
    );
  }
}

/// ৫৭. ইউনিট কনভার্টার স্পিন ট্রানজিশন (Unit Converter Spin Transition)
class UnitConverterSpinTransition extends StatelessWidget {
  final bool isKatha;
  const UnitConverterSpinTransition({super.key, required this.isKatha});
  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: isKatha ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(12)),
        child: Text(isKatha ? 'কাঠা' : 'শতাংশ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }
}

/// ৫৮. ড্রাফট অটো-সেভ ফ্ল্যাশ (Draft Auto-Save Flash)
class DraftAutoSaveFlash extends StatelessWidget {
  final bool isSaving; final Widget child;
  const DraftAutoSaveFlash({super.key, required this.isSaving, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(border: Border.all(color: isSaving ? const Color(0xFF10B981) : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(8)),
      child: child,
    );
  }
}

/// ৫৯. প্রাইস স্লাইডার বাবল পপ (Price Slider Bubble Pop)
class PriceSliderBubblePop extends StatelessWidget {
  final String priceText; final bool isDragging;
  const PriceSliderBubblePop({super.key, required this.priceText, required this.isDragging});
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isDragging ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.elasticOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFF0B4F32), borderRadius: BorderRadius.circular(6)),
        child: Text(priceText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// ৬০. আপলোড রিং টু কমপ্লিট ট্রানজিশন (Upload Ring to Complete)
class UploadRingToCompleteTransition extends StatelessWidget {
  final bool isCompleted; final double progress;
  const UploadRingToCompleteTransition({super.key, required this.isCompleted, required this.progress});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted ? const Color(0xFF10B981) : Colors.transparent),
      child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 18) : CircularProgressIndicator(value: progress.clamp(0.0, 1.0), strokeWidth: 2.5, color: const Color(0xFF0B4F32)),
    );
  }
}
