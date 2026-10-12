import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'caretaker@carevoice.com');
  final _passwordController = TextEditingController(text: 'carevoice123');
  String? _error;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _isSubmitting = true;
    });
    try {
      await context.read<AuthProvider>().login(_emailController.text, _passwordController.text);
    } catch (err) {
      setState(() => _error = err.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: context.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(18)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.shield, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
                      children: const [
                        TextSpan(text: 'CareVoice '),
                        TextSpan(text: 'Edge', style: TextStyle(color: AppColors.indigo500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Offline Edge AI Patient Assistant • Caretaker Dashboard',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.rose500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.rose500.withValues(alpha: 0.2)),
                      ),
                      child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.rose500)),
                    ),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                    decoration: const InputDecoration(labelText: 'Caretaker Email', prefixIcon: Icon(Icons.mail_outline, size: 18)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline, size: 18)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: Text(_isSubmitting ? 'Authenticating...' : 'Sign In to Dashboard',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: context.borderColor),
                  const SizedBox(height: 10),
                  Text('Default local credentials pre-filled for instant testing',
                      style: TextStyle(fontSize: 10, color: context.textSecondaryColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
