class MealRemindersSettings {
  final String breakfast;
  final String lunch;
  final String snack;
  final String dinner;
  final int waterIntervalHours;
  final bool notificationsEnabled;

  const MealRemindersSettings({
    this.breakfast = '08:00',
    this.lunch = '13:30',
    this.snack = '16:30',
    this.dinner = '20:00',
    this.waterIntervalHours = 2,
    this.notificationsEnabled = true,
  });

  factory MealRemindersSettings.fromMap(Map<String, dynamic> map) {
    return MealRemindersSettings(
      breakfast: map['breakfast'] as String? ?? '08:00',
      lunch: map['lunch'] as String? ?? '13:30',
      snack: map['snack'] as String? ?? '16:30',
      dinner: map['dinner'] as String? ?? '20:00',
      waterIntervalHours: (map['waterIntervalHours'] as num?)?.toInt() ?? 2,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'snack': snack,
      'dinner': dinner,
      'waterIntervalHours': waterIntervalHours,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}

class UserPhysicalBasics {
  final int age;
  final String sex; // 'female' | 'male'
  final double heightCm;
  final double weightKg;
  final String activityLevel; // 'sedentary' | 'moderate' | 'active'

  const UserPhysicalBasics({
    this.age = 26,
    this.sex = 'female',
    this.heightCm = 165.0,
    this.weightKg = 58.0,
    this.activityLevel = 'moderate',
  });

  factory UserPhysicalBasics.fromMap(Map<String, dynamic> map) {
    return UserPhysicalBasics(
      age: (map['age'] as num?)?.toInt() ?? 26,
      sex: map['sex'] as String? ?? 'female',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 165.0,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 58.0,
      activityLevel: map['activityLevel'] as String? ?? 'moderate',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'sex': sex,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
    };
  }
}

class NutriflowSettingsModel {
  final MealRemindersSettings reminders;
  final List<String> allergies;
  final List<String> dietTags;
  final String customExclusions;
  final double dailyBudgetPKR;
  final List<String> homeFoods;
  final List<String> goals;
  final String skinGoal;
  final UserPhysicalBasics basics;
  final List<String> medicalFlags;
  final bool hideCalories;
  final bool setupCompleted;

  const NutriflowSettingsModel({
    this.reminders = const MealRemindersSettings(),
    this.allergies = const [],
    this.dietTags = const ['halal'],
    this.customExclusions = '',
    this.dailyBudgetPKR = 800.0,
    this.homeFoods = const ['Eggs', 'Moong Daal', 'Fresh Dahi'],
    this.goals = const ['high_fiber', 'low_sodium', 'hydration'],
    this.skinGoal = 'hydration',
    this.basics = const UserPhysicalBasics(),
    this.medicalFlags = const [],
    this.hideCalories = false,
    this.setupCompleted = true,
  });

  factory NutriflowSettingsModel.fromMap(Map<String, dynamic> map) {
    return NutriflowSettingsModel(
      reminders: MealRemindersSettings.fromMap(map['reminders'] as Map<String, dynamic>? ?? {}),
      allergies: List<String>.from(map['allergies'] as List? ?? []),
      dietTags: List<String>.from(map['dietTags'] as List? ?? ['halal']),
      customExclusions: map['customExclusions'] as String? ?? '',
      dailyBudgetPKR: (map['dailyBudgetPKR'] as num?)?.toDouble() ?? 800.0,
      homeFoods: List<String>.from(map['homeFoods'] as List? ?? []),
      goals: List<String>.from(map['goals'] as List? ?? []),
      skinGoal: map['skinGoal'] as String? ?? 'hydration',
      basics: UserPhysicalBasics.fromMap(map['basics'] as Map<String, dynamic>? ?? {}),
      medicalFlags: List<String>.from(map['medicalFlags'] as List? ?? []),
      hideCalories: map['hideCalories'] as bool? ?? false,
      setupCompleted: map['setupCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reminders': reminders.toMap(),
      'allergies': allergies,
      'dietTags': dietTags,
      'customExclusions': customExclusions,
      'dailyBudgetPKR': dailyBudgetPKR,
      'homeFoods': homeFoods,
      'goals': goals,
      'skinGoal': skinGoal,
      'basics': basics.toMap(),
      'medicalFlags': medicalFlags,
      'hideCalories': hideCalories,
      'setupCompleted': setupCompleted,
    };
  }
}
