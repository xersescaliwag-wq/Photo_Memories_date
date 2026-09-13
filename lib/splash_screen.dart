import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _revealAnimation;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );


    // 1. Initial burst and settle
    _revealAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutExpo),
    );

    // 2. Slow subtle growth
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.05).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.15).chain(CurveTween(curve: Curves.easeInOut)), weight: 60),
    ]).animate(_controller);

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo Reveal
                Transform.scale(
                  scale: _logoScale.value,
                  child: Opacity(
                    opacity: _revealAnimation.value.clamp(0, 1),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // SEQUENTIAL TEXT REVEAL
                Opacity(
                  opacity: CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8)).value,
                  child: Column(
                    children: [
                      const Text(
                        'PHOTO',
                        style: TextStyle(
                          color: Color(0x66FFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Memories',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w100,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
