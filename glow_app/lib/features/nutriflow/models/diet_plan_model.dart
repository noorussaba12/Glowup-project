class PlanMealSlot {
  final String mealId;
  final String slotType; // 'breakfast' | 'lunch' | 'snack' | 'dinner'
  final String scheduledTime;

  const PlanMealSlot({
    required this.mealId,
    required this.slotType,
    required this.scheduledTime,
  });

  factory PlanMealSlot.fromMap(Map<String, dynamic> map) {
    return PlanMealSlot(
      mealId: map['mealId'] as String? ?? '',
      slotType: map['slotType'] as String? ?? 'lunch',
      scheduledTime: map['scheduledTime'] as String? ?? '13:30',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mealId': mealId,
      'slotType': slotType,
      'scheduledTime': scheduledTime,
    };
  }
}

class PlanDaySchedule {
  final String dayOfWeek; // 'Mon'..'Sun'
  final String date;
  final List<PlanMealSlot> meals;
  final double estimatedCostPKR;
  final double totalCalories;

  const PlanDaySchedule({
    required this.dayOfWeek,
    required this.date,
    required this.meals,
    required this.estimatedCostPKR,
    required this.totalCalories,
  });

  factory PlanDaySchedule.fromMap(Map<String, dynamic> map) {
    return PlanDaySchedule(
      dayOfWeek: map['dayOfWeek'] as String? ?? 'Mon',
      date: map['date'] as String? ?? '',
      meals: (map['meals'] as List? ?? [])
          .map((m) => PlanMealSlot.fromMap(m as Map<String, dynamic>))
          .toList(),
      estimatedCostPKR: (map['estimatedCostPKR'] as num?)?.toDouble() ?? 0.0,
      totalCalories: (map['totalCalories'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'date': date,
      'meals': meals.map((m) => m.toMap()).toList(),
      'estimatedCostPKR': estimatedCostPKR,
      'totalCalories': totalCalories,
    };
  }
}

class CustomLoggedFood {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double costPKR;

  const CustomLoggedFood({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.costPKR,
  });

  factory CustomLoggedFood.fromMap(Map<String, dynamic> map) {
    return CustomLoggedFood(
      name: map['name'] as String? ?? '',
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      costPKR: (map['costPKR'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'costPKR': costPKR,
    };
  }
}

class DailyNutritionLog {
  final String date;
  final List<String> eatenMealIds;
  final List<CustomLoggedFood> customFoods;
  final int waterMl;

  const DailyNutritionLog({
    required this.date,
    this.eatenMealIds = const [],
    this.customFoods = const [],
    this.waterMl = 1750,
  });

  factory DailyNutritionLog.fromMap(Map<String, dynamic> map, String date) {
    return DailyNutritionLog(
      date: date,
      eatenMealIds: List<String>.from(map['eatenMealIds'] as List? ?? []),
      customFoods: (map['customFoods'] as List? ?? [])
          .map((f) => CustomLoggedFood.fromMap(f as Map<String, dynamic>))
          .toList(),
      waterMl: (map['waterMl'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eatenMealIds': eatenMealIds,
      'customFoods': customFoods.map((f) => f.toMap()).toList(),
      'waterMl': waterMl,
    };
  }
}
