import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';
import '../providers/nutriflow_provider.dart';
import '../models/meal_model.dart';

class NutriflowMealDetailsScreen extends ConsumerStatefulWidget {
  final MealModel? meal;

  const NutriflowMealDetailsScreen({super.key, this.meal});

  @override
  ConsumerState<NutriflowMealDetailsScreen> createState() => _NutriflowMealDetailsScreenState();
}

class _NutriflowMealDetailsScreenState extends ConsumerState<NutriflowMealDetailsScreen> {
  late MealModel _currentMeal;
  bool _alternativeApplied = false;

  @override
  void initState() {
    super.initState();
    _currentMeal = widget.meal ?? ref.read(nutriflowProvider).meals.first;
  }

  void _applyAlternative() {
    if (_currentMeal.alternative != null && !_alternativeApplied) {
      setState(() {
        _alternativeApplied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Swapped to ${_currentMeal.alternative!.substituteName}! Saved ₨ ${_currentMeal.alternative!.savingPKR.round()} PKR.'),
          backgroundColor: const Color(0xFF4E8752),
        ),
      );
    }
  }

  void _markAsEaten() {
    ref.read(nutriflowProvider.notifier).toggleMealEaten(_currentMeal.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Meal marked as eaten today! Your daily tracker and calories ring have updated.'),
        backgroundColor: Color(0xFF4E8752),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final effectiveCost = _alternativeApplied
        ? (_currentMeal.estimatedCostPKR - (_currentMeal.alternative?.savingPKR ?? 0))
        : _currentMeal.estimatedCostPKR;

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        title: Text(
          'Meal Details',
          style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _currentMeal.imageUrl,
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 190,
                  color: palette.surface,
                  child: const Icon(Icons.restaurant, size: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Meta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _currentMeal.mealType.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: palette.accent),
                  ),
                ),
                Text(
                  '₨ ${effectiveCost.round()} PKR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: palette.accent),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _currentMeal.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: palette.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_currentMeal.prepTimeMinutes} min prep • ${_currentMeal.difficulty} • ${_currentMeal.calories} kcal',
              style: TextStyle(fontSize: 12, color: palette.mutedText),
            ),
            const SizedBox(height: 16),

            // How this meal works for you
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: palette.accent),
                      const SizedBox(width: 6),
                      Text(
                        'HOW THIS MEAL WORKS FOR YOU',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: palette.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentMeal.whyItWorks,
                    style: TextStyle(fontSize: 12.5, color: palette.primaryDark, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Why it matters
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: palette.mutedText),
                      const SizedBox(width: 6),
                      Text(
                        'WHY IT IS IMPORTANT',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: palette.mutedText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentMeal.whyItMatters,
                    style: TextStyle(fontSize: 12.5, color: palette.primaryDark, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Recipe Steps
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How to Prepare (Recipe)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ..._currentMeal.recipeSteps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key + 1}. ',
                            style: TextStyle(fontWeight: FontWeight.w700, color: palette.accent),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 12.5, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Nutritional Breakdown Table
            GlowCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What It Gives You (Per Serving)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _nutriBox('Calories', '${_currentMeal.calories.round()}'),
                      _nutriBox('Protein', '${_currentMeal.protein}g'),
                      _nutriBox('Carbs', '${_currentMeal.carbs}g'),
                      _nutriBox('Fiber', '${_currentMeal.fiber}g'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _nutriBox('Sugar', '${_currentMeal.nutritionPerServing.sugar}g'),
                      _nutriBox('Fats', '${_currentMeal.nutritionPerServing.fat}g'),
                      _nutriBox('Sodium', '${_currentMeal.sodium.round()}mg'),
                    ],
                  ),
                  if (_currentMeal.skinNutrients.isNotEmpty) ...[
                    const Divider(height: 24),
                    const Text('Skin Nutrients & Benefits', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey)),
                    const SizedBox(height: 6),
                    ..._currentMeal.skinNutrients.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• ${s.nutrient}: ${s.benefitNote}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                    )),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Affordable Alternative Card
            if (_currentMeal.alternative != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD6E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.savings_outlined, size: 16, color: Color(0xFF2C5263)),
                            SizedBox(width: 6),
                            Text('Affordable Pakistani Alternative', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2C5263))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Save ₨ ${_currentMeal.alternative!.savingPKR.round()} PKR',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF3B7E40)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentMeal.alternative!.substituteName,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentMeal.alternative!.note,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    GlowButton(
                      text: _alternativeApplied ? 'Alternative Applied' : 'Swap to Cheaper Staple',
                      isSecondary: true,
                      height: 36,
                      onPressed: _applyAlternative,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            GlowButton(
              text: 'Mark as Eaten Today',
              onPressed: _markAsEaten,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _nutriBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
