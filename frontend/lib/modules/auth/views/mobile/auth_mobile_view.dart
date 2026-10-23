import 'package:flutter/material.dart';
import '../../../../core/animations/animated_fade_switcher.dart';
import '../../../../core/localization/app_strings.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/demo_accounts_bar.dart';
import '../../widgets/login_form_card.dart';
import '../../widgets/register_form_card.dart';

class AuthMobileView extends StatelessWidget {
  final AuthViewModel viewModel;
  final Map<String, dynamic> config;
  final Future<void> Function(String, String) onLogin;
  final Future<void> Function(Map<String, dynamic>) onRegister;

  const AuthMobileView({
    super.key,
    required this.viewModel,
    required this.config,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final isLogin = viewModel.isLogin;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => viewModel.setLoginMode(true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isLogin ? const Color(0xFF0B4F32) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.tr('login_title'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isLogin ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => viewModel.setLoginMode(false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !isLogin ? const Color(0xFF0B4F32) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.tr('register_title'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: !isLogin ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isLogin) ...[
          const SizedBox(height: 12),
          DemoAccountsBar(
            isLoading: viewModel.isLoading,
            onDemoSelect: onLogin,
          ),
        ],
        const SizedBox(height: 14),
        AnimatedFadeSwitcher(
          child: KeyedSubtree(
            key: ValueKey(isLogin),
            child: isLogin
                ? LoginFormCard(
                    isMobile: true,
                    isLoading: viewModel.isLoading,
                    onSubmit: onLogin,
                  )
                : RegisterFormCard(
                    config: config,
                    isMobile: true,
                    isLoading: viewModel.isLoading,
                    onSubmit: onRegister,
                  ),
          ),
        ),
      ],
    );
  }
}

