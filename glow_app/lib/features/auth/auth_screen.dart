import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_segmented_tab.dart';
import '../../shared/widgets/glow_card.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  int _selectedTab = 0; // 0: Sign In, 1: Sign Up
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '24');

  bool _obscurePassword = true;
  bool _acceptedTerms = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;
    if (_selectedTab == 1 && !_acceptedTerms) {
      setState(() => _errorMessage = 'Please accept Terms & Privacy Policy to continue.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedTab == 0) {
        // Sign In
        await FirebaseService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        // Sign Up
        final age = int.tryParse(_ageController.text.trim()) ?? 24;
        await FirebaseService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          age: age,
        );
      }

      if (mounted) {
        context.go('/gender');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final palette = ref.read(currentPaletteProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.w600, color: palette.primaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive password reset instructions.',
              style: TextStyle(fontSize: 13, color: palette.secondaryText),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: resetEmailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: palette.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: palette.primaryDark),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset link sent to your email.')),
              );
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Top Branding Emblem
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: palette.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.spa_outlined, color: palette.accent, size: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Welcome to Glow',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: palette.primaryDark,
                          fontSize: 26,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _selectedTab == 0
                        ? 'Sign in to access your skin health profile'
                        : 'Create your account for personalized skin care',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: palette.secondaryText),
                  ),
                ),
                const SizedBox(height: 24),

                // Segmented Tab Toggle
                GlowSegmentedTabs(
                  tabs: const ['Sign In', 'Sign Up'],
                  selectedIndex: _selectedTab,
                  onTabSelected: (index) {
                    setState(() {
                      _selectedTab = index;
                      _errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Error Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 20, color: palette.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: palette.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Sign Up extra fields
                if (_selectedTab == 1) ...[
                  Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: palette.primaryText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Sarah Jenkins',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),

                  Text('Age', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: palette.primaryText)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 25',
                      prefixIcon: Icon(Icons.cake_outlined, size: 20),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 12 || n > 110) return 'Please enter a valid age (12-110)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: palette.primaryText)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.mail_outline, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || !v.contains('@') || !v.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: palette.primaryText)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: palette.secondaryText,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                if (_selectedTab == 0) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: palette.accent,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        activeColor: palette.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'I accept the Terms of Service & Privacy Policy',
                          style: TextStyle(fontSize: 12, color: palette.secondaryText),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

                // Primary Submit Button
                GlowPillButton(
                  text: _selectedTab == 0 ? 'Sign In' : 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),

                const SizedBox(height: 18),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: palette.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: TextStyle(color: palette.mutedText, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: palette.border)),
                  ],
                ),
                const SizedBox(height: 18),

                // Google Sign In Button
                GlowPillButton(
                  text: 'Continue with Google',
                  isSecondary: true,
                  showArrow: false,
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: () {
                    // Demo Google auth
                    context.go('/gender');
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
