import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/glow_button.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateNext() {
    final hasOnboarded = LocalStorageService.hasOnboarded;
    if (hasOnboarded) {
      context.go('/home');
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                // Center Emblem & Title matching reference Screen 1
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botanical Glow Emblem
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: palette.accentLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.border, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: palette.accent.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.spa_outlined,
                          size: 44,
                          color: palette.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Title in Serif Font
                    Text(
                      'Glow',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                            color: palette.primaryDark,
                          ),
                    ),
                    const SizedBox(height: 10),

                    // Subtitle / Tagline
                    Text(
                      'Your skin health journey starts here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: palette.secondaryText,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                // Bottom Action & Pagination Dots matching reference
                Column(
                  children: [
                    GlowPillButton(
                      text: 'Get Started',
                      onPressed: _navigateNext,
                    ),
                    const SizedBox(height: 22),

                    // Three indicator dots matching reference
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: palette.primaryDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: palette.mutedText.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: palette.mutedText.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
