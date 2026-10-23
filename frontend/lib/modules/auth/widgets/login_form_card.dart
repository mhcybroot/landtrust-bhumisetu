import 'package:flutter/material.dart';
import '../../../../core/animations/bouncing_pressable.dart';
import '../../../../core/animations/form_feedback_animations.dart';
import '../../marketplace/views/privacy_policy_view.dart';

class LoginFormCard extends StatefulWidget {
  final bool isMobile;
  final bool isLoading;
  final Future<void> Function(String phone, String password) onSubmit;

  const LoginFormCard({
    super.key,
    required this.isMobile,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_phoneCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অনুগ্রহ করে মোবাইল নম্বর ও পাসওয়ার্ড লিখুন।')),
      );
      return;
    }
    widget.onSubmit(_phoneCtrl.text.trim(), _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'লগইন করুন',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'মোবাইল নম্বর',
                prefixIcon: Icon(Icons.phone, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'পাসওয়ার্ড',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: PasswordEyeMorph(
                  isObscured: _obscurePass,
                  onToggle: () => setState(() => _obscurePass = !_obscurePass),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 18),
            BouncingPressable(
              onTap: widget.isLoading ? null : _handleLogin,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B4F32),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'লগইন করুন',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => PrivacyPolicyView.show(context),
                icon: const Icon(Icons.privacy_tip_outlined, size: 14, color: Colors.black54),
                label: const Text('গোপনীয়তা ও ডেটা নীতিমালা (Privacy Policy)', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

