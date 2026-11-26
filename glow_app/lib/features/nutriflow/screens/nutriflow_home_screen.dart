import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_bottom_nav.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';
import '../providers/nutriflow_provider.dart';
import '../models/meal_model.dart';

class NutriflowHomeScreen extends ConsumerWidget {
  const NutriflowHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);
    final nfState = ref.watch(nutriflowProvider);
    final nfNotifier = ref.read(nutriflowProvider.notifier);

    // Calculate totals eaten today
    double eatenCal = 0;
    double eatenProtein = 0;
    double eatenCarbs = 0;
    double eatenFiber = 0;
    double eatenPKR = 0;

    for (final id in nfState.dailyLog.eatenMealIds) {
      final meal = nfState.meals.firstWhere((m) => m.id == id, orElse: () => nfState.meals.first);
      eatenCal += meal.calories;
      eatenProtein += meal.protein;
      eatenCarbs += meal.carbs;
      eatenFiber += meal.fiber;
      eatenPKR += meal.estimatedCostPKR;
    }

    for (final custom in nfState.dailyLog.customFoods) {
      eatenCal += custom.calories;
      eatenProtein += custom.protein;
      eatenCarbs += custom.carbs;
      eatenPKR += custom.costPKR;
    }

    final double calorieTarget = 1650.0;
    final double calorieProgress = (eatenCal / calorieTarget).clamp(0.0, 1.0);

    // Next Meal (Lunch or first uneaten meal)
    final nextMeal = nfState.meals.firstWhere(
      (m) => !nfState.dailyLog.eatenMealIds.contains(m.id),
      orElse: () => nfState.meals.first,
    );

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thursday, 26 Nov',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: palette.accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nutriflow 🥗',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: palette.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.tune_rounded, color: palette.primaryDark),
                    onPressed: () => context.push('/nutriflow/setup'),
                    tooltip: 'Nutriflow Settings',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Clinical Disclaimer Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: palette.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'General nutrition guidance for skin and everyday health. Not medical advice.',
                        style: TextStyle(fontSize: 11, color: palette.secondaryText, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calories Ring & Macro Card
              GlowCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Nutrition",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: palette.primaryDark,
                          ),
                        ),
                        Text(
                          nfState.settings.hideCalories ? 'Quality-First Mode' : 'Floor: 1,200 kcal',
                          style: TextStyle(fontSize: 11, color: palette.mutedText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (!nfState.settings.hideCalories) ...[
                      // Calorie Circular Progress Ring
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: calorieProgress,
                              strokeWidth: 10,
                              backgroundColor: palette.bg,
                              valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  eatenCal.round().toString(),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: palette.primaryDark,
                                  ),
                                ),
                                Text(
                                  '/ ${calorieTarget.round()} kcal',
                                  style: TextStyle(fontSize: 11, color: palette.mutedText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.bg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.eco_rounded, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Focusing on nutrient density, fiber, and gut flora diversity.',
                                style: TextStyle(fontSize: 12, color: palette.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // Macro Split Bars
                    Row(
                      children: [
                        Expanded(
                          child: _MacroProgressTile(
                            label: 'Protein',
                            value: '${eatenProtein.round()} / 85g',
                            progress: (eatenProtein / 85).clamp(0.0, 1.0),
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroProgressTile(
                            label: 'Carbs',
                            value: '${eatenCarbs.round()} / 210g',
                            progress: (eatenCarbs / 210).clamp(0.0, 1.0),
                            color: const Color(0xFFC58B2D),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroProgressTile(
                            label: 'Fiber',
                            value: '${eatenFiber.round()} / 30g',
                            progress: (eatenFiber / 30).clamp(0.0, 1.0),
                            color: const Color(0xFF4E8752),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hydration Tracker Widget
              GlowCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop_rounded, color: Color(0xFF5B8296), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Hydration Tracker',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: palette.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${nfState.dailyLog.waterMl} / 2,500 ml',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B8296),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD6E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF5B8296)),
                            onPressed: () => nfNotifier.adjustWater(-250),
                          ),
                          Column(
                            children: [
                              Text(
                                '${(nfState.dailyLog.waterMl / 250).round()} Glasses',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C5263),
                                ),
                              ),
                              const Text('250 ml each', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFF5B8296)),
                            onPressed: () => nfNotifier.adjustWater(250),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Next Meal Card
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: palette.accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ],
                          child: Text(
                            'NEXT MEAL • ${nextMeal.mealType.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: palette.accent,
                            ),
                          ),
                        ),
                        Text(
                          '₨ ${nextMeal.estimatedCostPKR.round()} PKR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: palette.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            nextMeal.imageUrl,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 68,
                              height: 68,
                              color: palette.bg,
                              child: const Icon(Icons.restaurant),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nextMeal.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: palette.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${nextMeal.prepTimeMinutes} min prep • ${nextMeal.calories} kcal',
                                style: TextStyle(fontSize: 11.5, color: palette.mutedText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GlowButton(
                      text: 'View Recipe & Skin Benefits',
                      isSecondary: true,
                      height: 40,
                      onPressed: () => context.push('/nutriflow/meal-details', extra: nextMeal),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Budget & Streak Row
              Row(
                children: [
                  Expanded(
                    child: GlowCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Budget Spent', style: TextStyle(fontSize: 11, color: palette.mutedText)),
                          const SizedBox(height: 4),
                          Text(
                            '₨ ${eatenPKR.round()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: palette.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₨ ${(nfState.settings.dailyBudgetPKR - eatenPKR).clamp(0, 5000).round()} remaining',
                            style: const TextStyle(fontSize: 10.5, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Adherence Streak', style: TextStyle(fontSize: 11, color: palette.mutedText)),
                          const SizedBox(height: 4),
                          const Text(
                            '🔥 4 Days',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC58B2D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text('Best: 12 days', style: TextStyle(fontSize: 10.5, color: palette.mutedText)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Navigation Shortcuts
              Text(
                'EXPLORE NUTRIFLOW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: palette.mutedText,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _ShortcutCard(
                    icon: Icons.calendar_view_week_rounded,
                    title: '7-Day Plan',
                    subtitle: 'Meals & recipes',
                    onTap: () => context.push('/nutriflow/plan'),
                  ),
                  _ShortcutCard(
                    icon: Icons.checklist_rounded,
                    title: 'Daily Tracker',
                    subtitle: 'Log meals & water',
                    onTap: () => context.push('/nutriflow/tracker'),
                  ),
                  _ShortcutCard(
                    icon: Icons.alarm_rounded,
                    title: 'Schedule',
                    subtitle: 'Timings & alerts',
                    onTap: () => context.push('/nutriflow/schedule'),
                  ),
                  _ShortcutCard(
                    icon: Icons.insights_rounded,
                    title: 'Dashboard',
                    subtitle: 'Skin link & PDF',
                    onTap: () => context.push('/nutriflow/dashboard'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlowBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/instructions');
          if (index == 2) context.go('/plan');
          if (index == 3) context.go('/nutriflow');
          if (index == 4) context.go('/profile');
        },
      ),
    );
  }
}

class _MacroProgressTile extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color color;

  const _MacroProgressTile({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
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
}

class _ShortcutCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: palette.accent),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.primaryDark,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.5, color: palette.mutedText),
            ),
          ],
        ),
      ),
    );
  }
}
