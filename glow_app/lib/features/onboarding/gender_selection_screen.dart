import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/glow_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_card.dart';

class GenderSelectionScreen extends ConsumerStatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  ConsumerState<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends ConsumerState<GenderSelectionScreen> {
  String _selectedGender = 'female';
  bool _isSaving = false;

  void _selectGender(String gender) {
    setState(() => _selectedGender = gender);

    // Instant live theme switch
    if (gender == 'female') {
      ref.read(themeProvider.notifier).setTheme(GlowThemeMode.femalePink);
    } else {
      ref.read(themeProvider.notifier).setTheme(GlowThemeMode.maleBlue);
    }
  }

  Future<void> _handleContinue() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseService.updateUserGender(_selectedGender);
      await LocalStorageService.setHasOnboarded(true);
      if (mounted) {
        context.go('/home');
      }
    } catch (_) {
      if (mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Step indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Step 1 of 2',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                "Let's personalize\nyour Glow",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: palette.primaryDark,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 8),

              Text(
                'Select your profile to tune skincare guidelines, hydration targets, and visual ambience.',
                style: TextStyle(fontSize: 14, color: palette.secondaryText, height: 1.4),
              ),
              const SizedBox(height: 32),

              // Option 1: Female Card (Pink theme)
              _buildGenderCard(
                genderKey: 'female',
                title: 'Female',
                subtitle: 'Soft blush aesthetic • Hormonal cycle context & makeup barrier care',
                icon: Icons.face_3_outlined,
                cardThemeColor: GlowPalette.female.accent,
                cardBg: GlowPalette.female.surface,
              ),
              const SizedBox(height: 16),

              // Option 2: Male Card (Blue theme)
              _buildGenderCard(
                genderKey: 'male',
                title: 'Male',
                subtitle: 'Calm slate aesthetic • Shaving barrier support & sebum balance',
                icon: Icons.face_6_outlined,
                cardThemeColor: GlowPalette.male.accent,
                cardBg: GlowPalette.male.surface,
              ),
              const SizedBox(height: 16),

              // Option 3: Prefer not to say
              Center(
                child: TextButton(
                  onPressed: () => _selectGender('unspecified'),
                  child: Text(
                    'Prefer not to say (Neutral)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: palette.secondaryText,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Context notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.surfaceSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: palette.secondaryText),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You can switch your gender and theme anytime in Profile Settings.',
                        style: TextStyle(fontSize: 12, color: palette.secondaryText),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              GlowPillButton(
                text: 'Continue',
                isLoading: _isSaving,
                onPressed: _handleContinue,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required String genderKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardThemeColor,
    required Color cardBg,
  }) {
    final palette = ref.watch(currentPaletteProvider);
    final isSelected = _selectedGender == genderKey;

    return GestureDetector(
      onTap: () => _selectGender(genderKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? palette.primaryDark : palette.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: palette.primaryDark.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? palette.primaryDark : cardThemeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : cardThemeColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: palette.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.secondaryText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: palette.primaryDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.border, width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
