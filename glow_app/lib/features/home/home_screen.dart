import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_icon_circle.dart';
import '../../shared/widgets/glow_bottom_nav.dart';
import '../../shared/models/scan_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  List<ScanRecord> _recentScans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final scans = await FirebaseService.fetchScans();
    if (mounted) {
      setState(() {
        _recentScans = scans;
        _isLoading = false;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) return;
    if (index == 1) {
      _startScanFlow();
      return;
    }
    if (index == 2) {
      context.push('/plan');
      return;
    }
    if (index == 3) {
      context.push('/nutriflow');
      return;
    }
    if (index == 4) {
      context.push('/profile');
      return;
    }
  }

  void _startScanFlow() {
    final skipInstructions = LocalStorageService.skipScanInstructions;
    if (skipInstructions) {
      context.push('/scan');
    } else {
      context.push('/instructions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final user = FirebaseService.currentFirebaseUser;
    final userName = user?.displayName?.split(' ').first ?? 'Friend';

    final latestScan = _recentScans.isNotEmpty ? _recentScans.first : null;
    final latestScore = latestScan?.scanResult.overallScore ?? 84;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: palette.primaryDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar / Greeting Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.secondaryText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$userName ✨',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: palette.primaryDark,
                                fontSize: 24,
                              ),
                        ),
                      ],
                    ),
                    // Notification bell / Profile avatar
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: palette.accentLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.border, width: 1),
                        ),
                        child: Center(
                          child: Icon(Icons.person_outline_rounded, color: palette.accent, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reference-style Promotional Banner Card
                GlowCard(
                  padding: const EdgeInsets.all(22),
                  backgroundColor: palette.surfaceSecondary,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'AI Skin Health Check',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: palette.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Track your glow & balance your barrier',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: palette.primaryDark,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Small dark pill button matching reference "Толығырақ ->"
                            GestureDetector(
                              onTap: _startScanFlow,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: palette.primaryDark,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Scan Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Flower / Face icon container
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: palette.accentLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.face_retouching_natural_rounded, color: palette.accent, size: 38),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Big Action Button: "Scan your face"
                GlowPillButton(
                  text: 'Scan Your Face',
                  icon: Icons.camera_alt_outlined,
                  onPressed: _startScanFlow,
                ),
                const SizedBox(height: 24),

                // Category Circle Icons (Inspired directly by the Pinterest Reference grid)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GlowIconCircle(
                      icon: Icons.water_drop_outlined,
                      label: 'Hydration',
                      onTap: _startScanFlow,
                    ),
                    GlowIconCircle(
                      icon: Icons.grain_outlined,
                      label: 'Pores',
                      onTap: _startScanFlow,
                    ),
                    GlowIconCircle(
                      icon: Icons.visibility_outlined,
                      label: 'Dark Circles',
                      onTap: _startScanFlow,
                    ),
                    GlowIconCircle(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Sun Care',
                      onTap: _startScanFlow,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Metric Cards Grid
                Row(
                  children: [
                    // Skin Score Card with circular progress
                    Expanded(
                      child: GlowCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Skin Score',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: palette.secondaryText,
                                  ),
                                ),
                                Icon(Icons.analytics_outlined, size: 18, color: palette.accent),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: CircularPercentIndicator(
                                radius: 42.0,
                                lineWidth: 7.0,
                                percent: latestScore / 100.0,
                                center: Text(
                                  '$latestScore',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: palette.primaryDark,
                                  ),
                                ),
                                progressColor: palette.primaryDark,
                                backgroundColor: palette.scoreRingTrack,
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                latestScan != null ? 'Last scan: Today' : 'Initial estimate',
                                style: TextStyle(fontSize: 11, color: palette.mutedText),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // "Your Plan" Quick Shortcut
                    Expanded(
                      child: GlowCard(
                        padding: const EdgeInsets.all(18),
                        onTap: () => context.push('/plan'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Your Plan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: palette.secondaryText,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: palette.mutedText),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: palette.accentLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.spa_rounded, color: palette.accent, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '4-Week Regimen',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: palette.primaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: palette.border,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: 0.65,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: palette.accent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Week 1 of 4 • 65%',
                              style: TextStyle(fontSize: 11, color: palette.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Tip of the Day Card
                GlowCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: palette.accentLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lightbulb_outline_rounded, color: palette.accent, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tip of the Day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: palette.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Double cleanse tonight: remove mineral sunscreen and pollutants with an oil balm before using your gentle foaming cleanser.',
                              style: TextStyle(fontSize: 12, color: palette.secondaryText, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GlowBottomNavBar(
        currentIndex: _navIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
