import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';
import '../models/ingredient_model.dart';
import '../models/nutriflow_settings_model.dart';
import '../models/diet_plan_model.dart';
import 'diet_engine.dart';

final initialVerifiedMeals = [
  MealModel(
    id: "oats_dahi_nuts",
    name: "Rolled Oats with Fresh Dahi & Almonds",
    mealType: "breakfast",
    imageUrl: "https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?auto=format&fit=crop&w=600&q=80",
    ingredients: [
      MealIngredientItem(ingredientId: "oats", quantity: 50, unit: "g"),
      MealIngredientItem(ingredientId: "fresh_dahi", quantity: 150, unit: "g"),
      MealIngredientItem(ingredientId: "almonds", quantity: 15, unit: "g"),
    ],
    nutritionPerServing: const IngredientNutrition(
      calories: 342, protein: 15.1, carbs: 38.1, fiber: 6.8, sugar: 5.4, fat: 12.2, sodium: 48,
    ),
    estimatedCostPKR: 95,
    prepTimeMinutes: 10,
    difficulty: "Easy",
    recipeSteps: [
      "Add rolled oats to a bowl with warm water or milk to soften for 5 mins.",
      "Stir in plain fresh probiotic dahi until creamy.",
      "Top with chopped raw almonds and a pinch of cinnamon."
    ],
    allergens: ["dairy", "tree_nuts", "gluten"],
    dietTags: ["halal", "vegetarian"],
    supportsGoals: ["high_fiber", "hydration", "skin_dehydration", "more_protein"],
    whyItWorks: "Oats contain beta-glucans that support gut barrier integrity, while dahi provides lactic hydration that may support intracellular moisture retention.",
    whyItMatters: "Supplies slow-burning complex carbohydrates without provoking insulin-driven sebum spikes.",
    skinNutrients: [
      SkinNutrientClaim(nutrient: "Beta-Glucans", benefitNote: "Prebiotic fiber linked to gut barrier reinforcement"),
      SkinNutrientClaim(nutrient: "Lactic Acid Bacteria", benefitNote: "Probiotic cultures associated with balanced inflammatory response"),
    ],
    alternative: MealAlternative(
      substituteName: "Substitute almonds with roasted peanuts",
      savingPKR: 20,
      note: "Peanuts are an affordable staple providing protein and zinc; slightly higher monounsaturated fat.",
    ),
  ),
  MealModel(
    id: "boiled_eggs_veggies",
    name: "2 Soft Boiled Eggs with Sliced Cucumber & Tomato",
    mealType: "breakfast",
    imageUrl: "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=600&q=80",
    ingredients: [
      MealIngredientItem(ingredientId: "farm_eggs", quantity: 100, unit: "g"),
      MealIngredientItem(ingredientId: "cucumber", quantity: 100, unit: "g"),
      MealIngredientItem(ingredientId: "tomatoes", quantity: 80, unit: "g"),
    ],
    nutritionPerServing: const IngredientNutrition(
      calories: 178, protein: 13.7, carbs: 3.9, fiber: 0.9, sugar: 2.4, fat: 11.5, sodium: 152,
    ),
    estimatedCostPKR: 85,
    prepTimeMinutes: 12,
    difficulty: "Easy",
    recipeSteps: [
      "Boil 2 farm eggs in boiling water for 6-7 minutes for soft-boiled centers.",
      "Slice fresh cucumber and tomatoes into thin rounds.",
      "Season lightly with cracked black pepper and Himalayan pink salt."
    ],
    allergens: ["eggs"],
    dietTags: ["halal", "vegetarian"],
    supportsGoals: ["high_protein", "lower_carbs", "low_sodium", "skin_barrier"],
    whyItWorks: "Eggs provide bioavailable choline and sulfur-bearing amino acids essential for native collagen cross-linking and cellular repair.",
    whyItMatters: "High protein breakfast dampens morning ghrelin spikes and supports steady blood glucose.",
    skinNutrients: [
      SkinNutrientClaim(nutrient: "Bioavailable Choline", benefitNote: "Constituent of phosphatidylcholine, vital for cell membrane flexibility"),
      SkinNutrientClaim(nutrient: "Lycopene", benefitNote: "Lipid-soluble antioxidant supporting natural photoprotective defenses"),
    ],
  ),
  MealModel(
    id: "chana_chaat_salad",
    name: "High-Fiber Mint Lemon Chana Chaat",
    mealType: "lunch",
    imageUrl: "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=600&q=80",
    ingredients: [
      MealIngredientItem(ingredientId: "chickpeas", quantity: 150, unit: "g"),
      MealIngredientItem(ingredientId: "cucumber", quantity: 80, unit: "g"),
      MealIngredientItem(ingredientId: "tomatoes", quantity: 60, unit: "g"),
    ],
    nutritionPerServing: const IngredientNutrition(
      calories: 318, protein: 16.5, carbs: 52.2, fiber: 14.6, sugar: 9.2, fat: 5.1, sodium: 28,
    ),
    estimatedCostPKR: 75,
    prepTimeMinutes: 15,
    difficulty: "Easy",
    recipeSteps: [
      "Rinse boiled white chickpeas and place in a mixing bowl.",
      "Finely dice crisp cucumber and ripe tomatoes.",
      "Toss with fresh lemon juice, roasted cumin powder, and fresh mint leaves."
    ],
    allergens: [],
    dietTags: ["halal", "vegetarian", "vegan"],
    supportsGoals: ["high_fiber", "low_sodium", "less_added_sugar", "skin_acne"],
    whyItWorks: "Chickpeas deliver soluble prebiotic oligosaccharides that nourish beneficial gut bacteroidetes, which research associates with reduced systemic skin redness.",
    whyItMatters: "Rich dietary fiber content keeps glycemic index low, minimizing sebum gland stimulation.",
    skinNutrients: [
      SkinNutrientClaim(nutrient: "Prebiotic Oligosaccharides", benefitNote: "Supports commensal gut flora to moderate cutaneous histamine reactions"),
      SkinNutrientClaim(nutrient: "Vitamin C", benefitNote: "Essential cofactor in proline hydroxylation for collagen synthesis"),
    ],
    alternative: MealAlternative(
      substituteName: "Substitute white chickpeas with black chana (Kala Chana)",
      savingPKR: 15,
      note: "Kala chana is higher in insoluble fiber and iron, offering greater satiety for ₨ 15 less.",
    ),
  ),
  MealModel(
    id: "daal_roti_salad",
    name: "Yellow Moong Daal with 1 Whole Wheat Roti & Salad",
    mealType: "lunch",
    imageUrl: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80",
    ingredients: [
      MealIngredientItem(ingredientId: "moong_daal", quantity: 100, unit: "g"),
      MealIngredientItem(ingredientId: "atta_roti", quantity: 40, unit: "g"),
      MealIngredientItem(ingredientId: "cucumber", quantity: 80, unit: "g"),
    ],
    nutritionPerServing: const IngredientNutrition(
      calories: 395, protein: 18.2, carbs: 64.1, fiber: 12.8, sugar: 4.8, fat: 7.2, sodium: 310,
    ),
    estimatedCostPKR: 90,
    prepTimeMinutes: 25,
    difficulty: "Medium",
    recipeSteps: [
      "Simmer soaked yellow moong daal with turmeric, garlic, and cumin.",
      "Temper lightly with 1 tsp mustard oil or desi ghee and cumin seeds.",
      "Roll and cook 1 fresh whole wheat roti on a tawa.",
      "Serve warm with sliced cucumber and lemon."
    ],
    allergens: ["gluten"],
    dietTags: ["halal", "vegetarian"],
    supportsGoals: ["high_fiber", "low_sodium", "skin_barrier"],
    whyItWorks: "Moong daal is easily digested and delivers plant protein along with polyphenols that support antioxidant balance.",
    whyItMatters: "Balanced staple providing complex starches and sustained post-prandial energy.",
    skinNutrients: [
      SkinNutrientClaim(nutrient: "Polyphenolic Flavonoids", benefitNote: "Plant antioxidants scavenging free radicals from UV exposure"),
    ],
  ),
  MealModel(
    id: "unsweetened_lassi_snack",
    name: "Refreshing Mint Probiotic Buttermilk (Namkeen Lassi)",
    mealType: "snack",
    imageUrl: "https://images.unsplash.com/photo-1571212515416-fef01fc43637?auto=format&fit=crop&w=600&q=80",
    ingredients: [
      MealIngredientItem(ingredientId: "fresh_dahi", quantity: 100, unit: "g"),
      MealIngredientItem(ingredientId: "water_mint", quantity: 150, unit: "ml"),
    ],
    nutritionPerServing: const IngredientNutrition(
      calories: 98, protein: 5.5, carbs: 7.8, fiber: 0.2, sugar: 7.2, fat: 5.0, sodium: 70,
    ),
    estimatedCostPKR: 40,
    prepTimeMinutes: 5,
    difficulty: "Easy",
    recipeSteps: [
      "Blend fresh dahi with 1 glass of chilled water and fresh mint leaves.",
      "Add a pinch of roasted cumin powder and black salt.",
      "Serve chilled without any added sugar or condensed milk."
    ],
    allergens: ["dairy"],
    dietTags: ["halal", "vegetarian"],
    supportsGoals: ["hydration", "less_added_sugar", "low_sodium", "skin_dehydration"],
    whyItWorks: "Fermented live cultures in authentic dahi reinforce gut flora, which research demonstrates plays a key role in moderating cutaneous histamine sensitivity.",
    whyItMatters: "Replenishes electrolytes and natural fluid balance during warm or dry conditions.",
    skinNutrients: [
      SkinNutrientClaim(nutrient: "Live Lactobacillus Cultures", benefitNote: "Supports mucosal and cutaneous immune homeostasis"),
    ],
  ),
  MealModel(
    id: "palak_egg_bhurji",
    name: "Spiced Spinach & Scrambled Eggs with 1 Roti",
    mealType: "dinner",
    imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80",
    ingredients: [
      MealIngredientItem(ingredientId: "farm_eggs", quantity: 100, unit: "g"),
      MealIngredientItem(ingredientId: "spinach", quantity: 100, unit: "g"),
      MealIngredientItem(ingredientId: "atta_roti", quantity: 40, unit: "g"),
    ],
    nutritionPerServing: const IngredientNutrition(
      calories: 312, protein: 18.8, carbs: 28.9, fiber: 4.8, sugar: 1.2, fat: 14.2, sodium: 228,
    ),
    estimatedCostPKR: 105,
    prepTimeMinutes: 18,
    difficulty: "Medium",
    recipeSteps: [
      "Sauté fresh chopped spinach in 1 tsp mustard oil with garlic and green chili until wilted.",
      "Whisk 2 eggs and scramble gently with the spinach.",
      "Serve alongside 1 hot whole wheat roti freshly prepared."
    ],
    allergens: ["eggs", "gluten"],
    dietTags: ["halal", "vegetarian"],
    supportsGoals: ["high_protein", "high_fiber", "skin_barrier"],
    whyItWorks: "Spinach delivers lutein and beta-carotene while eggs supply complete proteins for nocturnal tissue repair.",
    whyItMatters: "Nutrient-dense dinner meeting both protein and vegetable targets under a modest budget.",
    skinNutrients: [
      SkinNutrientClaim(nutrient: "Lutein & Zeaxanthin", benefitNote: "Carotenoid pigments concentrated in skin to absorb blue-light stress"),
    ],
  ),
  MealModel(
    id: "chicken_kachumber_salad",
    name: "Tawa Grilled Chicken Breast with Kachumber Salad",
    mealType: "dinner",
    imageUrl: "https://images.unsplash.com/photo-1543339308-43e59d6b73a6?auto=format&fit=crop&w=600&q=80",
    ingredients: [
      MealIngredientItem(ingredientId: "chicken_breast", quantity: 120, unit: "g"),
      MealIngredientItem(ingredientId: "cucumber", quantity: 80, unit: "g"),
      MealIngredientItem(ingredientId: "tomatoes", quantity: 60, unit: "g"),
    ],
    nutritionPerServing: const IngredientNutrition(
      calories: 285, protein: 32.4, carbs: 8.5, fiber: 2.8, sugar: 4.1, fat: 13.8, sodium: 185,
    ),
    estimatedCostPKR: 140,
    prepTimeMinutes: 20,
    difficulty: "Easy",
    recipeSteps: [
      "Marinate skinless chicken breast with lemon juice, black pepper, and garlic paste.",
      "Grill on a non-stick tawa with 1 tsp oil until charred and cooked through.",
      "Toss diced cucumber, tomatoes, and red onions with lemon and mint.",
      "Serve the sliced chicken over the kachumber salad."
    ],
    allergens: [],
    dietTags: ["halal"],
    supportsGoals: ["high_protein", "lower_carbs", "low_sodium", "skin_barrier"],
    whyItWorks: "Lean poultry delivers high-density lysine and proline, the rate-limiting amino acids for dermal collagen assembly.",
    whyItMatters: "Satiating, low-glycemic evening meal preventing nocturnal blood sugar drops.",
    skinNutrients: [
      SkinNutrientClaim(nutrient: "L-Proline & L-Lysine", benefitNote: "Fundamental amino acid substrates for collagen fibril assembly"),
    ],
    alternative: MealAlternative(
      substituteName: "Substitute chicken breast with spiced boiled eggs (2 eggs)",
      savingPKR: 55,
      note: "Eggs offer high bioavailability protein for ₨ 55 less per serving.",
    ),
  ),
];

class NutriflowState {
  final List<MealModel> meals;
  final NutriflowSettingsModel settings;
  final DailyNutritionLog dailyLog;
  final Map<String, List<MealModel>> weeklyPlan;
  final String selectedDay;
  final bool isLoading;

  const NutriflowState({
    required this.meals,
    required this.settings,
    required this.dailyLog,
    required this.weeklyPlan,
    this.selectedDay = 'Thu',
    this.isLoading = false,
  });

  NutriflowState copyWith({
    List<MealModel>? meals,
    NutriflowSettingsModel? settings,
    DailyNutritionLog? dailyLog,
    Map<String, List<MealModel>>? weeklyPlan,
    String? selectedDay,
    bool? isLoading,
  }) {
    return NutriflowState(
      meals: meals ?? this.meals,
      settings: settings ?? this.settings,
      dailyLog: dailyLog ?? this.dailyLog,
      weeklyPlan: weeklyPlan ?? this.weeklyPlan,
      selectedDay: selectedDay ?? this.selectedDay,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NutriflowNotifier extends StateNotifier<NutriflowState> {
  NutriflowNotifier()
      : super(NutriflowState(
          meals: initialVerifiedMeals,
          settings: const NutriflowSettingsModel(),
          dailyLog: const DailyNutritionLog(
            date: '2026-11-26',
            eatenMealIds: ['boiled_eggs_veggies', 'unsweetened_lassi_snack'],
            waterMl: 1750,
          ),
          weeklyPlan: DietPlanEngine.assemble7DayPlan(
            eligibleMeals: initialVerifiedMeals,
            settings: const NutriflowSettingsModel(),
          ),
        )) {
    _fetchMealsFromBackend();
  }

  Future<void> _fetchMealsFromBackend() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/api/nutriflow/meals'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['meals'] != null) {
          final List<MealModel> loaded = (data['meals'] as List)
              .map((m) => MealModel.fromMap(m as Map<String, dynamic>, m['id'] ?? ''))
              .toList();
          if (loaded.isNotEmpty) {
            state = state.copyWith(meals: loaded);
            regeneratePlan();
          }
        }
      }
    } catch (_) {
      // Gracefully retains verified offline meals
    }
  }

  void updateSettings(NutriflowSettingsModel newSettings) {
    state = state.copyWith(settings: newSettings);
    regeneratePlan();
  }

  void selectDay(String day) {
    state = state.copyWith(selectedDay: day);
  }

  void adjustWater(int deltaMl) {
    final newWater = (state.dailyLog.waterMl + deltaMl).clamp(0, 10000);
    state = state.copyWith(
      dailyLog: DailyNutritionLog(
        date: state.dailyLog.date,
        eatenMealIds: state.dailyLog.eatenMealIds,
        customFoods: state.dailyLog.customFoods,
        waterMl: newWater,
      ),
    );
  }

  void toggleMealEaten(String mealId) {
    final list = List<String>.from(state.dailyLog.eatenMealIds);
    if (list.contains(mealId)) {
      list.remove(mealId);
    } else {
      list.add(mealId);
    }
    state = state.copyWith(
      dailyLog: DailyNutritionLog(
        date: state.dailyLog.date,
        eatenMealIds: list,
        customFoods: state.dailyLog.customFoods,
        waterMl: state.dailyLog.waterMl,
      ),
    );
  }

  void addCustomFood(CustomLoggedFood food) {
    final list = List<CustomLoggedFood>.from(state.dailyLog.customFoods)..add(food);
    state = state.copyWith(
      dailyLog: DailyNutritionLog(
        date: state.dailyLog.date,
        eatenMealIds: state.dailyLog.eatenMealIds,
        customFoods: list,
        waterMl: state.dailyLog.waterMl,
      ),
    );
  }

  void regeneratePlan() {
    final filtered = DietPlanEngine.filterMeals(
      allMeals: state.meals,
      allergens: state.settings.allergies,
      dietTags: state.settings.dietTags,
      medicalFlags: state.settings.medicalFlags,
    );
    final newPlan = DietPlanEngine.assemble7DayPlan(
      eligibleMeals: filtered.isNotEmpty ? filtered : state.meals,
      settings: state.settings,
    );
    state = state.copyWith(weeklyPlan: newPlan);
  }

  void swapMeal(String day, String currentMealId) {
    final currentMeals = state.weeklyPlan[day];
    if (currentMeals == null) return;

    final currentMeal = state.meals.firstWhere((m) => m.id == currentMealId, orElse: () => currentMeals.first);
    final candidates = state.meals.where((m) => m.mealType == currentMeal.mealType && m.id != currentMealId).toList();
    if (candidates.isEmpty) return;

    final replacement = candidates.first;
    final updatedList = currentMeals.map((m) => m.id == currentMealId ? replacement : m).toList();

    final updatedPlan = Map<String, List<MealModel>>.from(state.weeklyPlan);
    updatedPlan[day] = updatedList;

    state = state.copyWith(weeklyPlan: updatedPlan);
  }
}

final nutriflowProvider = StateNotifierProvider<NutriflowNotifier, NutriflowState>((ref) {
  return NutriflowNotifier();
});
