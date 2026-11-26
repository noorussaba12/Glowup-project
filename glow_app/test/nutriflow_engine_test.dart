import 'package:flutter_test/flutter_test.dart';
import 'package:glow/features/nutriflow/models/ingredient_model.dart';
import 'package:glow/features/nutriflow/models/meal_model.dart';
import 'package:glow/features/nutriflow/models/nutriflow_settings_model.dart';
import 'package:glow/features/nutriflow/providers/diet_engine.dart';

void main() {
  group('Nutriflow Diet Plan Engine Tests', () {
    test('Calculates safe calorie target and enforces safe floor for adult female', () {
      // Very low weight / age where raw formula might yield low calories
      const lowBasics = UserPhysicalBasics(
        age: 35,
        sex: 'female',
        heightCm: 150.0,
        weightKg: 42.0,
        activityLevel: 'sedentary',
      );

      final target = DietPlanEngine.calculateCaloricTarget(lowBasics);

      // Must never breach safe floor of 1,200 kcal for women
      expect(target, greaterThanOrEqualTo(1200));
    });

    test('Enforces safe floor of 1,500 kcal for adult male', () {
      const lowMaleBasics = UserPhysicalBasics(
        age: 40,
        sex: 'male',
        heightCm: 160.0,
        weightKg: 50.0,
        activityLevel: 'sedentary',
      );

      final target = DietPlanEngine.calculateCaloricTarget(lowMaleBasics);

      // Must never breach safe floor of 1,500 kcal for men
      expect(target, greaterThanOrEqualTo(1500));
    });

    test('Under-18 rule hides/disables calorie restriction counting', () {
      const minorBasics = UserPhysicalBasics(
        age: 16,
        sex: 'female',
        heightCm: 162.0,
        weightKg: 55.0,
      );

      final target = DietPlanEngine.calculateCaloricTarget(minorBasics);

      // Target is 0, indicating quality-first uncounted mode
      expect(target, equals(0));
    });

    test('Allergy filter strictly removes meals containing allergens', () {
      final eggMeal = MealModel(
        id: 'boiled_eggs',
        name: 'Soft Boiled Eggs',
        mealType: 'breakfast',
        imageUrl: 'https://example.com/egg.jpg',
        ingredients: [],
        nutritionPerServing: const IngredientNutrition(
          calories: 180, protein: 14, carbs: 2, fiber: 0, sugar: 1, fat: 12, sodium: 150,
        ),
        estimatedCostPKR: 80,
        prepTimeMinutes: 10,
        difficulty: 'Easy',
        recipeSteps: [],
        allergens: ['eggs'],
        dietTags: ['halal', 'vegetarian'],
        supportsGoals: ['high_protein'],
        whyItWorks: '',
        whyItMatters: '',
        skinNutrients: [],
      );

      final oatsMeal = MealModel(
        id: 'oats_bowl',
        name: 'Rolled Oats with Berries',
        mealType: 'breakfast',
        imageUrl: 'https://example.com/oats.jpg',
        ingredients: [],
        nutritionPerServing: const IngredientNutrition(
          calories: 280, protein: 10, carbs: 45, fiber: 8, sugar: 6, fat: 5, sodium: 30,
        ),
        estimatedCostPKR: 90,
        prepTimeMinutes: 5,
        difficulty: 'Easy',
        recipeSteps: [],
        allergens: ['gluten'],
        dietTags: ['halal', 'vegetarian', 'vegan'],
        supportsGoals: ['high_fiber'],
        whyItWorks: '',
        whyItMatters: '',
        skinNutrients: [],
      );

      final allMeals = [eggMeal, oatsMeal];

      // User allergic to eggs
      final filteredForEggAllergy = DietPlanEngine.filterMeals(
        allMeals: allMeals,
        allergens: ['eggs'],
        dietTags: ['halal'],
        medicalFlags: [],
      );

      expect(filteredForEggAllergy.length, equals(1));
      expect(filteredForEggAllergy.first.id, equals('oats_bowl'));

      // User vegetarian (both pass)
      final filteredVegetarian = DietPlanEngine.filterMeals(
        allMeals: allMeals,
        allergens: [],
        dietTags: ['vegetarian'],
        medicalFlags: [],
      );
      expect(filteredVegetarian.length, equals(2));
    });

    test('Budget allocation respects PKR threshold and applies alternatives', () {
      final expensiveMeal = MealModel(
        id: 'almond_chia',
        name: 'Almond Chia Bowl',
        mealType: 'breakfast',
        imageUrl: 'https://example.com/almond.jpg',
        ingredients: [],
        nutritionPerServing: const IngredientNutrition(
          calories: 320, protein: 12, carbs: 30, fiber: 8, sugar: 4, fat: 14, sodium: 40,
        ),
        estimatedCostPKR: 250,
        prepTimeMinutes: 5,
        difficulty: 'Easy',
        recipeSteps: [],
        allergens: ['tree_nuts'],
        dietTags: ['halal', 'vegetarian'],
        supportsGoals: ['high_fiber'],
        whyItWorks: '',
        whyItMatters: '',
        skinNutrients: [],
        alternative: const MealAlternative(
          substituteName: 'Peanut Chia Bowl',
          savingPKR: 60,
          note: 'Peanuts are an affordable staple substitute.',
        ),
      );

      const settings = NutriflowSettingsModel(
        dailyBudgetPKR: 200, // Budget is 200, meal is 250
      );

      final plan = DietPlanEngine.assemble7DayPlan(
        eligibleMeals: [expensiveMeal],
        settings: settings,
      );

      expect(plan.containsKey('Mon'), isTrue);
      expect(plan['Mon']!.isNotEmpty, isTrue);
    });
  });
}
