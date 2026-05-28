import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _obscurePass = true;
  bool _isRegister = false;
  final _nameCtl = TextEditingController();
  final _phoneCtl = TextEditingController();

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _nameCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.home_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'بنايتي',
                    style: GoogleFonts.notoNaskhArabic(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تطبيق إدارة الإيجارات',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (_isRegister)
                    TextFormField(
                      controller: _nameCtl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'الاسم بالكامل',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'الاسم مطلوب' : null,
                    ),
                  if (_isRegister) const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtl,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty ?? true ? 'البريد الإلكتروني مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    obscureText: _obscurePass,
                    validator: (v) => (v?.length ?? 0) < 6 ? '6 أحرف على الأقل' : null,
                  ),
                  if (_isRegister) const SizedBox(height: 16),
                  if (_isRegister)
                    TextFormField(
                      controller: _phoneCtl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: authState.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submit,
                            child: Text(_isRegister ? 'إنشاء حساب' : 'تسجيل الدخول'),
                          ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(
                      _isRegister ? 'لدي حساب بالفعل' : 'إنشاء حساب جديد',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                  if (authState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          authState.error.toString().replaceFirst('Exception: ', ''),
                          style: const TextStyle(color: AppTheme.errorColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegister) {
      ref.read(authProvider.notifier).register(
        _nameCtl.text, _emailCtl.text, _passCtl.text,
        phone: _phoneCtl.text,
      );
    } else {
      ref.read(authProvider.notifier).login(_emailCtl.text, _passCtl.text);
    }
  }
}
