import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/models/plan_model.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_segmented_tab.dart';
import '../../shared/widgets/glow_bottom_nav.dart';

class MyPlanScreen extends ConsumerStatefulWidget {
  final GlowPlan? plan;

  const MyPlanScreen({super.key, this.plan});

  @override
  ConsumerState<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends ConsumerState<MyPlanScreen> {
  int _selectedTab = 0; // 0: Skincare, 1: Nutrition, 2: Lifestyle, 3: Timeline, 4: Checklist
  late GlowPlan _currentPlan;
  int _streakCount = 3;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan ?? _buildDefaultPlan();
  }

  GlowPlan _buildDefaultPlan() {
    return GlowPlan(
      morningRoutine: [
        RoutineStep(
          stepNumber: 1,
          title: 'Gentle Hydrating Cleanser',
          category: 'cleanser',
          keyIngredient: 'Glycerin & Ceramides (pH 5.5)',
          howToApply: 'Massage over damp face for 45 seconds, rinse with lukewarm water.',
          frequency: 'Daily AM',
        ),
        RoutineStep(
          stepNumber: 2,
          title: 'Antioxidant Barrier Serum',
          category: 'treatment',
          keyIngredient: '5% Niacinamide + Multi-weight Hyaluronic Acid',
          howToApply: 'Pat 3 drops into damp skin before moisturizer.',
          frequency: 'Daily AM',
        ),
        RoutineStep(
          stepNumber: 3,
          title: 'Restorative Gel-Cream',
          category: 'moisturizer',
          keyIngredient: 'Centella Asiatica + Squalane',
          howToApply: 'Smooth gently over face and neck to seal moisture.',
          frequency: 'Daily AM',
        ),
        RoutineStep(
          stepNumber: 4,
          title: 'Broad Spectrum SPF 50+ PA++++',
          category: 'sunscreen',
          keyIngredient: 'Non-nano Zinc Oxide & Mexoryl UV Filters',
          howToApply: 'Apply two full finger-lengths evenly 15 mins before daylight.',
          frequency: 'Daily AM',
        ),
      ],
      eveningRoutine: [
        RoutineStep(
          stepNumber: 1,
          title: 'Oil-to-Milk First Cleanse',
          category: 'cleanser',
          keyIngredient: 'Jojoba Oil & Oat Lipids',
          howToApply: 'Massage over dry skin to dissolve pollutants, emulsify and rinse.',
          frequency: 'Daily PM',
        ),
        RoutineStep(
          stepNumber: 2,
          title: 'Cellular Turnover Treatment',
          category: 'treatment',
          keyIngredient: '0.05% Encapsulated Retinal or Copper Tripeptide-1',
          howToApply: 'Apply pea-sized amount onto completely dry skin. Start 2 nights/wk.',
          frequency: '2-3x weekly PM',
          avoidWith: 'Do not combine with chemical peels or AHA/BHA exfoliants on same night.',
        ),
        RoutineStep(
          stepNumber: 3,
          title: 'Deep Overnight Barrier Cream',
          category: 'moisturizer',
          keyIngredient: 'Panthenol (Pro-Vitamin B5) & Shea Butter',
          howToApply: 'Warm between palms and press into skin to prevent moisture loss.',
          frequency: 'Daily PM',
        ),
      ],
      weeklyAddOns: [
        RoutineStep(
          stepNumber: 1,
          title: 'Gentle PHA Enzyme Glow Mask',
          category: 'mask',
          keyIngredient: 'Gluconolactone & Papaya Enzymes',
          howToApply: 'Leave on for 10 minutes on Sunday evening, rinse thoroughly.',
          frequency: '1x weekly (Sunday)',
        ),
      ],
      nutritionItems: [
        NutritionItem(
          category: 'eat_more',
          title: 'Wild Omega-3s (Salmon / Chia / Flax)',
          reason: 'Calms inflammatory pathways and strengthens cellular membranes.',
          icon: 'water_drop',
        ),
        NutritionItem(
          category: 'eat_more',
          title: 'Antioxidant Dark Berries',
          reason: 'Combats oxidative stress from ambient pollution and sun exposure.',
          icon: 'apple',
        ),
        NutritionItem(
          category: 'limit',
          title: 'Refined Added Sugars & High Glycemic Snacks',
          reason: 'Accelerates collagen glycation, exacerbates breakouts, and dulls texture.',
          icon: 'warning',
        ),
        NutritionItem(
          category: 'supplement',
          title: 'Zinc Picolinate (15mg) & Vitamin D3',
          reason: 'Essential for skin epithelial healing. (Verify with your doctor).',
          icon: 'medication',
        ),
      ],
      sampleMealPlan: MealPlanDay(
        breakfast: 'Steel-cut oats with chia seeds, wild blueberries, and green tea.',
        lunch: 'Grilled salmon (or spiced tofu) bowl with quinoa, avocado, and steamed broccoli.',
        dinner: 'Warm turmeric lentil stew with roasted sweet potatoes and olive oil spinach salad.',
        snack: 'Handful of raw walnuts + hydration electrolytes.',
      ),
      hydrationGoalLiters: 2.7,
      lifestyleTips: [
        'Swap pillowcases twice per week to prevent overnight micro-bacterial contact.',
        'Apply blue-light screen tint 1 hour before bedtime for deeper REM cellular repair.',
        'Avoid scalding hot showers on the face to maintain skin lipid barrier.',
      ],
      fourWeekTimeline: [
        TimelineWeek(
          weekNumber: 1,
          title: 'Hydration Reset & Barrier Repair',
          focusPriority: 'Priority 1: Deep Hydration',
          milestoneGoal: 'Rebalance surface moisture and eliminate tightness or stinging.',
          actionItems: [
            'Establish morning and night hydrating regimen',
            'Drink 2.7 Liters of water daily',
            'Zero harsh physical exfoliants',
          ],
        ),
        TimelineWeek(
          weekNumber: 2,
          title: 'Active Introduction & Micro-Circulation',
          focusPriority: 'Priority 2: Pores & Sebum',
          milestoneGoal: 'Introduce active night serum 2 nights/week without irritation.',
          actionItems: [
            'Patch test serum behind ear before full facial application',
            'Strict daily SPF 50 application',
          ],
        ),
        TimelineWeek(
          weekNumber: 3,
          title: 'Periorbital Brightening & Radiance',
          focusPriority: 'Priority 3: Dark Circles',
          milestoneGoal: 'Lighten under-eye shadow density and achieve all-day dewiness.',
          actionItems: [
            'Introduce Sunday gentle PHA enzyme mask',
            'Incorporate antioxidant-dense meal plan daily',
          ],
        ),
        TimelineWeek(
          weekNumber: 4,
          title: 'Progress Scan & Habit Consolidation',
          focusPriority: 'Progress Verification',
          milestoneGoal: 'Retake face scan to measure skin score improvement.',
          actionItems: [
            'Perform secondary face scan under daylight',
            'Compare side-by-side progression metrics in History',
          ],
        ),
      ],
      streakDays: 3,
    );
  }

  void _toggleStep(int index, bool isMorning) {
    setState(() {
      if (isMorning) {
        final step = _currentPlan.morningRoutine[index];
        _currentPlan.morningRoutine[index] = step.copyWith(isCompleted: !step.isCompleted);
      } else {
        final step = _currentPlan.eveningRoutine[index];
        _currentPlan.eveningRoutine[index] = step.copyWith(isCompleted: !step.isCompleted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('My Personalized Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Streak Counter Chip
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: palette.accentLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$_streakCount Day Streak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: palette.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Tabs matching Pinterest reference style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GlowSegmentedTabs(
                isScrollable: true,
                tabs: const ['Skincare', 'Nutrition', 'Lifestyle', '4-Week Timeline', 'Daily Checklist'],
                selectedIndex: _selectedTab,
                onTabSelected: (i) => setState(() => _selectedTab = i),
              ),
            ),

            // Tab Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: _buildSelectedTabContent(palette),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GlowBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.push('/instructions');
          if (index == 2) {}
          if (index == 3) context.push('/nutriflow');
          if (index == 4) context.push('/profile');
        },
      ),
    );
  }

  Widget _buildSelectedTabContent(GlowPalette palette) {
    switch (_selectedTab) {
      case 0:
        return _buildSkincareTab(palette);
      case 1:
        return _buildNutritionTab(palette);
      case 2:
        return _buildLifestyleTab(palette);
      case 3:
        return _buildTimelineTab(palette);
      case 4:
        return _buildChecklistTab(palette);
      default:
        return _buildSkincareTab(palette);
    }
  }

  // 1. Skincare Routine Tab
  Widget _buildSkincareTab(GlowPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Morning Routine Header
        _buildSectionHeader('Morning Routine (AM)', Icons.wb_sunny_outlined, palette),
        const SizedBox(height: 12),
        ..._currentPlan.morningRoutine.map((step) => _buildRoutineStepCard(step, palette)),
        const SizedBox(height: 24),

        // Night Routine Header
        _buildSectionHeader('Night Routine (PM)', Icons.nights_stay_outlined, palette),
        const SizedBox(height: 12),
        ..._currentPlan.eveningRoutine.map((step) => _buildRoutineStepCard(step, palette)),
        const SizedBox(height: 24),

        // Weekly Add-ons
        _buildSectionHeader('Weekly Treatments & Add-ons', Icons.auto_awesome_outlined, palette),
        const SizedBox(height: 12),
        ..._currentPlan.weeklyAddOns.map((step) => _buildRoutineStepCard(step, palette)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRoutineStepCard(RoutineStep step, GlowPalette palette) {
    return GlowCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: palette.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: palette.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.primaryDark,
                      ),
                    ),
                    Text(
                      step.frequency,
                      style: TextStyle(fontSize: 11, color: palette.accent, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: palette.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.science_outlined, size: 16, color: palette.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Key Active: ${step.keyIngredient}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How: ${step.howToApply}',
            style: TextStyle(fontSize: 12, color: palette.secondaryText, height: 1.35),
          ),
          if (step.avoidWith.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '⚠️ Avoid: ${step.avoidWith}',
              style: TextStyle(fontSize: 11, color: palette.error, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  // 2. Nutrition Routine Tab
  Widget _buildNutritionTab(GlowPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hydration Card
        GlowCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: palette.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(Icons.water_drop_rounded, size: 28, color: palette.accent)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hydration Target: ${_currentPlan.hydrationGoalLiters} L / day',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: palette.primaryDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Maintain cellular turgor and lymphatic drainage under eyes.',
                      style: TextStyle(fontSize: 12, color: palette.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader('Foods to Eat & Supplements', Icons.restaurant_outlined, palette),
        const SizedBox(height: 12),
        ..._currentPlan.nutritionItems.map((item) {
          final isWarning = item.category == 'limit';
          return GlowCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isWarning ? Icons.remove_circle_outline : Icons.check_circle_outline,
                  color: isWarning ? palette.warning : palette.success,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.primaryDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.reason,
                        style: TextStyle(fontSize: 12, color: palette.secondaryText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        // 1-Day Sample Meal Plan Card
        _buildSectionHeader('1-Day Sample Meal Plan', Icons.calendar_month_outlined, palette),
        const SizedBox(height: 12),
        GlowCard(
          child: Column(
            children: [
              _buildMealRow('Breakfast', _currentPlan.sampleMealPlan.breakfast, palette),
              const Divider(),
              _buildMealRow('Lunch', _currentPlan.sampleMealPlan.lunch, palette),
              const Divider(),
              _buildMealRow('Dinner', _currentPlan.sampleMealPlan.dinner, palette),
              const Divider(),
              _buildMealRow('Snack', _currentPlan.sampleMealPlan.snack, palette),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMealRow(String meal, String desc, GlowPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              meal,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.accent),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(fontSize: 12, color: palette.primaryText, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Lifestyle Tab
  Widget _buildLifestyleTab(GlowPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Daily Habits & Environment', Icons.wb_twilight_outlined, palette),
        const SizedBox(height: 14),
        ..._currentPlan.lifestyleTips.map((tip) {
          return GlowCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.bedtime_outlined, color: palette.accent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(fontSize: 13, color: palette.primaryText, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 4. 4-Week Timeline Tab
  Widget _buildTimelineTab(GlowPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('4-Week Strategic Priority Timeline', Icons.timeline_outlined, palette),
        const SizedBox(height: 14),
        ..._currentPlan.fourWeekTimeline.map((week) {
          return GlowCard(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: palette.primaryDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Week ${week.weekNumber}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    Text(
                      week.focusPriority,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: palette.accent),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  week.title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: palette.primaryDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Milestone: ${week.milestoneGoal}',
                  style: TextStyle(fontSize: 12, color: palette.secondaryText),
                ),
                const SizedBox(height: 10),
                ...week.actionItems.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right_rounded, color: palette.accent, size: 18),
                        const SizedBox(width: 4),
                        Expanded(child: Text(action, style: TextStyle(fontSize: 12, color: palette.primaryText))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // 5. Daily Checklist Tab
  Widget _buildChecklistTab(GlowPalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streak Card
        GlowCard(
          backgroundColor: palette.primaryDark,
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_streakCount Day Glowing Streak!',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Consistency is 80% of cosmetic skincare results.',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader('Morning Steps Checklist', Icons.wb_sunny_outlined, palette),
        const SizedBox(height: 10),
        ...List.generate(_currentPlan.morningRoutine.length, (i) {
          final step = _currentPlan.morningRoutine[i];
          return CheckboxListTile(
            value: step.isCompleted,
            activeColor: palette.primaryDark,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${step.stepNumber}. ${step.title}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                color: step.isCompleted ? palette.mutedText : palette.primaryDark,
              ),
            ),
            subtitle: Text(step.keyIngredient, style: TextStyle(fontSize: 11, color: palette.secondaryText)),
            onChanged: (val) => _toggleStep(i, true),
          );
        }),

        const SizedBox(height: 20),
        _buildSectionHeader('Evening Steps Checklist', Icons.nights_stay_outlined, palette),
        const SizedBox(height: 10),
        ...List.generate(_currentPlan.eveningRoutine.length, (i) {
          final step = _currentPlan.eveningRoutine[i];
          return CheckboxListTile(
            value: step.isCompleted,
            activeColor: palette.primaryDark,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${step.stepNumber}. ${step.title}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                color: step.isCompleted ? palette.mutedText : palette.primaryDark,
              ),
            ),
            subtitle: Text(step.keyIngredient, style: TextStyle(fontSize: 11, color: palette.secondaryText)),
            onChanged: (val) => _toggleStep(i, false),
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, GlowPalette palette) {
    return Row(
      children: [
        Icon(icon, size: 18, color: palette.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 16,
                color: palette.primaryDark,
              ),
        ),
      ],
    );
  }
}
