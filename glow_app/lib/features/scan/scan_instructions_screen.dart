import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_card.dart';

class ScanInstructionsScreen extends ConsumerStatefulWidget {
  const ScanInstructionsScreen({super.key});

  @override
  ConsumerState<ScanInstructionsScreen> createState() => _ScanInstructionsScreenState();
}

class _ScanInstructionsScreenState extends ConsumerState<ScanInstructionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _dontShowAgain = false;

  final List<_InstructionStep> _steps = const [
    _InstructionStep(
      number: '1',
      title: 'Face Natural Daylight',
      description: 'Find a well-lit room or face a window directly. Avoid harsh backlighting or dramatic side shadows.',
      icon: Icons.wb_sunny_outlined,
    ),
    _InstructionStep(
      number: '2',
      title: 'Clear Your Face',
      description: 'Remove heavy makeup, glasses, and tuck any loose hair away from your forehead and cheeks.',
      icon: Icons.face_retouching_off_outlined,
    ),
    _InstructionStep(
      number: '3',
      title: 'Hold at Eye Level',
      description: 'Keep your phone about an arm’s length away (around 30-40 cm) directly facing your gaze.',
      icon: Icons.stay_current_portrait_outlined,
    ),
    _InstructionStep(
      number: '4',
      title: 'Neutral Expression',
      description: 'Relax your forehead and jaw. Avoid smiling or squinting to allow accurate surface texture analysis.',
      icon: Icons.sentiment_satisfied_outlined,
    ),
    _InstructionStep(
      number: '5',
      title: 'Fit Inside the Oval',
      description: 'Align your face contours within the guide oval until the scanning ring illuminates green.',
      icon: Icons.center_focus_strong_outlined,
    ),
    _InstructionStep(
      number: '6',
      title: 'Hold Completely Still',
      description: 'Stay steady for 2 seconds while our on-device validator checks sharpness, lighting, and symmetry.',
      icon: Icons.hourglass_top_outlined,
    ),
  ];

  void _onReady() async {
    if (_dontShowAgain) {
      await LocalStorageService.setSkipScanInstructions(true);
    }
    if (mounted) {
      context.pushReplacement('/scan');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Scan Instructions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Page indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? palette.primaryDark : palette.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Swipeable Card Carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: GlowCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Step Number Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: palette.accentLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Tip ${step.number} of ${_steps.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: palette.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Large Icon Circle
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: palette.surfaceSecondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: palette.border, width: 1.5),
                              ),
                              child: Center(
                                child: Icon(step.icon, size: 52, color: palette.primaryDark),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title
                            Text(
                              step.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: palette.primaryDark,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(height: 14),

                            // Description
                            Text(
                              step.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: palette.secondaryText,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Don't show again checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _dontShowAgain,
                    activeColor: palette.primaryDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (val) => setState(() => _dontShowAgain = val ?? false),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _dontShowAgain = !_dontShowAgain),
                    child: Text(
                      "Don't show instructions next time",
                      style: TextStyle(fontSize: 13, color: palette.secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // "I'm ready" Button
              GlowPillButton(
                text: "I'm ready",
                onPressed: _onReady,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionStep {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _InstructionStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });
}
