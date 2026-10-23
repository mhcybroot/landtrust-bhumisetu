import 'package:flutter/material.dart';
import 'modal_dialog_transitions.dart';

/// রিয়েল-টাইম স্প্রিং বাউন্স ও ব্যাকড্রপ ব্লার সহ স্মুথ ডায়ালগ এন্ট্রান্স হেল্পার
class AppDialogTransition {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color barrierColor = const Color(0x8A000000),
    Duration transitionDuration = const Duration(milliseconds: 320),
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      pageBuilder: (ctx, _, _) => builder(ctx),
      transitionBuilder: (ctx, _, _, child) => BackdropBlurRevealTransition(
        child: ScaleBounceDialogTransition(child: child),
      ),
    );
  }
}
