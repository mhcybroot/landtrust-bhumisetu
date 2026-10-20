import 'package:flutter/material.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/demo_accounts_bar.dart';
import '../../widgets/login_form_card.dart';
import '../../widgets/register_form_card.dart';

class AuthWebView extends StatelessWidget {
  final AuthViewModel viewModel;
  final Map<String, dynamic> config;
  final Future<void> Function(String, String) onLogin;
  final Future<void> Function(Map<String, dynamic>) onRegister;

  const AuthWebView({
    super.key,
    required this.viewModel,
    required this.config,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final ref = Uri.base.queryParameters['ref'] ?? '';
    final isLogin = viewModel.isLogin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ref.trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Text('রেফারেল কোড ($ref) যুক্ত হয়েছে।', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0B4F32))),
                ),
              DemoAccountsBar(
                isLoading: viewModel.isLoading,
                onDemoSelect: onLogin,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isLogin ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                        foregroundColor: !isLogin ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => viewModel.setLoginMode(false),
                      child: const Text('নতুন সদস্য নিবন্ধন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLogin ? const Color(0xFF0B4F32) : Colors.grey.shade200,
                        foregroundColor: isLogin ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => viewModel.setLoginMode(true),
                      child: const Text('পুরাতন সদস্য লগইন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLogin)
                LoginFormCard(
                  isMobile: false,
                  isLoading: viewModel.isLoading,
                  onSubmit: onLogin,
                )
              else
                RegisterFormCard(
                  config: config,
                  isMobile: false,
                  isLoading: viewModel.isLoading,
                  onSubmit: onRegister,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
