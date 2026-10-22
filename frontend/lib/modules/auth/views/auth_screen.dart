import 'package:flutter/material.dart';
import '../view_models/auth_view_model.dart';
import 'mobile/auth_mobile_view.dart';
import 'web/auth_web_view.dart';

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
        const SnackBar(content: Text('নিবন্ধন সফল হয়েছে! স্বাগতম bdHousing-এ।')),
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
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (widget.isMobile) {
          return AuthMobileView(
            viewModel: _viewModel,
            config: widget.config,
            onLogin: _handleLogin,
            onRegister: _handleRegister,
          );
        }
        return AuthWebView(
          viewModel: _viewModel,
          config: widget.config,
          onLogin: _handleLogin,
          onRegister: _handleRegister,
        );
      },
    );
  }
}
