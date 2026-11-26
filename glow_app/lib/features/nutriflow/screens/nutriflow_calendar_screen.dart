import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';
import '../providers/nutriflow_provider.dart';

class NutriflowCalendarScreen extends ConsumerStatefulWidget {
  const NutriflowCalendarScreen({super.key});

  @override
  ConsumerState<NutriflowCalendarScreen> createState() => _NutriflowCalendarScreenState();
}

class _NutriflowCalendarScreenState extends ConsumerState<NutriflowCalendarScreen> {
  int _selectedDay = 26;

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        title: Text(
          'Nutriflow Calendar',
          style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'November 2026',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: palette.primaryDark),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  child: const Text('Month View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Calendar Grid Card
            GlowCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .map((d) => Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.mutedText)))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 30,
                    itemBuilder: (context, idx) {
                      final dayNum = idx + 1;
                      final isSelected = dayNum == _selectedDay;

                      Color dotColor = const Color(0xFF4E8752); // green met
                      if (dayNum > 26) dotColor = const Color(0xFFC58B2D); // gold planned
                      else if (dayNum % 6 == 0) dotColor = Colors.grey;

                      return InkWell(
                        onTap: () => setState(() => _selectedDay = dayNum),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? palette.accent.withOpacity(0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? palette.accent : Colors.transparent),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNum.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: palette.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _legendDot(const Color(0xFF4E8752), 'Met Target'),
                      _legendDot(const Color(0xFFC58B2D), 'Planned'),
                      _legendDot(Colors.grey, 'Incomplete'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selected Day Preview
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thursday, Nov $_selectedDay 2026',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '4 meals scheduled • 1,640 kcal • ₨ 360 budget',
                    style: TextStyle(fontSize: 12, color: palette.mutedText),
                  ),
                  const SizedBox(height: 12),
                  GlowButton(
                    text: 'Open Day Plan & Tracker',
                    isSecondary: true,
                    height: 40,
                    onPressed: () => context.push('/nutriflow/plan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
      ],
    );
  }
}
