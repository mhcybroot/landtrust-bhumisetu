import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:landtrust_app/modules/shell/widgets/shell_bottom_nav.dart';
import 'package:landtrust_app/modules/shell/widgets/shell_helpline_dialog.dart';

void main() {
  testWidgets('ShellBottomNav renders with bounce bubble jump', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        bottomNavigationBar: ShellBottomNav(
          selectedIndex: 0,
          isLoggedIn: false,
          isAdmin: false,
          onTabSelected: (_) {},
        ),
      ),
    ));
    expect(find.byType(ShellBottomNav), findsOneWidget);
  });

  testWidgets('ShellHelplineDialog shows with pulse beacon', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => ShellHelplineDialog.show(context, {}),
            child: const Text('Help'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Help'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('হেল্পলাইন ও সহায়তা'), findsOneWidget);
  });
}
