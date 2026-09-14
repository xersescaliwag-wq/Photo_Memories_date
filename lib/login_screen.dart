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

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _usernameController =
  TextEditingController();

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

    bool success;

    if (isLogin) {
      success = await widget.auth.logIn(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      success = await widget.auth.register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
    }

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      widget.onLoggedIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      // BLACK BACKGROUND
      backgroundColor: const Color(0xFF05050A),

      background: const Stack(
        fit: StackFit.expand,
        children: [
          // BLUE AMBIENT GLOW
          Positioned(
            top: -100,
            left: -100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33007AFF),
              ),
              child: SizedBox(
                width: 300,
                height: 300,
              ),
            ),
          ),

          // PINK AMBIENT GLOW
          Positioned(
            bottom: -50,
            right: -50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x33FF2D92),
              ),
              child: SizedBox(
                width: 250,
                height: 250,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 40.0,
          ),
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
                // APP LOGO
                Image.asset(
                  'assets/logo.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 40),

                // HERO TEXT
                const Text(
                  'PHOTO',
                  style: TextStyle(
                    color: Color(0x66FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12,
                  ),
                ),

                const Text(
                  'Memories',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -2,
                  ),
                ),

                const SizedBox(height: 60),

                // FULL NAME - REGISTER ONLY
                if (!isLogin) ...[
                  _buildGlassField(
                    controller: _usernameController,
                    placeholder: 'FULL NAME',
                    icon: CupertinoIcons.person,
                  ),
                  const SizedBox(height: 16),
                ],

                // USERNAME / EMAIL
                _buildGlassField(
                  controller: _emailController,
                  placeholder:
                  isLogin ? 'USERNAME' : 'EMAIL ADDRESS',
                  icon: isLogin
                      ? CupertinoIcons.person
                      : CupertinoIcons.mail,
                  keyboardType: isLogin
                      ? TextInputType.text
                      : TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // PASSWORD
                _buildGlassField(
                  controller: _passwordController,
                  placeholder: 'SECURE PASSWORD',
                  icon: CupertinoIcons.lock,
                  obscureText: _obscurePassword,
                  suffix: GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye_slash
                            : CupertinoIcons.eye,
                        size: 20,
                        color: const Color(0x66FFFFFF),
                      ),
                    ),
                  ),
                ),

                // ERROR MESSAGE
                if (widget.auth.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.auth.errorMessage!,
                    style: const TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // ENTER GALLERY / START COLLECTION
                GlassButton.custom(
                  key: ValueKey('auth_button_$isLogin'),
                  onTap: isLoading ? () {} : _handleAuth,
                  width: double.infinity,
                  height: 64,
                  quality: GlassQuality.premium,
                  shape: const LiquidRoundedSuperellipse(
                    borderRadius: 100,
                  ),
                  settings: const LiquidGlassSettings(
                    chromaticAberration: 1.0,
                    blur: 30,
                  ),
                  child: Center(
                    child: isLoading
                        ? const CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    )
                        : Text(
                      isLogin
                          ? 'ENTER GALLERY'
                          : 'START COLLECTION',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SWITCH LOGIN / REGISTER
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 24.0,
                    ),
                    child: Text(
                      isLogin
                          ? "NEW MEMBER?"
                          : "EXISTING MEMBER?",
                      style: const TextStyle(
                        color: Color(0x80FFFFFF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return AdaptiveGlass(
      quality: GlassQuality.premium,
      shape: const LiquidRoundedSuperellipse(
        borderRadius: 100,
      ),
      settings: const LiquidGlassSettings(
        chromaticAberration: 0.3,
        blur: 20,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 4,
        ),
        child: CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          placeholderStyle: const TextStyle(
            color: Color(0x33FFFFFF),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          prefix: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0x66FFFFFF),
            ),
          ),
          suffix: suffix,
          decoration: null,
          obscureText: obscureText,
          keyboardType: keyboardType,

          // PINK CURSOR
          cursorColor: const Color(0xFFFF4FA3),
        ),
      ),
    );
  }
}