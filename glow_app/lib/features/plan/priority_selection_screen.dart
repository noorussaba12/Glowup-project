import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/models/plan_model.dart';
import '../../shared/widgets/glow_button.dart';
import '../../shared/widgets/glow_card.dart';

class PrioritySelectionScreen extends ConsumerStatefulWidget {
  final ScanResult? scanResult;
  final Map<String, dynamic>? questionnaire;
  final Map<String, dynamic>? reportData;
  final File? imageFile;

  const PrioritySelectionScreen({
    super.key,
    this.scanResult,
    this.questionnaire,
    this.reportData,
    this.imageFile,
  });

  @override
  ConsumerState<PrioritySelectionScreen> createState() => _PrioritySelectionScreenState();
}

class _PrioritySelectionScreenState extends ConsumerState<PrioritySelectionScreen> {
  // Ordered list of selected priority IDs
  final List<String> _selectedPriorities = ['dehydration', 'pores', 'dark_circles'];
  bool _isBuildingPlan = false;

  final Map<String, String> _recommendations = {
    'dehydration': 'Recommended first: Deep cellular hydration accelerates barrier repair and improves tone.',
    'pores': 'Targeting sebum balance reduces pore visibility and prevents subsequent micro-comedones.',
    'dark_circles': 'Periorbital care targets venous congestion and brightens tired under-eye contours.',
    'redness': 'Calming reactive sensitivity strengthens capillary resilience against environmental triggers.',
    'fine_lines': 'Antioxidants and retinoid introduction smooth superficial dynamic lines.',
    'acne': 'Anti-inflammatory treatments eliminate active bacterial proliferation and post-inflammatory marks.',
  };

  void _togglePriority(String id) {
    setState(() {
      if (_selectedPriorities.contains(id)) {
        _selectedPriorities.remove(id);
      } else {
        if (_selectedPriorities.length < 3) {
          _selectedPriorities.add(id);
        } else {
          // Replace last
          _selectedPriorities[2] = id;
        }
      }
    });
  }

  void _resetPriorities() {
    setState(() {
      _selectedPriorities.clear();
    });
  }

  Future<void> _buildMyPlan() async {
    if (_selectedPriorities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 priority concern.')),
      );
      return;
    }

    setState(() => _isBuildingPlan = true);

    try {
      final gender = LocalStorageService.userGender;
      final scan = widget.scanResult ??
          ScanResult(
            imageQuality: ImageQuality(usable: true, issues: []),
            overallScore: 82,
            skinTypeEstimate: 'combination',
            concerns: [],
            redFlags: [],
            notes: '',
          );

      // Generate the personalized plan
      final response = await ApiService.generatePlan(
        scanResult: scan,
        questionnaireAnswers: widget.questionnaire ?? {},
        priorities: _selectedPriorities,
        gender: gender,
      );

      final planData = response['plan'] as Map<String, dynamic>? ?? {};
      final plan = GlowPlan.fromJson(planData);

      // Save scan record to Firestore & local storage
      final scanRecord = ScanRecord(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        localImagePath: widget.imageFile?.path,
        createdAt: DateTime.now(),
        scanResult: scan,
        questionnaireAnswers: widget.questionnaire,
        doctorReport: widget.reportData?['report'],
        selectedPriorities: _selectedPriorities,
        planData: planData,
      );

      await FirebaseService.saveScanRecord(scanRecord, imageFile: widget.imageFile);

      if (mounted) {
        context.pushReplacement('/plan', extra: {'plan': plan});
      }
    } catch (e) {
      debugPrint('Plan build notice: $e');
      if (mounted) {
        context.pushReplacement('/plan');
      }
    } finally {
      if (mounted) setState(() => _isBuildingPlan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final scan = widget.scanResult;

    final allConcerns = scan?.concerns ?? [
      SkinConcern(
        id: 'dehydration',
        title: 'Dehydration / Dryness',
        severity: 'moderate',
        score: 68,
        zones: ['cheeks'],
        confidence: 0.9,
        explanation: 'Surface flaking and water loss.',
      ),
      SkinConcern(
        id: 'pores',
        title: 'Enlarged Pores',
        severity: 'mild',
        score: 45,
        zones: ['nose'],
        confidence: 0.88,
        explanation: 'Enlarged pores in T-zone.',
      ),
      SkinConcern(
        id: 'dark_circles',
        title: 'Dark Circles',
        severity: 'moderate',
        score: 62,
        zones: ['under_eyes'],
        confidence: 0.86,
        explanation: 'Vascular pooling under eyes.',
      ),
      SkinConcern(
        id: 'redness',
        title: 'Redness / Sensitivity',
        severity: 'mild',
        score: 38,
        zones: ['cheeks'],
        confidence: 0.84,
        explanation: 'Reactive cheek erythema.',
      ),
      SkinConcern(
        id: 'fine_lines',
        title: 'Fine Lines & Texture',
        severity: 'mild',
        score: 32,
        zones: ['forehead'],
        confidence: 0.82,
        explanation: 'Expression lines.',
      ),
    ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Priority Selection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _resetPriorities,
            child: Text('Reset', style: TextStyle(color: palette.accent)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assistant Dialog Prompt Card
              GlowCard(
                padding: const EdgeInsets.all(18),
                backgroundColor: palette.surface,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: palette.accentLight, shape: BoxShape.circle),
                      child: Center(child: Icon(Icons.spa_outlined, color: palette.accent, size: 24)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'I found several areas we can improve. Choose up to 3 priorities in the order you want to fix them.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: palette.primaryDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Rank Your Top 3 Concerns',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 18,
                      color: palette.primaryDark,
                    ),
              ),
              const SizedBox(height: 12),

              // Concern items list
              Expanded(
                child: ListView.separated(
                  itemCount: allConcerns.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = allConcerns[i];
                    final rankIndex = _selectedPriorities.indexOf(item.id);
                    final isSelected = rankIndex != -1;
                    final rankNumber = rankIndex + 1;
                    final recommendation = _recommendations[item.id] ?? 'Targets optimal skin barrier health.';

                    return GestureDetector(
                      onTap: () => _togglePriority(item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? palette.primaryDark : palette.border,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: palette.primaryDark.withOpacity(0.06),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Rank Number Badge
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? palette.primaryDark : palette.chipBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  isSelected ? '$rankNumber' : '+',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? Colors.white : palette.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: palette.primaryDark,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: palette.accentLight,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            'Priority $rankNumber',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: palette.accent,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    recommendation,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: palette.secondaryText,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Button
              GlowPillButton(
                text: 'Build My Personalized Plan',
                isLoading: _isBuildingPlan,
                onPressed: _buildMyPlan,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
