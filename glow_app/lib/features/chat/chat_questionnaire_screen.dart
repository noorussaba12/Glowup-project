import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/widgets/glow_button.dart';

class ChatQuestionnaireScreen extends ConsumerStatefulWidget {
  final ScanResult? scanResult;
  final File? imageFile;

  const ChatQuestionnaireScreen({super.key, this.scanResult, this.imageFile});

  @override
  ConsumerState<ChatQuestionnaireScreen> createState() => _ChatQuestionnaireScreenState();
}

class _ChatQuestionnaireScreenState extends ConsumerState<ChatQuestionnaireScreen> {
  int _currentQuestionIndex = 0;
  bool _isAssistantTyping = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textInputController = TextEditingController();

  final Map<String, dynamic> _answers = {};
  final List<_ChatMessage> _chatHistory = [];

  final List<_Question> _questions = const [
    _Question(
      key: 'skin_type',
      text: 'To get started, how would you describe your natural skin type?',
      options: ['Oily', 'Dry', 'Combination', 'Normal', 'Not sure'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'sensitivity',
      text: 'Does your skin easily sting, redden, or burn when trying new products?',
      options: ['Very sensitive', 'Mildly sensitive', 'Rarely reactive', 'Not sensitive at all'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'skin_tone',
      text: 'What is your approximate skin tone and undertone?',
      options: ['Fair (Cool)', 'Fair (Warm)', 'Light (Neutral)', 'Medium (Warm)', 'Tan (Golden)', 'Deep (Warm/Neutral)'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'current_products',
      text: 'Which skincare steps are already part of your weekly routine? (Select all that apply)',
      options: ['Cleanser', 'Moisturizer', 'Sunscreen', 'Vitamin C Serum', 'Retinol / Retinoid', 'AHA/BHA Exfoliant', 'Face Oils', 'Makeup'],
      isMultiSelect: true,
    ),
    _Question(
      key: 'sunscreen_frequency',
      text: 'How frequently do you apply sunscreen during daylight hours?',
      options: ['Every morning (365 days)', 'Only on sunny days', 'Only at beach/pool', 'Rarely or never'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'allergies',
      text: 'Do you have any known ingredient sensitivities, fragrance allergies, or brand intolerances?',
      options: ['No known allergies', 'Fragrance sensitivity', 'Essential oils', 'Chemical UV filters', 'Niacinamide sensitivity'],
      isMultiSelect: false,
      allowCustomText: true,
    ),
    _Question(
      key: 'water_intake',
      text: 'Approximately how much pure water do you drink daily?',
      options: ['Less than 1 Liter', '1 to 2 Liters', '2 to 3 Liters', 'More than 3 Liters'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'sleep_hours',
      text: 'On average, how many hours of restful sleep do you get each night?',
      options: ['Under 5 hours', '5 to 6 hours', '7 to 8 hours', 'Over 8 hours'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'diet_type',
      text: 'Which dietary pattern best matches your regular lifestyle?',
      options: ['Balanced Non-Veg', 'Vegetarian', 'Vegan / Plant-Based', 'High Sugar / Fast Food', 'Keto / Low-Carb'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'lifestyle_stress',
      text: 'How would you rate your typical daily stress and screen-time exposure?',
      options: ['Low stress / moderate screens', 'Moderate stress / high screens', 'High stress / late night screens'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'sun_exposure',
      text: 'What does your daily sun exposure look like?',
      options: ['Mostly indoors / office', 'Moderate outdoor commute', 'Outdoors frequently (>3 hrs/day)'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'primary_goal',
      text: 'What is your #1 primary skincare goal right now?',
      options: ['Clear Acne & Blemishes', 'Radiant Glow & Tone', 'Deep Hydration & Barrier', 'Reduce Dark Circles', 'Anti-Aging & Firmness'],
      isMultiSelect: false,
    ),
    _Question(
      key: 'medical_conditions',
      text: 'Do you have any diagnosed medical skin conditions or active prescriptions (e.g. PCOS, Eczema, Isotretinoin)? Note: Serious conditions require an in-person doctor.',
      options: ['None / Healthy', 'Eczema / Dermatitis', 'PCOS-related breakouts', 'Currently on Isotretinoin', 'Rosacea'],
      isMultiSelect: false,
      allowCustomText: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pushAssistantQuestion(0);
  }

  void _pushAssistantQuestion(int index) {
    if (index >= _questions.length) {
      _finishQuestionnaire();
      return;
    }

    setState(() => _isAssistantTyping = true);

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _isAssistantTyping = false;
        _chatHistory.add(
          _ChatMessage(
            sender: 'assistant',
            text: _questions[index].text,
            questionIndex: index,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _handleAnswer(dynamic answer) {
    final currentQ = _questions[_currentQuestionIndex];
    setState(() {
      _answers[currentQ.key] = answer;
      _chatHistory.add(
        _ChatMessage(
          sender: 'user',
          text: answer is List ? answer.join(', ') : answer.toString(),
        ),
      );
      _currentQuestionIndex++;
    });

    _scrollToBottom();

    if (_currentQuestionIndex < _questions.length) {
      _pushAssistantQuestion(_currentQuestionIndex);
    } else {
      _finishQuestionnaire();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isGeneratingReport = false;

  Future<void> _finishQuestionnaire() async {
    setState(() => _isGeneratingReport = true);

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

      // Call backend to generate clinical consultation report
      final responseData = await ApiService.generatePlan(
        scanResult: scan,
        questionnaireAnswers: _answers,
        priorities: ['Hydration', 'Pores', 'Dark Circles'],
        gender: gender,
      );

      if (mounted) {
        context.pushReplacement(
          '/report',
          extra: {
            'scanResult': scan,
            'questionnaire': _answers,
            'reportData': responseData,
            'imageFile': widget.imageFile,
          },
        );
      }
    } catch (_) {
      if (mounted) {
        context.pushReplacement('/report', extra: {
          'scanResult': widget.scanResult,
          'questionnaire': _answers,
          'imageFile': widget.imageFile,
        });
      }
    } finally {
      if (mounted) setState(() => _isGeneratingReport = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final isDone = _currentQuestionIndex >= _questions.length;
    final currentQ = !isDone ? _questions[_currentQuestionIndex] : null;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Glow Consultation Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (_currentQuestionIndex > 0) {
              setState(() {
                _currentQuestionIndex--;
                if (_chatHistory.length >= 2) {
                  _chatHistory.removeLast(); // user answer
                  _chatHistory.removeLast(); // question
                }
                _pushAssistantQuestion(_currentQuestionIndex);
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / (_questions.length + 1),
              backgroundColor: palette.border,
              valueColor: AlwaysStoppedAnimation<Color>(palette.primaryDark),
              minHeight: 3,
            ),

            // Chat conversation list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _chatHistory.length + (_isAssistantTyping ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == _chatHistory.length && _isAssistantTyping) {
                    return _buildTypingIndicator(palette);
                  }
                  final msg = _chatHistory[i];
                  return _buildChatBubble(msg, palette);
                },
              ),
            ),

            // Bottom Input / Option Chips Area
            if (!isDone && currentQ != null && !_isAssistantTyping) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  border: Border(top: BorderSide(color: palette.border, width: 1)),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primaryDark.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Options Wrap
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentQ.options.map((opt) {
                        return ActionChip(
                          backgroundColor: palette.chipBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: palette.border, width: 1),
                          ),
                          label: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: palette.primaryText,
                            ),
                          ),
                          onPressed: () => _handleAnswer(opt),
                        );
                      }).toList(),
                    ),

                    // Custom free text input if allowed
                    if (currentQ.allowCustomText) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textInputController,
                              decoration: InputDecoration(
                                hintText: 'Or type custom details...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.send_rounded, color: palette.primaryDark),
                            onPressed: () {
                              if (_textInputController.text.trim().isNotEmpty) {
                                _handleAnswer(_textInputController.text.trim());
                                _textInputController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (isDone) ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: GlowPillButton(
                  text: 'Generate Doctor Report',
                  isLoading: _isGeneratingReport,
                  onPressed: _finishQuestionnaire,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg, GlowPalette palette) {
    final isAssistant = msg.sender == 'assistant';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isAssistant ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAssistant) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: palette.accentLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.spa_outlined, size: 18, color: palette.accent),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAssistant ? palette.surface : palette.primaryDark,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isAssistant ? const Radius.circular(4) : const Radius.circular(18),
                  bottomRight: isAssistant ? const Radius.circular(18) : const Radius.circular(4),
                ),
                border: isAssistant ? Border.all(color: palette.border, width: 1) : null,
                boxShadow: [
                  BoxShadow(
                    color: palette.primaryDark.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isAssistant ? palette.primaryText : Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (!isAssistant) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(GlowPalette palette) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: palette.accentLight, shape: BoxShape.circle),
            child: Center(child: Icon(Icons.spa_outlined, size: 18, color: palette.accent)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(palette),
                const SizedBox(width: 4),
                _dot(palette),
                const SizedBox(width: 4),
                _dot(palette),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(GlowPalette palette) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: palette.accent.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _Question {
  final String key;
  final String text;
  final List<String> options;
  final bool isMultiSelect;
  final bool allowCustomText;

  const _Question({
    required this.key,
    required this.text,
    required this.options,
    this.isMultiSelect = false,
    this.allowCustomText = false,
  });
}

class _ChatMessage {
  final String sender; // 'assistant' | 'user'
  final String text;
  final int? questionIndex;

  _ChatMessage({
    required this.sender,
    required this.text,
    this.questionIndex,
  });
}
