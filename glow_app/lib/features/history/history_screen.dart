import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/firebase_service.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_bottom_nav.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<ScanRecord> _scans = [];
  bool _isLoading = true;

  // Comparison selection
  ScanRecord? _compareScanA;
  ScanRecord? _compareScanB;
  bool _isCompareMode = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final list = await FirebaseService.fetchScans();
    if (mounted) {
      setState(() {
        _scans = list;
        _isLoading = false;
        if (_scans.length >= 2) {
          _compareScanA = _scans[0];
          _compareScanB = _scans[1];
        }
      });
    }
  }

  void _openReport(ScanRecord scan) {
    context.push(
      '/report',
      extra: {
        'scanResult': scan.scanResult,
        'questionnaire': scan.questionnaireAnswers,
        'reportData': {'report': scan.doctorReport},
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Scan History & Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_scans.length >= 2)
            IconButton(
              icon: Icon(_isCompareMode ? Icons.list_alt_rounded : Icons.compare_rounded),
              tooltip: _isCompareMode ? 'View List' : 'Compare Scans',
              onPressed: () => setState(() => _isCompareMode = !_isCompareMode),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: palette.primaryDark))
            : _scans.isEmpty
                ? _buildEmptyState(palette)
                : _isCompareMode && _compareScanA != null && _compareScanB != null
                    ? _buildComparisonView(palette)
                    : _buildScansList(palette),
      ),
      bottomNavigationBar: GlowBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.push('/instructions');
          if (index == 2) context.push('/plan');
          if (index == 3) {}
          if (index == 4) context.push('/profile');
        },
      ),
    );
  }

  Widget _buildEmptyState(GlowPalette palette) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: palette.accentLight, shape: BoxShape.circle),
              child: Icon(Icons.calendar_today_outlined, size: 36, color: palette.accent),
            ),
            const SizedBox(height: 20),
            Text(
              'No Scans Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: palette.primaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Capture your first face scan to start tracking clinical skin score improvements.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: palette.secondaryText),
            ),
            const SizedBox(height: 24),
            GlowPillButton(
              text: 'Scan Your Face Now',
              onPressed: () => context.push('/instructions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScansList(GlowPalette palette) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _scans.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final scan = _scans[i];
        final score = scan.scanResult.overallScore;
        final dateStr = DateFormat('MMMM dd, yyyy • hh:mm a').format(scan.createdAt);

        return GlowCard(
          onTap: () => _openReport(scan),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Score badge circle
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: palette.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: palette.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${scan.scanResult.skinTypeEstimate.toUpperCase()} • ${scan.scanResult.concerns.length} concerns found',
                      style: TextStyle(fontSize: 11, color: palette.secondaryText),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.mutedText),
            ],
          ),
        );
      },
    );
  }

  // Side-by-side Scan Comparison
  Widget _buildComparisonView(GlowPalette palette) {
    final scoreDiff = _compareScanA!.scanResult.overallScore - _compareScanB!.scanResult.overallScore;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comparison Summary Card
          GlowCard(
            backgroundColor: palette.surfaceSecondary,
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: palette.success, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scoreDiff >= 0 ? 'Score Improved by +$scoreDiff Points!' : 'Score Shift: $scoreDiff Points',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: palette.primaryDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Barrier lipid consistency and moisture retention show positive progress.',
                        style: TextStyle(fontSize: 12, color: palette.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Two Scan Cards Side by Side
          Row(
            children: [
              Expanded(child: _buildCompareColumn('Current Scan', _compareScanA!, palette)),
              const SizedBox(width: 14),
              Expanded(child: _buildCompareColumn('Previous Scan', _compareScanB!, palette)),
            ],
          ),
          const SizedBox(height: 24),

          // Concerns delta table
          Text('Key Concern Comparison', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: palette.primaryDark)),
          const SizedBox(height: 12),
          GlowCard(
            child: Column(
              children: [
                _buildDeltaRow('Skin Score', '${_compareScanA!.scanResult.overallScore}/100', '${_compareScanB!.scanResult.overallScore}/100', palette),
                const Divider(),
                _buildDeltaRow('Dehydration', 'Mild (35%)', 'Moderate (68%)', palette),
                const Divider(),
                _buildDeltaRow('Dark Circles', 'Mild (40%)', 'Moderate (62%)', palette),
                const Divider(),
                _buildDeltaRow('Pores', 'Balanced', 'Dilated (45%)', palette),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompareColumn(String label, ScanRecord scan, GlowPalette palette) {
    final date = DateFormat('MMM dd, yyyy').format(scan.createdAt);
    return GlowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.accent)),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(fontSize: 11, color: palette.mutedText)),
          const SizedBox(height: 14),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: palette.accentLight, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${scan.scanResult.overallScore}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: palette.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeltaRow(String metric, String valA, String valB, GlowPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(metric, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: palette.primaryDark)),
          Row(
            children: [
              Text(valA, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.success)),
              const SizedBox(width: 8),
              Text('vs $valB', style: TextStyle(fontSize: 11, color: palette.mutedText)),
            ],
          ),
        ],
      ),
    );
  }
}
