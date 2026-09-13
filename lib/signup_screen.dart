import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await widget.auth.register(
      _username.text,
      _email.text,
      _password.text,
    );
    if (!mounted) return;
    if (!success) {
      setState(() {
        _loading = false;
        _error = "Registration failed";
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  Widget _field({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      placeholderStyle: const TextStyle(color: Color(0x80FFFFFF)),
      style: const TextStyle(color: CupertinoColors.white),
      keyboardType: keyboardType,
      autocorrect: false,
      obscureText: obscure,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(),
      onSubmitted: (_) => _createAccount(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: const Text('Create Account'),
        leading: GlassButton(
          settings: const LiquidGlassSettings(chromaticAberration: 0.5),
          icon: const Icon(CupertinoIcons.xmark),
          onTap: () => Navigator.of(context).pop(),
          width: 40,
          height: 40,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your account',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 28,
                fontWeight: FontWeight.w200,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Use your username, email, and a password of at least 6 characters.',
              style: TextStyle(
                color: Color(0xCCFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 32),
            AdaptiveGlass(
              shape: const LiquidRoundedSuperellipse(borderRadius: 20),
              settings: const LiquidGlassSettings(chromaticAberration: 0.5),
              child: Column(
                children: [
                  _field(controller: _username, placeholder: 'Username'),
                  Container(height: 0.5, color: const Color(0x1AFFFFFF)),
                  _field(
                    controller: _email,
                    placeholder: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  Container(height: 0.5, color: const Color(0x1AFFFFFF)),
                  CupertinoTextField(
                    controller: _password,
                    placeholder: 'Password',
                    placeholderStyle: const TextStyle(
                      color: Color(0x80FFFFFF),
                    ),
                    style: const TextStyle(color: CupertinoColors.white),
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(),
                    suffix: GestureDetector(
                      onTap: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          _obscurePassword
                              ? CupertinoIcons.eye
                              : CupertinoIcons.eye_slash,
                          color: const Color(0x80FFFFFF),
                          size: 20,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _createAccount(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 24),
            GlassButton.custom(
              onTap: _createAccount,
              width: double.infinity,
              height: 56,
              child: Text(
                _loading ? 'Creating account...' : 'Create Account',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}