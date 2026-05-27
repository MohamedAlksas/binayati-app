import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.home_rounded, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'بنايتي',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تطبيق إدارة الإيجارات',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  if (_isRegister)
                    TextFormField(
                      controller: _nameCtl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(labelText: 'الاسم بالكامل', prefixIcon: Icon(Icons.person)),
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                  if (_isRegister) const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtl,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtl,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    obscureText: _obscurePass,
                    validator: (v) => (v?.length ?? 0) < 6 ? 'At least 6 characters' : null,
                  ),
                  if (_isRegister) const SizedBox(height: 16),
                  if (_isRegister)
                    TextFormField(
                      controller: _phoneCtl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                    ),
                  const SizedBox(height: 24),
                  authState.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isRegister ? 'إنشاء حساب' : 'تسجيل الدخول'),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister ? 'لدي حساب بالفعل' : 'إنشاء حساب جديد'),
                  ),
                  if (authState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        authState.error.toString(),
                        style: const TextStyle(color: AppTheme.errorColor),
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
