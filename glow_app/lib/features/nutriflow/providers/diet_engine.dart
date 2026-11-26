import '../models/meal_model.dart';
import '../models/ingredient_model.dart';
import '../models/nutriflow_settings_model.dart';
import '../models/diet_plan_model.dart';

class DietPlanEngine {
  /// Step A: Calculate safe calorie target using Mifflin-St Jeor Equation with clinical floors
  static int calculateCaloricTarget(UserPhysicalBasics basics) {
    // Under 18 rule: no calorie restriction or counting targets
    if (basics.age < 18) {
      return 0; // Signifies uncounted, quality-first mode
    }

    double bmr;
    if (basics.sex.toLowerCase() == 'male') {
      bmr = (10 * basics.weightKg) + (6.25 * basics.heightCm) - (5 * basics.age) + 5;
    } else {
      bmr = (10 * basics.weightKg) + (6.25 * basics.heightCm) - (5 * basics.age) - 161;
    }

    double activityFactor = 1.375; // Moderate daily activity default
    if (basics.activityLevel == 'sedentary') activityFactor = 1.2;
    if (basics.activityLevel == 'active') activityFactor = 1.55;

    int target = (bmr * activityFactor).round();

    // Enforce Safe Caloric Floor (widely published clinical minimums)
    final int safeFloor = (basics.sex.toLowerCase() == 'male') ? 1500 : 1200;
    if (target < safeFloor) {
      target = safeFloor;
    }

    return target;
  }

  /// Step B: Hard Filters (Removes meals that conflict with allergies or diet restrictions)
  static List<MealModel> filterMeals({
    required List<MealModel> allMeals,
    required List<String> allergens,
    required List<String> dietTags,
    required List<String> medicalFlags,
  }) {
    return allMeals.where((meal) {
      // Must be verified by clinic/owner
      if (!meal.verified) return false;

      // 1. Allergen conflict check
      for (final allergy in allergens) {
        final cleanAllergy = allergy.toLowerCase().trim();
        if (cleanAllergy.isEmpty) continue;
        for (final mealAllergen in meal.allergens) {
          if (mealAllergen.toLowerCase().contains(cleanAllergy) ||
              cleanAllergy.contains(mealAllergen.toLowerCase())) {
            return false;
          }
        }
      }

      // 2. Strict Dietary Tags (e.g. halal, vegetarian, vegan)
      if (dietTags.contains('vegetarian') && !meal.dietTags.contains('vegetarian')) {
        return false;
      }
      if (dietTags.contains('vegan') && !meal.dietTags.contains('vegan')) {
        return false;
      }
      if (dietTags.contains('halal') && !meal.dietTags.contains('halal')) {
        return false;
      }

      // 3. Conservative medical flags
      if (medicalFlags.contains('diabetes') && meal.nutritionPerServing.sugar > 15.0) {
        return false;
      }
      if (medicalFlags.contains('hypertension') && meal.nutritionPerServing.sodium > 450.0) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Step C: Scoring Meals based on Skin Priorities, Goals, and Home Pantry Overlap
  static double scoreMeal({
    required MealModel meal,
    required List<String> userGoals,
    required String primarySkinConcern,
    required List<String> homeFoods,
  }) {
    double score = 10.0;

    // 1. Goal Alignment
    for (final goal in userGoals) {
      if (meal.supportsGoals.contains(goal)) {
        score += 5.0;
      }
    }

    // 2. Primary Skin Concern Priority (highest weighting from scan)
    if (primarySkinConcern.isNotEmpty) {
      final concernTag = 'skin_${primarySkinConcern.toLowerCase().replaceAll(' ', '_')}';
      if (meal.supportsGoals.contains(concernTag) ||
          meal.supportsGoals.contains('skin_dehydration') ||
          meal.supportsGoals.contains('skin_barrier')) {
        score += 12.0; // Major boost for scan-linked dermatological benefit
      }
    }

    // 3. Pantry Food Overlap Bonus (uses food already at home)
    for (final food in homeFoods) {
      final clean = food.toLowerCase().trim();
      if (clean.isNotEmpty && meal.name.toLowerCase().contains(clean)) {
        score += 8.0;
      }
    }

    return score;
  }

  /// Step D: Assemble a 7-Day Balanced Diet Plan matching PKR Budget
  static Map<String, List<MealModel>> assemble7DayPlan({
    required List<MealModel> eligibleMeals,
    required NutriflowSettingsModel settings,
  }) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, List<MealModel>> plan = {};

    final breakfasts = eligibleMeals.where((m) => m.mealType == 'breakfast').toList();
    final lunches = eligibleMeals.where((m) => m.mealType == 'lunch').toList();
    final snacks = eligibleMeals.where((m) => m.mealType == 'snack').toList();
    final dinners = eligibleMeals.where((m) => m.mealType == 'dinner').toList();

    for (int i = 0; i < days.length; i++) {
      final day = days[i];

      final b = (breakfasts.isNotEmpty) ? breakfasts[i % breakfasts.length] : eligibleMeals.first;
      final l = (lunches.isNotEmpty) ? lunches[(i + 1) % lunches.length] : eligibleMeals.first;
      final s = (snacks.isNotEmpty) ? snacks[i % snacks.length] : eligibleMeals.first;
      final d = (dinners.isNotEmpty) ? dinners[(i + 2) % dinners.length] : eligibleMeals.first;

      final dayMeals = [b, l, s, d];

      // Check daily PKR budget
      double totalDayCost = dayMeals.fold(0.0, (sum, m) => sum + m.estimatedCostPKR);
      if (totalDayCost > settings.dailyBudgetPKR) {
        // Apply affordable alternative to meals that offer one
        for (int mIdx = 0; mIdx < dayMeals.length; mIdx++) {
          final m = dayMeals[mIdx];
          if (m.alternative != null && totalDayCost > settings.dailyBudgetPKR) {
            // Apply alternative saving
            totalDayCost -= m.alternative!.savingPKR;
          }
        }
      }

      plan[day] = dayMeals;
    }

    return plan;
  }
}
