import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/core/animations/transitions/admin_auth_transitions.dart';

void main() {
  testWidgets('RoleSwitchCrossfadeTransition renders active role', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RoleSwitchCrossfadeTransition(roleName: 'ADMIN', child: Text('Admin View')))));
    expect(find.text('Admin View'), findsOneWidget);
  });

  testWidgets('AdminDashboardCardStaggerSlide renders card', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AdminDashboardCardStaggerSlide(index: 1, child: Text('Metric Card')))));
    expect(find.text('Metric Card'), findsOneWidget);
  });

  testWidgets('UserStatusBadgeMorphTransition renders badge', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: UserStatusBadgeMorphTransition(status: 'ACTIVE'))));
    expect(find.byType(UserStatusBadgeMorphTransition), findsOneWidget);
  });

  testWidgets('AuditLogEntryExpandTransition renders audit entry', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AuditLogEntryExpandTransition(isExpanded: true, child: Text('Audit Entry')))));
    expect(find.text('Audit Entry'), findsOneWidget);
  });

  testWidgets('BiometricScanRippleTransition renders biometric scanner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BiometricScanRippleTransition(isScanning: true))));
    expect(find.byType(BiometricScanRippleTransition), findsOneWidget);
  });

  testWidgets('SessionTimeoutWarningSlide renders timeout banner', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SessionTimeoutWarningSlide(isExpiring: true, child: Text('Session Warning')))));
    expect(find.text('Session Warning'), findsOneWidget);
  });

  testWidgets('TwoFactorCodeCellSlide renders 2fa cells', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TwoFactorCodeCellSlide(code: '1234'))));
    expect(find.byType(TwoFactorCodeCellSlide), findsOneWidget);
  });

  testWidgets('PermissionRevokeStrikeTransition renders revoked label', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PermissionRevokeStrikeTransition(isRevoked: true, child: Text('Edit Deed')))));
    expect(find.text('Edit Deed'), findsOneWidget);
  });

  testWidgets('AdminApprovalStampSlam renders approval stamp', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AdminApprovalStampSlam(isApproved: true, child: Text('APPROVED')))));
    expect(find.text('APPROVED'), findsOneWidget);
  });

  testWidgets('LogoutExitShrinkFadeTransition renders exiting screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LogoutExitShrinkFadeTransition(isLoggingOut: true, child: Text('Goodbye')))));
    expect(find.text('Goodbye'), findsOneWidget);
  });
}
