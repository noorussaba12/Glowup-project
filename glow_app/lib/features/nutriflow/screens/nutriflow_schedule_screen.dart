import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';
import '../providers/nutriflow_provider.dart';

class NutriflowScheduleScreen extends ConsumerWidget {
  const NutriflowScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);
    final nfState = ref.watch(nutriflowProvider);

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        title: Text(
          'Schedule & Reminders',
          style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Nutrition Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _timelineItem(
                    palette: palette,
                    time: nfState.settings.reminders.breakfast,
                    slot: 'BREAKFAST',
                    title: '2 Soft Boiled Eggs & Veggies',
                    icon: Icons.egg_outlined,
                  ),
                  _timelineItem(
                    palette: palette,
                    time: '10:30 AM',
                    slot: 'HYDRATION',
                    title: '250ml Water Reminder 💧',
                    icon: Icons.water_drop_outlined,
                    isWater: true,
                  ),
                  _timelineItem(
                    palette: palette,
                    time: nfState.settings.reminders.lunch,
                    slot: 'LUNCH',
                    title: 'High-Fiber Mint Lemon Chana Chaat',
                    icon: Icons.restaurant,
                  ),
                  _timelineItem(
                    palette: palette,
                    time: nfState.settings.reminders.snack,
                    slot: 'SNACK',
                    title: 'Refreshing Mint Probiotic Buttermilk',
                    icon: Icons.local_drink_outlined,
                  ),
                  _timelineItem(
                    palette: palette,
                    time: nfState.settings.reminders.dinner,
                    slot: 'DINNER',
                    title: 'Spiced Spinach & Scrambled Eggs with Roti',
                    icon: Icons.dinner_dining_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlowButton(
              text: 'Save Schedule & Sync Reminders',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Local meal & water reminders synced!'),
                    backgroundColor: Color(0xFF4E8752),
                  ),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem({
    required dynamic palette,
    required String time,
    required String slot,
    required String title,
    required IconData icon,
    bool isWater = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isWater ? const Color(0xFFEBF3F7) : palette.accent.withOpacity(0.12),
            child: Icon(icon, size: 16, color: isWater ? const Color(0xFF5B8296) : palette.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$time • $slot',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isWater ? const Color(0xFF5B8296) : palette.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: palette.primaryDark),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            activeColor: isWater ? const Color(0xFF5B8296) : palette.accent,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }
}
