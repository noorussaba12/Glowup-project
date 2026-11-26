import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';
import '../providers/nutriflow_provider.dart';
import '../models/meal_model.dart';

class NutriflowPlanScreen extends ConsumerWidget {
  const NutriflowPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);
    final nfState = ref.watch(nutriflowProvider);
    final nfNotifier = ref.read(nutriflowProvider.notifier);

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final currentMeals = nfState.weeklyPlan[nfState.selectedDay] ?? nfState.meals.take(4).toList();

    double totalCost = currentMeals.fold(0.0, (sum, m) => sum + m.estimatedCostPKR);
    double totalCal = currentMeals.fold(0.0, (sum, m) => sum + m.calories);

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        title: Text(
          '7-Day Meal Plan',
          style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Regenerate Day',
            onPressed: () => nfNotifier.regeneratePlan(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: days.map((d) {
                final isSel = d == nfState.selectedDay;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d),
                    selected: isSel,
                    selectedColor: palette.primaryDark,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : palette.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    onSelected: (_) => nfNotifier.selectDay(d),
                  ),
                );
              }).toList(),
            ),
          ),

          // Day Summary Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nfState.selectedDay} Overview',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text(
                        '${totalCal.round()} kcal • 4 meals',
                        style: TextStyle(fontSize: 11, color: palette.mutedText),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₨ ${totalCost.round()} PKR',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: palette.accent,
                        ),
                      ),
                      Text(
                        'Budget: ₨ ${nfState.settings.dailyBudgetPKR.round()}',
                        style: const TextStyle(fontSize: 11, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Meal List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: currentMeals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final meal = currentMeals[index];
                return _MealCard(
                  meal: meal,
                  onTap: () => context.push('/nutriflow/meal-details', extra: meal),
                  onSwap: () => nfNotifier.swapMeal(nfState.selectedDay, meal.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  final MealModel meal;
  final VoidCallback onTap;
  final VoidCallback onSwap;

  const _MealCard({
    required this.meal,
    required this.onTap,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(currentPaletteProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                meal.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: palette.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          meal.mealType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: palette.accent,
                          ),
                        ),
                      ),
                      Text(
                        '₨ ${meal.estimatedCostPKR.round()} PKR',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: palette.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: palette.primaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${meal.prepTimeMinutes} min prep • ${meal.calories} kcal',
                    style: TextStyle(fontSize: 11, color: palette.mutedText),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: meal.supportsGoals.take(2).map((g) {
                      final label = g.replaceAll('skin_', '').replaceAll('_', ' ');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF4E7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 9.5, color: Color(0xFFB57A22), fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.swap_horiz_rounded, color: palette.mutedText),
              onPressed: onSwap,
              tooltip: 'Swap Meal',
            ),
          ],
        ),
      ),
    );
  }
}
