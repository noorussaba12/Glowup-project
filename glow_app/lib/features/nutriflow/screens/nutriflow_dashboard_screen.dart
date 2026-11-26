import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';

class NutriflowDashboardScreen extends ConsumerWidget {
  const NutriflowDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        title: Text(
          'Nutrition Analytics',
          style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export PDF',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📄 Generating Clinical Nutrition Summary PDF...'),
                  backgroundColor: Color(0xFF4E8752),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adherence Stats Card
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dietary Consistency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text(
                        '🔥 88% Adherence',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: palette.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _goalProgressRow('Fiber Goal (30g/day)', 'Met 6 of 7 days', 6 / 7, const Color(0xFF4E8752)),
                  _goalProgressRow('Sodium Guideline (<2,000mg)', 'Met 5 of 7 days', 5 / 7, const Color(0xFFC58B2D)),
                  _goalProgressRow('Hydration Target (2.5L)', 'Met 6 of 7 days', 6 / 7, const Color(0xFF5B8296)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Crucial Skin Link Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEBDAD3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link_rounded, size: 16, color: palette.accent),
                      const SizedBox(width: 6),
                      Text(
                        'SKIN LINK: ADHERENCE & PROGRESS',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: palette.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Skin Goals This Month',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: palette.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Over your 3-week nutrition adherence, your latest Scan showed a +14 point improvement in epidermal moisture and a reduction in mid-facial redness markers.',
                    style: TextStyle(fontSize: 12.5, color: palette.primaryDark, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Multifactorial Clinical Note: Skin improvements have many simultaneous causes (adequate sleep, lower stress, gentle barrier skincare, and water intake). Nutrition supports intracellular health but is not proof of sole causation.',
                      style: TextStyle(fontSize: 11, color: palette.secondaryText, height: 1.35),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GlowButton(
                    text: 'Rescan Skin (4-Week Progress Check)',
                    isSecondary: true,
                    height: 40,
                    onPressed: () => context.push('/instructions'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Weekly Averages Card
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Averages vs Targets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _metricRow('Average Daily Calories', '1,610 kcal / day'),
                  _metricRow('Average Protein Intake', '74g (Target: 80g)'),
                  _metricRow('Average Daily Grocery Cost', '₨ 580 PKR (Under ₨ 800 Target)'),
                  _metricRow('Average Daily Water', '2.3 Liters / day'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GlowButton(
              text: 'Export Weekly Nutrition Summary (PDF)',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📄 Exported Weekly Summary to Downloads!'),
                    backgroundColor: Color(0xFF4E8752),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalProgressRow(String title, String subtitle, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
