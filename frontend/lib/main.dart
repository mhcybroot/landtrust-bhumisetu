import 'package:flutter/material.dart';
import 'package:landtrust_app/core/session/session_manager.dart';
import 'package:landtrust_app/core/theme/app_theme.dart';
import 'package:landtrust_app/modules/shell/views/main_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManager.instance.loadSession();
  runApp(const LandTrustApp());
}

class LandTrustApp extends StatelessWidget {
  const LandTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ভূমি সেতু (Bhumi Setu)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainShellScreen(),
    );
  }
}
