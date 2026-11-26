import 'ingredient_model.dart';

class MealIngredientItem {
  final String ingredientId;
  final double quantity;
  final String unit;

  const MealIngredientItem({
    required this.ingredientId,
    required this.quantity,
    required this.unit,
  });

  factory MealIngredientItem.fromMap(Map<String, dynamic> map) {
    return MealIngredientItem(
      ingredientId: map['ingredientId'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? 'g',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredientId': ingredientId,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class SkinNutrientClaim {
  final String nutrient;
  final String benefitNote;

  const SkinNutrientClaim({
    required this.nutrient,
    required this.benefitNote,
  });

  factory SkinNutrientClaim.fromMap(Map<String, dynamic> map) {
    return SkinNutrientClaim(
      nutrient: map['nutrient'] as String? ?? '',
      benefitNote: map['benefitNote'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nutrient': nutrient,
      'benefitNote': benefitNote,
    };
  }
}

class MealAlternative {
  final String substituteName;
  final double savingPKR;
  final String note;

  const MealAlternative({
    required this.substituteName,
    required this.savingPKR,
    required this.note,
  });

  factory MealAlternative.fromMap(Map<String, dynamic> map) {
    return MealAlternative(
      substituteName: map['substituteName'] as String? ?? '',
      savingPKR: (map['savingPKR'] as num?)?.toDouble() ?? 0.0,
      note: map['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'substituteName': substituteName,
      'savingPKR': savingPKR,
      'note': note,
    };
  }
}

class MealModel {
  final String id;
  final String name;
  final String mealType; // breakfast | lunch | snack | dinner
  final String imageUrl;
  final List<MealIngredientItem> ingredients;
  final IngredientNutrition nutritionPerServing;
  final double estimatedCostPKR;
  final int prepTimeMinutes;
  final String difficulty;
  final List<String> recipeSteps;
  final List<String> allergens;
  final List<String> dietTags;
  final List<String> supportsGoals;
  final String whyItWorks;
  final String whyItMatters;
  final List<SkinNutrientClaim> skinNutrients;
  final String sourceNote;
  final bool verified;
  final MealAlternative? alternative;

  const MealModel({
    required this.id,
    required this.name,
    required this.mealType,
    required this.imageUrl,
    required this.ingredients,
    required this.nutritionPerServing,
    required this.estimatedCostPKR,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.recipeSteps,
    required this.allergens,
    required this.dietTags,
    required this.supportsGoals,
    required this.whyItWorks,
    required this.whyItMatters,
    required this.skinNutrients,
    this.sourceNote = 'USDA FoodData Central / Verified Staple',
    this.verified = true,
    this.alternative,
  });

  factory MealModel.fromMap(Map<String, dynamic> map, String id) {
    return MealModel(
      id: id,
      name: map['name'] as String? ?? '',
      mealType: map['mealType'] as String? ?? 'lunch',
      imageUrl: map['imageUrl'] as String? ?? '',
      ingredients: (map['ingredients'] as List? ?? [])
          .map((i) => MealIngredientItem.fromMap(i as Map<String, dynamic>))
          .toList(),
      nutritionPerServing: IngredientNutrition.fromMap(
          map['nutritionPerServing'] as Map<String, dynamic>? ?? {}),
      estimatedCostPKR: (map['estimatedCostPKR'] as num?)?.toDouble() ?? 0.0,
      prepTimeMinutes: (map['prepTimeMinutes'] as num?)?.toInt() ?? 15,
      difficulty: map['difficulty'] as String? ?? 'Easy',
      recipeSteps: List<String>.from(map['recipeSteps'] as List? ?? []),
      allergens: List<String>.from(map['allergens'] as List? ?? []),
      dietTags: List<String>.from(map['dietTags'] as List? ?? []),
      supportsGoals: List<String>.from(map['supportsGoals'] as List? ?? []),
      whyItWorks: map['whyItWorks'] as String? ?? '',
      whyItMatters: map['whyItMatters'] as String? ?? '',
      skinNutrients: (map['skinNutrients'] as List? ?? [])
          .map((s) => SkinNutrientClaim.fromMap(s as Map<String, dynamic>))
          .toList(),
      sourceNote: map['sourceNote'] as String? ?? 'USDA FoodData Central',
      verified: map['verified'] as bool? ?? true,
      alternative: map['alternative'] != null
          ? MealAlternative.fromMap(map['alternative'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mealType': mealType,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'nutritionPerServing': nutritionPerServing.toMap(),
      'estimatedCostPKR': estimatedCostPKR,
      'prepTimeMinutes': prepTimeMinutes,
      'difficulty': difficulty,
      'recipeSteps': recipeSteps,
      'allergens': allergens,
      'dietTags': dietTags,
      'supportsGoals': supportsGoals,
      'whyItWorks': whyItWorks,
      'whyItMatters': whyItMatters,
      'skinNutrients': skinNutrients.map((s) => s.toMap()).toList(),
      'sourceNote': sourceNote,
      'verified': verified,
      if (alternative != null) 'alternative': alternative!.toMap(),
    };
  }
}
