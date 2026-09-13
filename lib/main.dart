import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'calendar_view.dart';
import 'upload_memory_screen.dart';
import 'history_view.dart';
import 'login_screen.dart';
import 'profile_view.dart';
import 'splash_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  final ApiService api = ApiService();
  final AuthService auth = AuthService(api: api);
  await auth.init();
  runApp(LiquidGlassWidgets.wrap(child: AppRoot(auth: auth, api: api)));
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.auth, required this.api});

  final AuthService auth;
  final ApiService api;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onComplete: () {
            setState(() {
              _showSplash = false;
            });
          },
        ),
      );
    }

    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: widget.auth.isLoggedIn
          ? MyApp(
              auth: widget.auth,
              api: widget.api,
              onLogout: _handleLogout,
            )
          : LoginScreen(auth: widget.auth, onLoggedIn: _handleLoggedIn),
    );
  }

  void _handleLoggedIn() {
    setState(() {});
  }

  Future<void> _handleLogout() async {
    await widget.auth.logOut();
    if (mounted) setState(() {});
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.auth,
    required this.api,
    required this.onLogout,
  });

  final AuthService auth;
  final ApiService api;
  final VoidCallback onLogout;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  Map<String, String> dateImages = {};
  bool _isUploading = false;

  Timer? _heartbeatTimer;
  int _serverFailures = 0;
  bool _serverDownShown = false;

  String _getDateKey(DateTime date) {
    // Pad with zeros (e.g., 2025-01-12) for reliable sorting
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    _loadMemories();
    _startHeartbeat();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkServer(),
    );
  }

  Future<void> _checkServer() async {
    if (_serverDownShown) return;
    final reachable = await widget.api.ping();
    if (!mounted) return;
    if (reachable) {
      _serverFailures = 0;
      return;
    }
    _serverFailures += 1;
    if (_serverFailures >= 2 && !_serverDownShown) {
      _serverDownShown = true;
      _heartbeatTimer?.cancel();
      await _showServerDownDialog();
    }
  }

  Future<void> _showServerDownDialog() async {
    await showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('SERVER WAS SHUTDOWN'),
        content: const Text(
          'The server is currently offline. Tap OK to close the app.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () async {
              await widget.auth.logOut();
              if (mounted) Navigator.pop(context);
              exit(0);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadMemories() async {
    final userId = widget.auth.userId;
    if (userId == null) return;
    try {
      final memories = await widget.api.getMemories(userId);
      if (!mounted) return;
      setState(() {
        dateImages = {
          for (final memory in memories) memory.memoryDate: memory.imageUrl,
        };
      });
    } catch (e) {
      if (mounted) _showError('Could not load memories', e.toString());
    }
  }

  Future<void> _uploadMemory(String imagePath) async {
    final userId = widget.auth.userId;
    if (userId == null || _isUploading) return;
    setState(() => _isUploading = true);
    try {
      final memory = await widget.api.uploadMemory(
        userId,
        _getDateKey(selectedDate),
        File(imagePath),
      );
      if (!mounted) return;
      setState(() {
        dateImages[memory.memoryDate] = memory.imageUrl;
      });
    } catch (e) {
      if (mounted) _showError('Upload failed', e.toString());
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }


  Future<void> _deleteMemory(String dateKey) async {
    final userId = widget.auth.userId;
    if (userId == null) return;
    try {
      await widget.api.deleteMemory(userId, dateKey);
      if (!mounted) return;
      setState(() {
        dateImages.remove(dateKey);
      });
    } catch (e) {
      if (mounted) _showError('Delete failed', e.toString());
    }
  }

  void _showError(String title, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
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

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      CalendarByMonth(
        selectedDate: selectedDate,
        dateImages: dateImages,
        onDateChanged: (newDate) {
          setState(() {
            selectedDate = newDate;
          });
        },
      ),
      HistoryView(
        dateImages: dateImages,
        onDeleteImage: (dateKey) {
          _deleteMemory(dateKey);
        },
      ),
      ProfileView(
        auth: widget.auth,
        username: widget.auth.currentUsername,
        email: widget.auth.currentEmail,
        dateImages: dateImages,
        onLogout: widget.onLogout,
      ),
    ];

    return GlassScaffold(
      backgroundColor: const Color(0xFF000000),
      background: Stack(
        fit: StackFit.expand,
        children: const [
          // Top-Left Ambient Glow (Blue)
          Positioned(
            top: -100,
            left: -100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x26007AFF), // 0.15 alpha
              ),
              child: SizedBox(width: 400, height: 400),
            ),
          ),
          // Bottom-Right Ambient Glow (Teal)
          Positioned(
            bottom: -50,
            right: -50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A64FFDA), // 0.1 alpha
              ),
              child: SizedBox(width: 350, height: 350),
            ),
          ),
        ],
      ),
      bottomBar: GlassTabBar.bottom(
        settings: const LiquidGlassSettings(chromaticAberration: 1),
        bottomAccessory: selectedIndex == 0
            ? Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.only(bottom: 12, right: 48),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: GlassMenu(
                      menuWidth: 180,
                      settings: const LiquidGlassSettings(
                        chromaticAberration: 1,
                      ),
                      triggerBuilder: (context, toggle) => GlassButton(
                        settings: const LiquidGlassSettings(
                          chromaticAberration: 1,
                        ),
                        icon: const FaIcon(
                          FontAwesomeIcons.plus,
                          color: CupertinoColors.white,
                        ),
                        onTap: toggle,
                        width: 64,
                        height: 64,
                      ),
                      items: [
                        GlassMenuItem(
                          title: 'Photo',
                          icon: const Icon(
                            CupertinoIcons.camera,
                            color: CupertinoColors.white,
                          ),
                          onTap: () async {
                            final now = DateTime.now();
                            final today = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );
                            final selected = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                            );

                            if (selected.isAfter(today)) {
                              GlassDialog.show(
                                context: context,
                                quality: GlassQuality.premium,
                                settings: const LiquidGlassSettings(
                                  chromaticAberration: 1.5,
                                  blur: 50,
                                  thickness: 0.2,
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 10),
                                    // Gowing Lock Icon
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0x4D007AFF),
                                                blurRadius: 30,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          CupertinoIcons.lock_fill,
                                          size: 40,
                                          color: CupertinoColors.white,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'TIMELINE LOCKED',
                                      style: TextStyle(
                                        color: Color(0xB3FFFFFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Memories can only be captured in the present. Future dates are currently sealed.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0x99FFFFFF),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                                actions: [
                                  GlassDialogAction(
                                    label: 'UNDERSTOOD',
                                    isPrimary: true,
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              );
                              return;
                            }

                            final String? imagePath =
                                await Navigator.push<String>(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        const UploadMemoryScreen(),
                                  ),
                                );

                            if (imagePath != null) {
                              await _uploadMemory(imagePath);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        bottomAccessoryHeight: selectedIndex == 0 ? 80 : null,
        tabs: const [
          GlassTab(icon: FaIcon(FontAwesomeIcons.house)),
          GlassTab(icon: FaIcon(FontAwesomeIcons.clockRotateLeft)),
          GlassTab(icon: FaIcon(FontAwesomeIcons.user)),
        ],
        selectedIndex: selectedIndex,
        onTabSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      body: pages[selectedIndex],
    );
  }
}
