import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.auth,
    required this.onLoggedIn,
  });

  final AuthService auth;
  final VoidCallback onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    if (isLogin) {
      final success = await widget.auth.logIn(
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      setState(() => isLoading = false);
      if (success) {
        widget.onLoggedIn();
      }
    } else {
      // Registration request
      final success = await widget.auth.requestRegistrationCode(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (!mounted) return;
      setState(() => isLoading = false);
      if (success) {
        _showRegisterVerifyDialog();
      }
    }
  }

  // --- REGISTRATION OTP FLOW ---

  void _showRegisterVerifyDialog() {
    final TextEditingController codeController = TextEditingController();
    final String email = _emailController.text.trim();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    showCupertinoDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: AdaptiveGlass(
              quality: GlassQuality.premium,
              shape: const LiquidRoundedSuperellipse(borderRadius: 32),
              settings: const LiquidGlassSettings(
                chromaticAberration: 1.5,
                blur: 50,
                thickness: 0.2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'VERIFY EMAIL',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A 6-digit code was sent to $email. Enter it below to complete your registration.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AdaptiveGlass(
                      quality: GlassQuality.premium,
                      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
                      settings: const LiquidGlassSettings(
                        chromaticAberration: 0.3,
                        blur: 20,
                      ),
                      child: CupertinoTextField(
                        controller: codeController,
                        placeholder: '000000',
                        textAlign: TextAlign.center,
                        placeholderStyle: const TextStyle(
                          color: Color(0x33FFFFFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: null,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        cursorColor: const Color(0xFFFF4FA3),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton.custom(
                            onTap: () => Navigator.pop(context),
                            height: 48,
                            shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                            child: const Center(
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Color(0x80FFFFFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassButton.custom(
                            onTap: () async {
                              final code = codeController.text.trim();
                              if (code.length != 6) return;

                              Navigator.pop(context); // Close code dialog
                              setState(() => isLoading = true);
                              
                              final success = await widget.auth.verifyRegistrationAndCreate(
                                username, email, password, code
                              );

                              if (!mounted) return;
                              setState(() => isLoading = false);
                              
                              if (success) {
                                widget.onLoggedIn();
                              } else {
                                _showErrorDialog(widget.auth.errorMessage ?? 'Verification failed');
                              }
                            },
                            height: 48,
                            shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                            settings: const LiquidGlassSettings(chromaticAberration: 0.8),
                            child: const Center(
                              child: Text(
                                'VERIFY',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- FORGOT PASSWORD FLOW ---

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: AdaptiveGlass(
              quality: GlassQuality.premium,
              shape: const LiquidRoundedSuperellipse(borderRadius: 32),
              settings: const LiquidGlassSettings(
                chromaticAberration: 1.5,
                blur: 50,
                thickness: 0.2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'RESET PASSWORD',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter your email to receive a 6-digit verification code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AdaptiveGlass(
                      quality: GlassQuality.premium,
                      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
                      settings: const LiquidGlassSettings(
                        chromaticAberration: 0.3,
                        blur: 20,
                      ),
                      child: CupertinoTextField(
                        controller: resetEmailController,
                        placeholder: 'EMAIL ADDRESS',
                        placeholderStyle: const TextStyle(
                          color: Color(0x33FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                        style: const TextStyle(color: CupertinoColors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: null,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: const Color(0xFFFF4FA3),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton.custom(
                            onTap: () => Navigator.pop(context),
                            height: 48,
                            shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                            child: const Center(
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Color(0x80FFFFFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassButton.custom(
                            onTap: () async {
                              final email = resetEmailController.text.trim();
                              if (email.isEmpty) return;

                              Navigator.pop(context); // Close email dialog
                              final success = await widget.auth.requestResetCode(email);

                              if (!mounted) return;
                              if (success) {
                                _showVerifyCodeDialog(email);
                              } else {
                                _showErrorDialog(widget.auth.errorMessage ?? 'Request failed');
                              }
                            },
                            height: 48,
                            shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                            settings: const LiquidGlassSettings(chromaticAberration: 0.8),
                            child: const Center(
                              child: Text(
                                'SEND CODE',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showVerifyCodeDialog(String email) {
    final TextEditingController codeController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: AdaptiveGlass(
              quality: GlassQuality.premium,
              shape: const LiquidRoundedSuperellipse(borderRadius: 32),
              settings: const LiquidGlassSettings(
                chromaticAberration: 1.5,
                blur: 50,
                thickness: 0.2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'VERIFY CODE',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the 6-digit code sent to $email',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0x99FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AdaptiveGlass(
                      quality: GlassQuality.premium,
                      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
                      settings: const LiquidGlassSettings(
                        chromaticAberration: 0.3,
                        blur: 20,
                      ),
                      child: CupertinoTextField(
                        controller: codeController,
                        placeholder: '000000',
                        textAlign: TextAlign.center,
                        placeholderStyle: const TextStyle(
                          color: Color(0x33FFFFFF),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: null,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        cursorColor: const Color(0xFFFF4FA3),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton.custom(
                            onTap: () => Navigator.pop(context),
                            height: 48,
                            shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                            child: const Center(
                              child: Text(
                                'BACK',
                                style: TextStyle(
                                  color: Color(0x80FFFFFF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassButton.custom(
                            onTap: () async {
                              final code = codeController.text.trim();
                              if (code.length != 6) return;

                              Navigator.pop(context); // Close code dialog
                              final success = await widget.auth.verifyCode(email, code);

                              if (!mounted) return;
                              if (success) {
                                _showNewPasswordDialog(email, code);
                              } else {
                                _showErrorDialog(widget.auth.errorMessage ?? 'Invalid code');
                              }
                            },
                            height: 48,
                            shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                            settings: const LiquidGlassSettings(chromaticAberration: 0.8),
                            child: const Center(
                              child: Text(
                                'VERIFY',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNewPasswordDialog(String email, String code) {
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    bool isUpdating = false;
    bool obscurePass = true;
    bool obscureConfirm = true;
    String? localError;

    showCupertinoDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 300,
              child: AdaptiveGlass(
                quality: GlassQuality.premium,
                shape: const LiquidRoundedSuperellipse(borderRadius: 32),
                settings: const LiquidGlassSettings(
                  chromaticAberration: 1.5,
                  blur: 50,
                  thickness: 0.2,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'NEW PASSWORD',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Secure your account with a new strong password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0x99FFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          height: 1.5,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AdaptiveGlass(
                        quality: GlassQuality.premium,
                        shape: const LiquidRoundedSuperellipse(borderRadius: 12),
                        settings: const LiquidGlassSettings(
                          chromaticAberration: 0.3,
                          blur: 20,
                        ),
                        child: CupertinoTextField(
                          controller: passController,
                          placeholder: 'NEW PASSWORD',
                          obscureText: obscurePass,
                          placeholderStyle: const TextStyle(
                            color: Color(0x33FFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                          style: const TextStyle(color: CupertinoColors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: null,
                          suffix: GestureDetector(
                            onTap: () => setDialogState(() => obscurePass = !obscurePass),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                obscurePass ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                                size: 18,
                                color: const Color(0x66FFFFFF),
                              ),
                            ),
                          ),
                          cursorColor: const Color(0xFFFF4FA3),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AdaptiveGlass(
                        quality: GlassQuality.premium,
                        shape: const LiquidRoundedSuperellipse(borderRadius: 12),
                        settings: const LiquidGlassSettings(
                          chromaticAberration: 0.3,
                          blur: 20,
                        ),
                        child: CupertinoTextField(
                          controller: confirmController,
                          placeholder: 'CONFIRM PASSWORD',
                          obscureText: obscureConfirm,
                          placeholderStyle: const TextStyle(
                            color: Color(0x33FFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                          style: const TextStyle(color: CupertinoColors.white),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: null,
                          suffix: GestureDetector(
                            onTap: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                obscureConfirm ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                                size: 18,
                                color: const Color(0x66FFFFFF),
                              ),
                            ),
                          ),
                          cursorColor: const Color(0xFFFF4FA3),
                        ),
                      ),
                      if (localError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          localError!,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      GlassButton.custom(
                        onTap: isUpdating
                            ? () {}
                            : () async {
                                final pass = passController.text.trim();
                                final confirm = confirmController.text.trim();

                                if (pass.length < 6) {
                                  setDialogState(() => localError = 'Password too short');
                                  return;
                                }
                                if (pass != confirm) {
                                  setDialogState(() => localError = 'Passwords do not match');
                                  return;
                                }

                                setDialogState(() {
                                  isUpdating = true;
                                  localError = null;
                                });

                                final success = await widget.auth.updatePasswordWithCode(email, code, pass);

                                if (!mounted) return;
                                setDialogState(() => isUpdating = false);

                                if (success) {
                                  Navigator.pop(context); // Close password dialog
                                  _showSuccessDialog('Password updated! You can now log in.');
                                } else {
                                  setDialogState(() => localError = widget.auth.errorMessage ?? 'Update failed');
                                }
                              },
                        width: double.infinity,
                        height: 48,
                        shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                        settings: const LiquidGlassSettings(chromaticAberration: 0.8),
                        child: Center(
                          child: isUpdating
                              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                              : const Text(
                                  'UPDATE PASSWORD',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => Center(
        child: SizedBox(
          width: 300,
          child: AdaptiveGlass(
            quality: GlassQuality.premium,
            shape: const LiquidRoundedSuperellipse(borderRadius: 32),
            settings: const LiquidGlassSettings(blur: 40),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.checkmark_circle, size: 48, color: CupertinoColors.activeBlue),
                  const SizedBox(height: 16),
                  const Text(
                    'SUCCESS',
                    style: TextStyle(color: CupertinoColors.white, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 14, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 24),
                  GlassButton.custom(
                    onTap: () => Navigator.pop(context),
                    width: double.infinity,
                    height: 44,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                    child: const Center(child: Text('OK', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => Center(
        child: SizedBox(
          width: 300,
          child: AdaptiveGlass(
            quality: GlassQuality.premium,
            shape: const LiquidRoundedSuperellipse(borderRadius: 32),
            settings: const LiquidGlassSettings(blur: 40),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.exclamationmark_circle, size: 48, color: CupertinoColors.systemRed),
                  const SizedBox(height: 16),
                  const Text(
                    'ERROR',
                    style: TextStyle(color: CupertinoColors.white, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 14, decoration: TextDecoration.none),
                  ),
                  const SizedBox(height: 24),
                  GlassButton.custom(
                    onTap: () => Navigator.pop(context),
                    width: double.infinity,
                    height: 44,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                    child: const Center(child: Text('OK', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.none))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      backgroundColor: const Color(0xFF05050A),
      background: const Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33007AFF),
              ),
              child: SizedBox(width: 300, height: 300),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33FF2D92),
              ),
              child: SizedBox(width: 250, height: 250),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  80,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 140, height: 140, fit: BoxFit.contain),
                const SizedBox(height: 40),
                const Text('PHOTO', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 12)),
                const Text('Memories', style: TextStyle(color: CupertinoColors.white, fontSize: 48, fontWeight: FontWeight.w200, letterSpacing: -2)),
                const SizedBox(height: 60),
                if (!isLogin) ...[
                  _buildGlassField(controller: _usernameController, placeholder: 'FULL NAME', icon: CupertinoIcons.person),
                  const SizedBox(height: 16),
                ],
                _buildGlassField(
                  controller: _emailController,
                  placeholder: isLogin ? 'USERNAME' : 'EMAIL ADDRESS',
                  icon: isLogin ? CupertinoIcons.person : CupertinoIcons.mail,
                  keyboardType: isLogin ? TextInputType.text : TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildGlassField(
                  controller: _passwordController,
                  placeholder: 'SECURE PASSWORD',
                  icon: CupertinoIcons.lock,
                  obscureText: _obscurePassword,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(_obscurePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye, size: 20, color: const Color(0x66FFFFFF)),
                    ),
                  ),
                ),
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: _showForgotPasswordDialog,
                      child: const Text('FORGOT PASSWORD?', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ),
                if (widget.auth.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(widget.auth.errorMessage!, style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 48),
                GlassButton.custom(
                  key: ValueKey('auth_button_$isLogin'),
                  onTap: isLoading ? () {} : _handleAuth,
                  width: double.infinity,
                  height: 64,
                  quality: GlassQuality.premium,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                  settings: const LiquidGlassSettings(chromaticAberration: 1.0, blur: 30),
                  child: Center(
                    child: isLoading
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Text(isLogin ? 'ENTER GALLERY' : 'START COLLECTION', style: const TextStyle(color: CupertinoColors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 4)),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => setState(() => isLogin = !isLogin),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Text(isLogin ? "NEW MEMBER?" : "EXISTING MEMBER?", style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassField({required TextEditingController controller, required String placeholder, required IconData icon, bool obscureText = false, TextInputType? keyboardType, Widget? suffix}) {
    return AdaptiveGlass(
      quality: GlassQuality.premium,
      shape: const LiquidRoundedSuperellipse(borderRadius: 100),
      settings: const LiquidGlassSettings(chromaticAberration: 0.3, blur: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          placeholderStyle: const TextStyle(color: Color(0x33FFFFFF), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 2),
          style: const TextStyle(color: CupertinoColors.white, fontSize: 15, fontWeight: FontWeight.w400),
          padding: const EdgeInsets.symmetric(vertical: 14),
          prefix: Padding(padding: const EdgeInsets.only(right: 12), child: Icon(icon, size: 16, color: const Color(0x66FFFFFF))),
          suffix: suffix,
          decoration: null,
          obscureText: obscureText,
          keyboardType: keyboardType,
          cursorColor: const Color(0xFFFF4FA3),
        ),
      ),
    );
  }
}
