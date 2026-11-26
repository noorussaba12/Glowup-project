import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/glow_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_bottom_nav.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Sarah Jenkins');
  final _ageController = TextEditingController(text: '24');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseService.currentFirebaseUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _nameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _switchTheme(GlowThemeMode mode) async {
    ref.read(themeProvider.notifier).setTheme(mode);
    final gender = mode == GlowThemeMode.maleBlue ? 'male' : 'female';
    await FirebaseService.updateUserGender(gender);
  }

  void _showDeleteHistoryDialog() {
    final palette = ref.read(currentPaletteProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Scan History?', style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete all your stored face scans and reports from the device and cloud.',
          style: TextStyle(fontSize: 13, color: palette.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: palette.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: palette.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseService.deleteScanHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan history cleared.')),
                );
              }
            },
            child: const Text('Delete History'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final palette = ref.read(currentPaletteProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Account & All Data?', style: TextStyle(color: palette.error, fontWeight: FontWeight.w600)),
        content: Text(
          'This permanently erases your account, face photos, clinical skin scores, and routine plan. This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: palette.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: palette.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: palette.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseService.deleteAccountAndAllData();
              if (mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  void _handleSignOut() async {
    await FirebaseService.signOut();
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final currentThemeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Avatar & User Header matching Reference "Профиль"
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: palette.accentLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: palette.border, width: 2),
                          ),
                          child: Center(
                            child: Icon(Icons.person_rounded, size: 48, color: palette.accent),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: palette.primaryDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: palette.surface, width: 2),
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nameController.text,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 20,
                            color: palette.primaryDark,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since November 2026',
                      style: TextStyle(fontSize: 12, color: palette.secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Theme Switcher Card (Female Pink vs Male Blue)
              GlowCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Theme & Visual Ambience',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.primaryDark),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildThemeToggleOption(
                            title: 'Glow Pink (Female)',
                            color: GlowPalette.female.accent,
                            isSelected: currentThemeMode == GlowThemeMode.femalePink,
                            onTap: () => _switchTheme(GlowThemeMode.femalePink),
                            palette: palette,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildThemeToggleOption(
                            title: 'Glow Blue (Male)',
                            color: GlowPalette.male.accent,
                            isSelected: currentThemeMode == GlowThemeMode.maleBlue,
                            onTap: () => _switchTheme(GlowThemeMode.maleBlue),
                            palette: palette,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Account Details Card
              GlowCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Details',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.primaryDark),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions List matching reference tile items
              GlowCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Retake Skin Health Questionnaire',
                      onTap: () => context.push('/questionnaire'),
                      palette: palette,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.history_rounded,
                      title: 'Scan History & Reports',
                      onTap: () => context.push('/history'),
                      palette: palette,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Scan History',
                      titleColor: palette.warning,
                      onTap: _showDeleteHistoryDialog,
                      palette: palette,
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.person_remove_outlined,
                      title: 'Delete Account & All Data',
                      titleColor: palette.error,
                      onTap: _showDeleteAccountDialog,
                      palette: palette,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sign Out Button
              GlowPillButton(
                text: 'Sign Out',
                isSecondary: true,
                showArrow: false,
                icon: Icons.logout_rounded,
                onPressed: _handleSignOut,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlowBottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.push('/instructions');
          if (index == 2) context.push('/plan');
          if (index == 3) context.push('/nutriflow');
          if (index == 4) {}
        },
      ),
    );
  }

  Widget _buildThemeToggleOption({
    required String title,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required GlowPalette palette,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? palette.primaryDark : palette.chipBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? palette.primaryDark : palette.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : palette.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
    required GlowPalette palette,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? palette.accent, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: titleColor ?? palette.primaryText,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: palette.mutedText),
      onTap: onTap,
    );
  }
}
