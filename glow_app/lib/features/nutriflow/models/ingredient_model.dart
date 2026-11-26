class IngredientNutrition {
  final double calories;
  final double protein;
  final double carbs;
  final double fiber;
  final double sugar;
  final double fat;
  final double sodium;

  const IngredientNutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fiber,
    required this.sugar,
    required this.fat,
    required this.sodium,
  });

  factory IngredientNutrition.fromMap(Map<String, dynamic> map) {
    return IngredientNutrition(
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      sodium: (map['sodium'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fiber': fiber,
      'sugar': sugar,
      'fat': fat,
      'sodium': sodium,
    };
  }
}

class IngredientModel {
  final String id;
  final String name;
  final String category;
  final double pricePerUnitPKR;
  final String priceUpdatedAt;
  final IngredientNutrition per100g;
  final List<String> allergens;
  final List<String> dietTags;
  final List<String> roleTags;
  final List<String> alternatives;
  final bool verified;

  const IngredientModel({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerUnitPKR,
    required this.priceUpdatedAt,
    required this.per100g,
    required this.allergens,
    required this.dietTags,
    required this.roleTags,
    this.alternatives = const [],
    this.verified = true,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map, String id) {
    return IngredientModel(
      id: id,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'Staple',
      pricePerUnitPKR: (map['pricePerUnitPKR'] as num?)?.toDouble() ?? 0.0,
      priceUpdatedAt: map['priceUpdatedAt'] as String? ?? '',
      per100g: IngredientNutrition.fromMap(map['per100g'] as Map<String, dynamic>? ?? {}),
      allergens: List<String>.from(map['allergens'] as List? ?? []),
      dietTags: List<String>.from(map['dietTags'] as List? ?? []),
      roleTags: List<String>.from(map['roleTags'] as List? ?? []),
      alternatives: List<String>.from(map['alternatives'] as List? ?? []),
      verified: map['verified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'pricePerUnitPKR': pricePerUnitPKR,
      'priceUpdatedAt': priceUpdatedAt,
      'per100g': per100g.toMap(),
      'allergens': allergens,
      'dietTags': dietTags,
      'roleTags': roleTags,
      'alternatives': alternatives,
      'verified': verified,
    };
  }
}
