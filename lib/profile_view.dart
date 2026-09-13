import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'services/auth_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.auth,
    required this.username,
    required this.email,
    required this.dateImages,
    required this.onLogout,
  });

  final AuthService auth;
  final String? username;
  final String? email;
  final Map<String, String> dateImages;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final initial = username == null || username!.isEmpty
        ? '?'
        : username![0].toUpperCase();
    final displayName = (username ?? 'COLLECTOR').toUpperCase();

    return SizedBox.expand(
      child: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 80,
              24,
              120,
            ),
            child: Column(
              children: [
                // Avatar Module
                GlassButton.custom(
                  onTap: () {},
                  width: 120,
                  height: 120,
                  quality: GlassQuality.premium,
                  shape: const LiquidOval(),
                  settings: const LiquidGlassSettings(
                    chromaticAberration: 1.4,
                    blur: 40,
                    thickness: 0.3,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Identity Slab
                AdaptiveGlass(
                  quality: GlassQuality.premium,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 32),
                  settings: const LiquidGlassSettings(
                    chromaticAberration: 1.0,
                    blur: 50,
                    thickness: 0.15,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (email ?? 'ACCESS.DENIED@MEMORY.LAB').toLowerCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0x99FFFFFF),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(height: 0.5, width: 40, color: const Color(0x33FFFFFF)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard('POST', '${dateImages.length}'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard('SECURITY', 'PRO'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                const Text(
                  'PHOTO MEMORIES • CAPTURE THE PRESENT',
                  style: TextStyle(
                    color: Color(0x26FFFFFF),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          
          // 3-dots Menu Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GlassPopover(
              popoverWidth: 200,
              settings: const LiquidGlassSettings(chromaticAberration: 0.5, blur: 30),
              triggerBuilder: (context, toggle) => GlassButton(
                onTap: toggle,
                width: 44,
                height: 44,
                icon: const Icon(CupertinoIcons.ellipsis_vertical, color: CupertinoColors.white),
                settings: const LiquidGlassSettings(chromaticAberration: 0.5),
              ),
              contentBuilder: (context, close) => _DropdownContent(
                auth: auth,
                onLogout: () {
                  close();
                  onLogout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return AdaptiveGlass(
      quality: GlassQuality.premium,
      shape: const LiquidRoundedSuperellipse(borderRadius: 24),
      settings: const LiquidGlassSettings(chromaticAberration: 0.4, blur: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0x66FFFFFF),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownContent extends StatefulWidget {
  const _DropdownContent({required this.auth, required this.onLogout});
  final AuthService auth;
  final VoidCallback onLogout;

  @override
  State<_DropdownContent> createState() => _DropdownContentState();
}

class _DropdownContentState extends State<_DropdownContent> {
  bool isChangingPassword = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  final TextEditingController _oldPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();

  @override
  void dispose() {
    _oldPass.dispose();
    _newPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isChangingPassword) ...[
            const Text(
              'OPTIONS',
              style: TextStyle(
                color: Color(0x66FFFFFF),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            GlassMenuItem(
              title: 'PASSWORD',
              icon: const Icon(CupertinoIcons.lock_fill, size: 16, color: CupertinoColors.activeBlue),
              onTap: () => setState(() => isChangingPassword = true),
            ),
            const SizedBox(height: 8),
            GlassMenuItem(
              title: 'LOGOUT',
              icon: const Icon(CupertinoIcons.power, size: 16, color: CupertinoColors.systemRed),
              onTap: widget.onLogout,
            ),
            const GlassMenuDivider(),
            GlassMenuItem(
              title: 'DELETE ACCOUNT',
              titleStyle: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
              icon: const Icon(CupertinoIcons.delete, size: 18, color: CupertinoColors.systemRed),
              onTap: () {
                GlassDialog.show(
                  context: context,
                  title: 'Delete Account',
                  message: 'This action is irreversible. All your memories will be permanently deleted. Continue?',
                  actions: [
                    GlassDialogAction(
                      label: 'CANCEL',
                      onPressed: () => Navigator.pop(context),
                    ),
                    GlassDialogAction(
                      label: 'DELETE',
                      isDestructive: true,
                      onPressed: () async {
                        final bool success = await widget.auth.deleteAccount();
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (!success) {
                          final message = widget.auth.errorMessage ?? 'Could not delete account';
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Delete Account Failed'),
                              content: Text(message),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            const Text(
              'UPDATE SECURITY',
              style: TextStyle(color: Color(0x66FFFFFF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            _buildField(
              _oldPass,
              'Current Password',
              _obscureOld,
              () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 8),
            _buildField(
              _newPass,
              'New Password',
              _obscureNew,
              () => setState(() => _obscureNew = !_obscureNew),
            ),
            if (widget.auth.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(widget.auth.errorMessage!, style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 10)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassButton.custom(
                    onTap: () => setState(() => isChangingPassword = false),
                    height: 36,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                    child: const Center(child: Text('BACK', style: TextStyle(color: Color(0x80FFFFFF), fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassButton.custom(
                    onTap: () async {
                      bool success = await widget.auth.changePassword(_oldPass.text, _newPass.text);
                      if (success) {
                        setState(() => isChangingPassword = false);
                      } else {
                        setState(() {});
                      }
                    },
                    height: 36,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                    settings: const LiquidGlassSettings(chromaticAberration: 1.0),
                    child: const Center(child: Text('SAVE', style: TextStyle(color: CupertinoColors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, bool obscure, VoidCallback onToggle) {
    return AdaptiveGlass(
      shape: const LiquidRoundedSuperellipse(borderRadius: 12),
      settings: const LiquidGlassSettings(chromaticAberration: 0.3, blur: 20, thickness: 0.2),
      child: CupertinoTextField(
        controller: controller,
        placeholder: hint,
        placeholderStyle: const TextStyle(color: Color(0x33FFFFFF), fontSize: 12),
        style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
        obscureText: obscure,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: null,
        suffix: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
              size: 16,
              color: const Color(0x66FFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}
