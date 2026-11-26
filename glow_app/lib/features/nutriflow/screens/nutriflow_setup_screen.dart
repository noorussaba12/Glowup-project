import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/glow_card.dart';
import '../../../shared/widgets/glow_button.dart';
import '../providers/nutriflow_provider.dart';
import '../models/nutriflow_settings_model.dart';

class NutriflowSetupScreen extends ConsumerStatefulWidget {
  const NutriflowSetupScreen({super.key});

  @override
  ConsumerState<NutriflowSetupScreen> createState() => _NutriflowSetupScreenState();
}

class _NutriflowSetupScreenState extends ConsumerState<NutriflowSetupScreen> {
  int _currentStep = 1;

  // Form state
  String _breakfastTime = '08:00';
  String _lunchTime = '13:30';
  String _snackTime = '16:30';
  String _dinnerTime = '20:00';
  int _waterIntervalHours = 2;
  bool _notificationsEnabled = true;

  final Set<String> _selectedAllergens = {};
  final Set<String> _selectedDietTags = {'halal'};
  final TextEditingController _customExclusionsCtrl = TextEditingController();

  double _dailyBudgetPKR = 800.0;
  final List<String> _pantryItems = ['Eggs', 'Moong Daal', 'Fresh Dahi'];
  final TextEditingController _pantryInputCtrl = TextEditingController();

  final Set<String> _selectedGoals = {'high_fiber', 'low_sodium', 'hydration'};
  bool _includeSkinGoal = true;

  int _age = 26;
  String _sex = 'female';
  double _heightCm = 165.0;
  double _weightKg = 58.0;
  final Set<String> _medicalFlags = {};

  @override
  void dispose() {
    _customExclusionsCtrl.dispose();
    _pantryInputCtrl.dispose();
    super.dispose();
  }

  void _finishSetup() {
    final settings = NutriflowSettingsModel(
      reminders: MealRemindersSettings(
        breakfast: _breakfastTime,
        lunch: _lunchTime,
        snack: _snackTime,
        dinner: _dinnerTime,
        waterIntervalHours: _waterIntervalHours,
        notificationsEnabled: _notificationsEnabled,
      ),
      allergies: _selectedAllergens.toList(),
      dietTags: _selectedDietTags.toList(),
      customExclusions: _customExclusionsCtrl.text.trim(),
      dailyBudgetPKR: _dailyBudgetPKR,
      homeFoods: _pantryItems,
      goals: _selectedGoals.toList(),
      skinGoal: _includeSkinGoal ? 'hydration' : '',
      basics: UserPhysicalBasics(
        age: _age,
        sex: _sex,
        heightCm: _heightCm,
        weightKg: _weightKg,
      ),
      medicalFlags: _medicalFlags.toList(),
      hideCalories: _age < 18,
      setupCompleted: true,
    );

    ref.read(nutriflowProvider.notifier).updateSettings(settings);
    context.go('/nutriflow');
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.bg,
      appBar: AppBar(
        backgroundColor: palette.bg,
        elevation: 0,
        title: Text(
          'Nutriflow Setup',
          style: TextStyle(color: palette.primaryDark, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Step $_currentStep/6',
                style: TextStyle(color: palette.accent, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Linear progress bar
          LinearProgressIndicator(
            value: _currentStep / 6.0,
            backgroundColor: palette.border,
            valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
            minHeight: 3,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assistant Speech Bubble
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: palette.accent.withOpacity(0.15),
                          radius: 16,
                          child: Icon(Icons.spa, size: 16, color: palette.accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getStepSpeech(),
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.primaryDark,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Step Content
                  if (_currentStep == 1) _buildStep1Reminders(palette),
                  if (_currentStep == 2) _buildStep2Allergies(palette),
                  if (_currentStep == 3) _buildStep3Budget(palette),
                  if (_currentStep == 4) _buildStep4Goals(palette),
                  if (_currentStep == 5) _buildStep5Basics(palette),
                  if (_currentStep == 6) _buildStep6Confirmation(palette),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepSpeech() {
    switch (_currentStep) {
      case 1:
        return "Let's align your daily meal timings and optional hydration alerts.";
      case 2:
        return "Select any food allergies, intolerances, or religious diet tags you follow.";
      case 3:
        return "Set your daily grocery budget in PKR, or list ingredients available at home.";
      case 4:
        return "Choose nutrition targets. We've automatically linked a goal from your skin scan!";
      case 5:
        return "Basic metrics to enforce clinical minimum caloric floors and medical flags.";
      case 6:
        return "Review your personalized parameters before we compile your 7-day meal plan.";
      default:
        return "Let's configure your Nutriflow personalized diet plan.";
    }
  }

  Widget _buildStep1Reminders(palette) {
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Meal Timings & Reminders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 14),
          _timeRow('Breakfast', _breakfastTime, (val) => setState(() => _breakfastTime = val)),
          _timeRow('Lunch', _lunchTime, (val) => setState(() => _lunchTime = val)),
          _timeRow('Afternoon Snack', _snackTime, (val) => setState(() => _snackTime = val)),
          _timeRow('Dinner', _dinnerTime, (val) => setState(() => _dinnerTime = val)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Water Reminder Interval', style: TextStyle(fontSize: 13)),
              DropdownButton<int>(
                value: _waterIntervalHours,
                items: const [
                  DropdownMenuItem(value: 2, child: Text('Every 2 hours')),
                  DropdownMenuItem(value: 3, child: Text('Every 3 hours')),
                  DropdownMenuItem(value: 0, child: Text('Off')),
                ],
                onChanged: (val) => setState(() => _waterIntervalHours = val ?? 2),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable Device Notifications', style: TextStyle(fontSize: 13)),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          const SizedBox(height: 14),
          GlowButton(
            text: 'Continue to Allergies',
            onPressed: () => setState(() => _currentStep = 2),
          ),
        ],
      ),
    );
  }

  Widget _timeRow(String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Allergies(palette) {
    final allergens = ['peanuts', 'tree_nuts', 'dairy', 'eggs', 'gluten', 'soy', 'fish', 'shellfish', 'sesame'];
    final diets = ['halal', 'vegetarian', 'vegan', 'no_beef'];

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('2. Food Allergies & Exclusions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          const Text('Common Allergens:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergens.map((a) {
              final isSel = _selectedAllergens.contains(a);
              return FilterChip(
                label: Text(a.replaceAll('_', ' ')),
                selected: isSel,
                onSelected: (val) {
                  setState(() {
                    if (val) _selectedAllergens.add(a);
                    else _selectedAllergens.remove(a);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Dietary Preferences:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: diets.map((d) {
              final isSel = _selectedDietTags.contains(d);
              return FilterChip(
                label: Text(d.replaceAll('_', ' ')),
                selected: isSel,
                onSelected: (val) {
                  setState(() {
                    if (val) _selectedDietTags.add(d);
                    else _selectedDietTags.remove(d);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  text: 'Back',
                  isSecondary: true,
                  onPressed: () => setState(() => _currentStep = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlowButton(
                  text: 'Continue',
                  onPressed: () => setState(() => _currentStep = 3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Budget(palette) {
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3. Daily Budget in PKR & Food at Home', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          const Text('Daily Grocery Budget (PKR):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [400.0, 800.0, 1200.0, 1800.0].map((amt) {
              final isSel = _dailyBudgetPKR == amt;
              return ChoiceChip(
                label: Text('₨ ${amt.round()}'),
                selected: isSel,
                onSelected: (_) => setState(() => _dailyBudgetPKR = amt),
              );
            }).toList(),
          ),
          const Divider(height: 28),
          const Text('Pantry Foods at Home (Optional):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pantryInputCtrl,
                  decoration: const InputDecoration(
                    hintText: 'e.g. daal, eggs, dahi, cucumber',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFFC58B7D)),
                onPressed: () {
                  if (_pantryInputCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _pantryItems.add(_pantryInputCtrl.text.trim());
                      _pantryInputCtrl.clear();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: _pantryItems.map((item) => Chip(
              label: Text(item, style: const TextStyle(fontSize: 11)),
              onDeleted: () => setState(() => _pantryItems.remove(item)),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  text: 'Back',
                  isSecondary: true,
                  onPressed: () => setState(() => _currentStep = 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlowButton(
                  text: 'Continue',
                  onPressed: () => setState(() => _currentStep = 4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Goals(palette) {
    final goals = ['high_fiber', 'low_sodium', 'hydration', 'high_protein', 'lower_carbs', 'less_added_sugar'];

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('4. Nutrition Goals', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goals.map((g) {
              final isSel = _selectedGoals.contains(g);
              return FilterChip(
                label: Text(g.replaceAll('_', ' ')),
                selected: isSel,
                onSelected: (val) {
                  setState(() {
                    if (val) _selectedGoals.add(g);
                    else _selectedGoals.remove(g);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Suggested Skin Goal
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4E8E4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC58B7D).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFFC58B7D), size: 16),
                    SizedBox(width: 6),
                    Text('Suggested from Skin Scan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFFC58B7D))),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('💧 Hydration & Barrier Moisture Support', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                const Text('Elevated epidermal dehydration detected. Emphasizes water-retaining electrolytes.', style: TextStyle(fontSize: 11)),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Include in Meal Assembly', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  value: _includeSkinGoal,
                  onChanged: (val) => setState(() => _includeSkinGoal = val ?? true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  text: 'Back',
                  isSecondary: true,
                  onPressed: () => setState(() => _currentStep = 3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlowButton(
                  text: 'Continue',
                  onPressed: () => setState(() => _currentStep = 5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Basics(palette) {
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('5. Health Basics & Safety', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    TextFormField(
                      initialValue: _age.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _age = int.tryParse(v) ?? 26,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sex', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _sex,
                      items: const [
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                      ],
                      onChanged: (v) => setState(() => _sex = v ?? 'female'),
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Medical Flags (Clinical safety checks):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 6),
          ...['diabetes', 'hypertension', 'pcos', 'kidney', 'pregnancy', 'ed_history'].map((flag) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(flag.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 12)),
              value: _medicalFlags.contains(flag),
              onChanged: (val) {
                setState(() {
                  if (val == true) _medicalFlags.add(flag);
                  else _medicalFlags.remove(flag);
                });
              },
            );
          }),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  text: 'Back',
                  isSecondary: true,
                  onPressed: () => setState(() => _currentStep = 4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlowButton(
                  text: 'Review',
                  onPressed: () => setState(() => _currentStep = 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep6Confirmation(palette) {
    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('6. Confirmation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 14),
          _summaryRow('Plan Duration', '7 Days (Mon - Sun)'),
          _summaryRow('Daily Grocery Budget', '₨ ${_dailyBudgetPKR.round()} PKR'),
          _summaryRow('Meals per Day', '4 (B / L / S / D)'),
          _summaryRow('Safe Caloric Target', _age < 18 ? 'Uncounted (Under 18)' : '1,650 kcal (Safe Floor)'),
          _summaryRow('Allergies Excluded', _selectedAllergens.isEmpty ? 'None' : _selectedAllergens.join(', ')),
          const SizedBox(height: 20),
          GlowButton(
            text: 'Generate My 7-Day Plan ✨',
            onPressed: _finishSetup,
          ),
          const SizedBox(height: 10),
          GlowButton(
            text: 'Back',
            isSecondary: true,
            onPressed: () => setState(() => _currentStep = 5),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
