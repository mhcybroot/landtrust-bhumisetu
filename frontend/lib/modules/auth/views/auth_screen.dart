import 'package:flutter/material.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/demo_accounts_bar.dart';
import '../widgets/login_form_card.dart';
import '../widgets/register_form_card.dart';

class AuthScreen extends StatefulWidget {
  final Map<String, dynamic> config;
  final bool isMobile;
  final VoidCallback onAuthSuccess;

  const AuthScreen({
    super.key,
    required this.config,
    required this.isMobile,
    required this.onAuthSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late final AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String phone, String pass) async {
    final success = await _viewModel.login(phone, pass);
    if (!mounted) return;
    if (success) {
      widget.onAuthSuccess();
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    }
  }

  Future<void> _handleRegister(Map<String, dynamic> payload) async {
    final success = await _viewModel.register(payload);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('নিবন্ধন সফল হয়েছে! স্বাগতম ভূমি সেতুতে।')),
      );
      widget.onAuthSuccess();
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = Uri.base.queryParameters['ref'] ?? '';
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(widget.isMobile ? 12 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ref.trim().isNotEmpty) _buildRefBanner(ref.trim()),
                  DemoAccountsBar(
                    isLoading: _viewModel.isLoading,
                    onDemoSelect: _handleLogin,
                  ),
                  const SizedBox(height: 16),
                  _buildToggleTabs(),
                  const SizedBox(height: 16),
                  if (_viewModel.isLogin)
                    LoginFormCard(
                      isMobile: widget.isMobile,
                      isLoading: _viewModel.isLoading,
                      onSubmit: _handleLogin,
                    )
                  else
                    RegisterFormCard(
                      config: widget.config,
                      isMobile: widget.isMobile,
                      isLoading: _viewModel.isLoading,
                      onSubmit: _handleRegister,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRefBanner(String code) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade700),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Color(0xFF0B4F32), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'রেফারেল কোড ($code) স্বয়ংক্রিয়ভাবে যুক্ত হয়েছে।',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0B4F32)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    final isLogin = _viewModel.isLogin;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: !isLogin ? const Color(0xFF0B4F32) : Colors.grey.shade200,
              foregroundColor: !isLogin ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _viewModel.setLoginMode(false),
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
            onPressed: () => _viewModel.setLoginMode(true),
            child: const Text('পুরাতন সদস্য লগইন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }
}
