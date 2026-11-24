class RoutineStep {
  final int stepNumber;
  final String title;
  final String category; // 'cleanser' | 'treatment' | 'moisturizer' | 'sunscreen' | 'exfoliant' | 'mask'
  final String keyIngredient;
  final String howToApply;
  final String frequency; // e.g. 'Daily AM', 'Daily PM', '2x per week'
  final String avoidWith;
  final bool isCompleted;

  RoutineStep({
    required this.stepNumber,
    required this.title,
    required this.category,
    required this.keyIngredient,
    required this.howToApply,
    required this.frequency,
    this.avoidWith = '',
    this.isCompleted = false,
  });

  RoutineStep copyWith({bool? isCompleted}) {
    return RoutineStep(
      stepNumber: stepNumber,
      title: title,
      category: category,
      keyIngredient: keyIngredient,
      howToApply: howToApply,
      frequency: frequency,
      avoidWith: avoidWith,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'stepNumber': stepNumber,
    'title': title,
    'category': category,
    'keyIngredient': keyIngredient,
    'howToApply': howToApply,
    'frequency': frequency,
    'avoidWith': avoidWith,
    'isCompleted': isCompleted,
  };

  factory RoutineStep.fromJson(Map<String, dynamic> json) => RoutineStep(
    stepNumber: json['stepNumber'] ?? 1,
    title: json['title'] ?? '',
    category: json['category'] ?? 'cleanser',
    keyIngredient: json['keyIngredient'] ?? '',
    howToApply: json['howToApply'] ?? '',
    frequency: json['frequency'] ?? 'Daily',
    avoidWith: json['avoidWith'] ?? '',
    isCompleted: json['isCompleted'] ?? false,
  );
}

class NutritionItem {
  final String category; // 'eat_more' | 'limit' | 'supplement'
  final String title;
  final String reason;
  final String icon;

  NutritionItem({
    required this.category,
    required this.title,
    required this.reason,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'title': title,
    'reason': reason,
    'icon': icon,
  };

  factory NutritionItem.fromJson(Map<String, dynamic> json) => NutritionItem(
    category: json['category'] ?? 'eat_more',
    title: json['title'] ?? '',
    reason: json['reason'] ?? '',
    icon: json['icon'] ?? 'leaf',
  );
}

class MealPlanDay {
  final String breakfast;
  final String lunch;
  final String dinner;
  final String snack;

  MealPlanDay({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });

  Map<String, dynamic> toJson() => {
    'breakfast': breakfast,
    'lunch': lunch,
    'dinner': dinner,
    'snack': snack,
  };

  factory MealPlanDay.fromJson(Map<String, dynamic> json) => MealPlanDay(
    breakfast: json['breakfast'] ?? '',
    lunch: json['lunch'] ?? '',
    dinner: json['dinner'] ?? '',
    snack: json['snack'] ?? '',
  );
}

class TimelineWeek {
  final int weekNumber;
  final String title;
  final String focusPriority;
  final String milestoneGoal;
  final List<String> actionItems;

  TimelineWeek({
    required this.weekNumber,
    required this.title,
    required this.focusPriority,
    required this.milestoneGoal,
    required this.actionItems,
  });

  Map<String, dynamic> toJson() => {
    'weekNumber': weekNumber,
    'title': title,
    'focusPriority': focusPriority,
    'milestoneGoal': milestoneGoal,
    'actionItems': actionItems,
  };

  factory TimelineWeek.fromJson(Map<String, dynamic> json) => TimelineWeek(
    weekNumber: json['weekNumber'] ?? 1,
    title: json['title'] ?? '',
    focusPriority: json['focusPriority'] ?? '',
    milestoneGoal: json['milestoneGoal'] ?? '',
    actionItems: (json['actionItems'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
  );
}

class GlowPlan {
  final List<RoutineStep> morningRoutine;
  final List<RoutineStep> eveningRoutine;
  final List<RoutineStep> weeklyAddOns;
  final List<NutritionItem> nutritionItems;
  final MealPlanDay sampleMealPlan;
  final double hydrationGoalLiters;
  final List<String> lifestyleTips;
  final List<TimelineWeek> fourWeekTimeline;
  final int streakDays;

  GlowPlan({
    required this.morningRoutine,
    required this.eveningRoutine,
    required this.weeklyAddOns,
    required this.nutritionItems,
    required this.sampleMealPlan,
    required this.hydrationGoalLiters,
    required this.lifestyleTips,
    required this.fourWeekTimeline,
    this.streakDays = 1,
  });

  Map<String, dynamic> toJson() => {
    'morningRoutine': morningRoutine.map((s) => s.toJson()).toList(),
    'eveningRoutine': eveningRoutine.map((s) => s.toJson()).toList(),
    'weeklyAddOns': weeklyAddOns.map((s) => s.toJson()).toList(),
    'nutritionItems': nutritionItems.map((n) => n.toJson()).toList(),
    'sampleMealPlan': sampleMealPlan.toJson(),
    'hydrationGoalLiters': hydrationGoalLiters,
    'lifestyleTips': lifestyleTips,
    'fourWeekTimeline': fourWeekTimeline.map((w) => w.toJson()).toList(),
    'streakDays': streakDays,
  };

  factory GlowPlan.fromJson(Map<String, dynamic> json) => GlowPlan(
    morningRoutine: (json['morningRoutine'] as List<dynamic>?)
            ?.map((e) => RoutineStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    eveningRoutine: (json['eveningRoutine'] as List<dynamic>?)
            ?.map((e) => RoutineStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    weeklyAddOns: (json['weeklyAddOns'] as List<dynamic>?)
            ?.map((e) => RoutineStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    nutritionItems: (json['nutritionItems'] as List<dynamic>?)
            ?.map((e) => NutritionItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    sampleMealPlan: MealPlanDay.fromJson(json['sampleMealPlan'] ?? {}),
    hydrationGoalLiters: (json['hydrationGoalLiters'] as num?)?.toDouble() ?? 2.5,
    lifestyleTips: (json['lifestyleTips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    fourWeekTimeline: (json['fourWeekTimeline'] as List<dynamic>?)
            ?.map((e) => TimelineWeek.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    streakDays: json['streakDays'] ?? 1,
  );
}
