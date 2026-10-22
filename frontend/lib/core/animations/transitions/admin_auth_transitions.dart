import 'package:flutter/material.dart';

/// 91. Role Switch Crossfade Transition
class RoleSwitchCrossfadeTransition extends StatelessWidget {
  final String roleName;
  final Widget child;
  const RoleSwitchCrossfadeTransition({super.key, required this.roleName, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (ch, anim) => FadeTransition(opacity: anim, child: ch),
    child: KeyedSubtree(key: ValueKey<String>(roleName), child: child),
  );
}

/// 92. Admin Dashboard Metric Card Staggered Slide
class AdminDashboardCardStaggerSlide extends StatelessWidget {
  final int index;
  final Widget child;
  const AdminDashboardCardStaggerSlide({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 250 + (index * 60).clamp(0, 500)),
    curve: Curves.easeOutQuad,
    builder: (_, val, ch) => Transform.translate(offset: Offset(0, 20 * (1.0 - val)), child: Opacity(opacity: val, child: ch)),
    child: child,
  );
}

/// 93. User Status Badge Morph Transition
class UserStatusBadgeMorphTransition extends StatelessWidget {
  final String status;
  const UserStatusBadgeMorphTransition({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final col = status == 'ACTIVE' ? Colors.teal : (status == 'PENDING' ? Colors.amber : Colors.red);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: col.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: col)),
      child: Text(status, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

/// 94. Audit Log Entry Expand Transition
class AuditLogEntryExpandTransition extends StatelessWidget {
  final bool isExpanded;
  final Widget child;
  const AuditLogEntryExpandTransition({super.key, required this.isExpanded, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeInOut,
    child: isExpanded ? child : const SizedBox.shrink(),
  );
}

/// 95. Biometric Scan Ripple Transition
class BiometricScanRippleTransition extends StatelessWidget {
  final bool isScanning;
  const BiometricScanRippleTransition({super.key, required this.isScanning});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 0.8, end: isScanning ? 1.2 : 1.0),
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
    builder: (_, s, _) => Transform.scale(
      scale: s,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isScanning ? Colors.teal : Colors.grey, width: 2)),
        child: Icon(Icons.fingerprint, color: isScanning ? Colors.teal : Colors.grey, size: 36),
      ),
    ),
  );
}

/// 96. Session Timeout Warning Slide Down Banner
class SessionTimeoutWarningSlide extends StatelessWidget {
  final bool isExpiring;
  final Widget child;
  const SessionTimeoutWarningSlide({super.key, required this.isExpiring, required this.child});

  @override
  Widget build(BuildContext context) => AnimatedSlide(
    offset: isExpiring ? Offset.zero : const Offset(0, -1),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutBack,
    child: AnimatedOpacity(opacity: isExpiring ? 1.0 : 0.0, duration: const Duration(milliseconds: 250), child: child),
  );
}

/// 97. Two-Factor Code Cell Slide Transition
class TwoFactorCodeCellSlide extends StatelessWidget {
  final String code;
  const TwoFactorCodeCellSlide({super.key, required this.code});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(4, (i) {
      final char = i < code.length ? code[i] : '';
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        width: 36,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: char.isNotEmpty ? Colors.teal : Colors.grey), borderRadius: BorderRadius.circular(6)),
        child: Text(char, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );
    }),
  );
}

/// 98. Permission Revoke Strikethrough Transition
class PermissionRevokeStrikeTransition extends StatelessWidget {
  final bool isRevoked;
  final Widget child;
  const PermissionRevokeStrikeTransition({super.key, required this.isRevoked, required this.child});

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.centerLeft,
    children: [
      AnimatedOpacity(opacity: isRevoked ? 0.4 : 1.0, duration: const Duration(milliseconds: 200), child: child),
      if (isRevoked)
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 250),
          builder: (_, w, _) => FractionallySizedBox(widthFactor: w, child: Container(height: 2, color: Colors.redAccent)),
        ),
    ],
  );
}

/// 99. Admin Approval Stamp Slam Transition
class AdminApprovalStampSlam extends StatelessWidget {
  final bool isApproved;
  final Widget child;
  const AdminApprovalStampSlam({super.key, required this.isApproved, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(begin: 2.5, end: isApproved ? 1.0 : 2.5),
    duration: const Duration(milliseconds: 350),
    curve: Curves.bounceOut,
    builder: (_, s, ch) => Transform.scale(
      scale: s,
      child: Transform.rotate(
        angle: isApproved ? -0.15 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 3), borderRadius: BorderRadius.circular(8)),
          child: ch,
        ),
      ),
    ),
    child: child,
  );
}

/// 100. App Logout Exit Shrink & Fade
class LogoutExitShrinkFadeTransition extends StatelessWidget {
  final bool isLoggingOut;
  final Widget child;
  const LogoutExitShrinkFadeTransition({super.key, required this.isLoggingOut, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: isLoggingOut ? 0.85 : 1.0),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeIn,
    builder: (_, s, ch) => Transform.scale(
      scale: s,
      child: AnimatedOpacity(opacity: isLoggingOut ? 0.0 : 1.0, duration: const Duration(milliseconds: 250), child: ch),
    ),
    child: child,
  );
}
