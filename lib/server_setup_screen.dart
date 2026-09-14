import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'config.dart';
import 'services/api_service.dart';

class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({
    super.key,
    required this.api,
    required this.onConnected,
  });

  final ApiService api;
  final VoidCallback onConnected;

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  final TextEditingController _ipController =
      TextEditingController(text: '192.168.100.120');

  bool _isConnecting = false;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  bool _isValidIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) {
        return false;
      }
    }

    return true;
  }

  Future<void> _connectToServer() async {
    final ip = _ipController.text.trim();

    if (!_isValidIp(ip)) {
      _showError(
        'Invalid IP Address',
        'Please enter a valid IPv4 address such as 192.168.1.10.',
      );
      return;
    }

    setState(() => _isConnecting = true);

    ApiConfig.setServerIp(ip);

    final connected = await widget.api.ping();

    if (!mounted) return;

    setState(() => _isConnecting = false);

    if (connected) {
      widget.onConnected();
    } else {
      ApiConfig.clearCustomServer();

      _showError(
        'Connection Failed',
        'Could not connect to the server at $ip.\n\n'
            'Make sure the PHP server is running and your phone is connected '
            'to the same network.',
      );
    }
  }

  void _showError(String title, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      backgroundColor: const Color(0xFF000000),
      background: Stack(
        fit: StackFit.expand,
        children: const [
          Positioned(
            top: -100,
            left: -100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x26007AFF),
              ),
              child: SizedBox(
                width: 400,
                height: 400,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A64FFDA),
              ),
              child: SizedBox(
                width: 350,
                height: 350,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AdaptiveGlass(
              shape: const LiquidRoundedSuperellipse(borderRadius: 40),
              settings: const LiquidGlassSettings(
                chromaticAberration: 1,
                blur: 25,
                thickness: 0.2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.cloud,
                      size: 64,
                      color: CupertinoColors.white,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SERVER CONNECTION',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter the IP address of the PHP server to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xB3FFFFFF),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    CupertinoTextField(
                      controller: _ipController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      placeholder: '192.168.1.10',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                      ),
                      placeholderStyle: const TextStyle(
                        color: Color(0x66FFFFFF),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0x33FFFFFF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GlassButton.custom(
                      onTap: () {
                        if (!_isConnecting) {
                          _connectToServer();
                        }
                      },
                      shape: const LiquidRoundedSuperellipse(borderRadius: 14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        child: _isConnecting
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              )
                            : const Text(
                                'CONNECT TO SERVER',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
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
    );
  }
}
