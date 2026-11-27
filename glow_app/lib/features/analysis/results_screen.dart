import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/glow_button.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  final ScanResult? scanResult;
  final File? imageFile;

  const ResultsScreen({super.key, this.scanResult, this.imageFile});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  String _selectedZoneFilter = 'all';

  Color _getSeverityColor(String severity, GlowPalette palette) {
    switch (severity.toLowerCase()) {
      case 'none':
        return palette.success;
      case 'mild':
        return const Color(0xFF8DB89A);
      case 'moderate':
        return palette.warning;
      case 'severe':
        return palette.error;
      default:
        return palette.secondaryText;
    }
  }

  double _getSeverityProgress(String severity) {
    switch (severity.toLowerCase()) {
      case 'none': return 0.1;
      case 'mild': return 0.35;
      case 'moderate': return 0.68;
      case 'severe': return 1.0;
      default: return 0.2;
    }
  }

  void _onContinue() {
    context.push(
      '/report',
      extra: {
        'scanResult': widget.scanResult,
        'imageFile': widget.imageFile,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final result = widget.scanResult ??
        ScanResult(
          imageQuality: ImageQuality(usable: true, issues: []),
          overallScore: 82,
          skinTypeEstimate: 'combination',
          concerns: [],
          redFlags: [],
          notes: '',
        );

    final concerns = result.concerns;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Detected Skin Health'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Score Card
              GlowCard(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 46.0,
                      lineWidth: 8.0,
                      percent: result.overallScore / 100.0,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${result.overallScore}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: palette.primaryDark,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(fontSize: 10, color: palette.mutedText),
                          ),
                        ],
                      ),
                      progressColor: palette.primaryDark,
                      backgroundColor: palette.scoreRingTrack,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: palette.accentLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Type: ${result.skinTypeEstimate.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: palette.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Overall Skin Vitality',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: palette.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${concerns.length} visual markers analyzed across 6 facial zones.',
                            style: TextStyle(fontSize: 12, color: palette.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Zone highlight chip filters
              Text(
                'Facial Zones',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.primaryDark),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildZoneFilterChip('all', 'All Zones', palette),
                    _buildZoneFilterChip('forehead', 'Forehead', palette),
                    _buildZoneFilterChip('under_eyes', 'Under-Eyes', palette),
                    _buildZoneFilterChip('nose', 'Nose & T-Zone', palette),
                    _buildZoneFilterChip('cheeks', 'Cheeks', palette),
                    _buildZoneFilterChip('chin', 'Chin', palette),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Title: Detected Issues List
              Text(
                'Identified Skin Markers',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 18,
                      color: palette.primaryDark,
                    ),
              ),
              const SizedBox(height: 12),

              // Concern Cards List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: concerns.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final concern = concerns[i];
                  final sevColor = _getSeverityColor(concern.severity, palette);
                  final sevProgress = _getSeverityProgress(concern.severity);

                  return GlowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              concern.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: palette.primaryDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: sevColor.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                concern.severity.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: sevColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Severity Bar
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: sevProgress,
                                  backgroundColor: palette.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(sevColor),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(concern.confidence * 100).toInt()}% conf',
                              style: TextStyle(fontSize: 11, color: palette.mutedText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Explanation
                        Text(
                          concern.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: palette.secondaryText,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Zones tag row
                        Wrap(
                          spacing: 6,
                          children: concern.zones.map((z) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: palette.chipBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                z.replaceAll('_', ' '),
                                style: TextStyle(fontSize: 10, color: palette.secondaryText),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Bottom Action Button
              GlowPillButton(
                text: 'View Full Clinical Report',
                onPressed: _onContinue,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneFilterChip(String zoneKey, String label, GlowPalette palette) {
    final isSelected = _selectedZoneFilter == zoneKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedZoneFilter = zoneKey),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? palette.primaryDark : palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? palette.primaryDark : palette.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : palette.secondaryText,
          ),
        ),
      ),
    );
  }
}
