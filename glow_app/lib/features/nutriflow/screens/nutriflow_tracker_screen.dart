import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';
import '../providers/nutriflow_provider.dart';
import '../models/diet_plan_model.dart';

class NutriflowTrackerScreen extends ConsumerStatefulWidget {
  const NutriflowTrackerScreen({super.key});

  @override
  ConsumerState<NutriflowTrackerScreen> createState() => _NutriflowTrackerScreenState();
}

class _NutriflowTrackerScreenState extends ConsumerState<NutriflowTrackerScreen> {
  final TextEditingController _foodNameCtrl = TextEditingController();
  final TextEditingController _foodCalCtrl = TextEditingController();
  final TextEditingController _foodCostCtrl = TextEditingController();

  @override
  void dispose() {
    _foodNameCtrl.dispose();
    _foodCalCtrl.dispose();
    _foodCostCtrl.dispose();
    super.dispose();
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Custom Food', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _foodNameCtrl,
                decoration: const InputDecoration(labelText: 'Food Name', hintText: 'e.g. 1 Apple, Roasted Grams'),
              ),
              TextField(
                controller: _foodCalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories (kcal)', hintText: '95'),
              ),
              TextField(
                controller: _foodCostCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Estimated Cost (PKR)', hintText: '30'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _foodNameCtrl.text.trim();
                final cal = double.tryParse(_foodCalCtrl.text) ?? 100.0;
                final cost = double.tryParse(_foodCostCtrl.text) ?? 30.0;
                if (name.isNotEmpty) {
                  ref.read(nutriflowProvider.notifier).addCustomFood(
                    CustomLoggedFood(name: name, calories: cal, protein: 4, carbs: 15, costPKR: cost),
                  );
                  _foodNameCtrl.clear();
                  _foodCalCtrl.clear();
                  _foodCostCtrl.clear();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Log Food'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final nfState = ref.watch(nutriflowProvider);
    final nfNotifier = ref.read(nutriflowProvider.notifier);

    final todayMeals = nfState.weeklyPlan[nfState.selectedDay] ?? nfState.meals.take(4).toList();

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        title: Text(
          'Daily Tracker',
          style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Custom Food',
            onPressed: _showAddFoodDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Planned Meals Checklist
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Planned Meals for Today', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...todayMeals.map((meal) {
                    final isEaten = nfState.dailyLog.eatenMealIds.contains(meal.id);
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(meal.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('${meal.calories} kcal • ₨ ${meal.estimatedCostPKR.round()} PKR', style: const TextStyle(fontSize: 11)),
                      value: isEaten,
                      activeColor: palette.accent,
                      onChanged: (_) => nfNotifier.toggleMealEaten(meal.id),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Custom Logged Foods
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Custom Foods Logged', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: _showAddFoodDialog,
                        child: Text('+ Add', style: TextStyle(color: palette.accent)),
                      ),
                    ],
                  ),
                  if (nfState.dailyLog.customFoods.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No extra snacks logged today.', style: TextStyle(fontSize: 12, color: palette.mutedText)),
                    )
                  else
                    ...nfState.dailyLog.customFoods.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('• ${f.name} (${f.calories.round()} kcal)', style: const TextStyle(fontSize: 12.5)),
                          Text('₨ ${f.costPKR.round()} PKR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: palette.accent)),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Water Log
            GlowCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Water Intake', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('${nfState.dailyLog.waterMl} / 2,500 ml', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => nfNotifier.adjustWater(-250),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF5B8296)),
                        onPressed: () => nfNotifier.adjustWater(250),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GlowButton(
              text: 'View Nutrition Dashboard',
              onPressed: () => context.push('/nutriflow/dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
