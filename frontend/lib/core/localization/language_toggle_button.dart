import 'package:flutter/material.dart';
import '../animations/bouncing_pressable.dart';
import 'locale_notifier.dart';

/// অ্যাপবারে ভাষা পরিবর্তনের আকর্ষণীয় ক্যাপসুল টগল বাটন।
class LanguageToggleButton extends StatelessWidget {
  final bool compact;

  const LanguageToggleButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleNotifier.instance,
      builder: (context, _) {
        final isBangla = LocaleNotifier.instance.isBangla;

        if (compact) {
          return BouncingPressable(
            onTap: LocaleNotifier.instance.toggleLanguage,
            scaleFactor: 0.94,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBangla ? '🇬🇧 EN' : '🇧🇩 বাং',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return BouncingPressable(
          onTap: LocaleNotifier.instance.toggleLanguage,
          scaleFactor: 0.94,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chip('🇧🇩 বাং', isBangla),
                const SizedBox(width: 4),
                _chip('🇬🇧 EN', !isBangla),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: active ? const Color(0xFF0B4F32) : Colors.white.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}

