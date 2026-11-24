import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/api_service.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/widgets/glow_button.dart';

class AnalysisLoadingScreen extends ConsumerStatefulWidget {
  final File? imageFile;

  const AnalysisLoadingScreen({super.key, this.imageFile});

  @override
  ConsumerState<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends ConsumerState<AnalysisLoadingScreen> {
  int _messageIndex = 0;
  Timer? _messageTimer;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isRetrying = false;

  final List<String> _statusMessages = const [
    'Evaluating skin barrier integrity...',
    'Checking hydration & transepidermal moisture...',
    'Measuring pore diameter and sebum distribution...',
    'Analyzing periorbital microcirculation & dark circles...',
    'Assessing fine lines & epidermal smoothness...',
    'Synthesizing clinical skin health profile...',
  ];

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
    _executeAnalysis();
  }

  void _startMessageCycle() {
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _statusMessages.length;
        });
      }
    });
  }

  Future<void> _executeAnalysis() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _isRetrying = false;
    });

    try {
      final file = widget.imageFile ?? File('simulated_face.jpg');
      final ScanResult result = await ApiService.analyzeSkin(imageFile: file);

      if (mounted) {
        _messageTimer?.cancel();
        // Route to Screen 8: Detected Skin Issues
        context.pushReplacement(
          '/results',
          extra: {
            'scanResult': result,
            'imageFile': widget.imageFile,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Analysis timed out or connection failed. Please check network and retry.';
        });
      }
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_hasError) ...[
                // Radiant pulsing circle animation
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: palette.accentLight.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SpinKitRing(
                      color: palette.primaryDark,
                      size: 110,
                      lineWidth: 3.5,
                    ),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: palette.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: palette.primaryDark.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.auto_awesome_rounded, color: palette.accent, size: 34),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Heading
                Text(
                  'Analyzing Your Skin',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: palette.primaryDark,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 14),

                // Animated changing text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusMessages[_messageIndex],
                    key: ValueKey<int>(_messageIndex),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: palette.secondaryText,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Subtle progress indicator bar
                Container(
                  width: 160,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      color: palette.primaryDark,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ] else ...[
                // Error & Retry State
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: palette.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.error_outline_rounded, color: palette.error, size: 40),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Analysis Interrupted',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: palette.primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: palette.secondaryText),
                ),
                const SizedBox(height: 28),
                GlowPillButton(
                  text: 'Retry Analysis',
                  isLoading: _isRetrying,
                  onPressed: () {
                    setState(() => _isRetrying = true);
                    _executeAnalysis();
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Cancel & Retake', style: TextStyle(color: palette.secondaryText)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
