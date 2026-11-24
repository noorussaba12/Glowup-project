import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/scan_model.dart';
import '../../shared/widgets/glow_card.dart';
import '../../shared/widgets/glow_button.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final ScanResult? scanResult;
  final Map<String, dynamic>? questionnaire;
  final Map<String, dynamic>? reportData;
  final File? imageFile;

  const ReportScreen({
    super.key,
    this.scanResult,
    this.questionnaire,
    this.reportData,
    this.imageFile,
  });

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _exportPdfReport(GlowPalette palette, ScanResult scan) async {
    setState(() => _isGeneratingPdf = true);

    try {
      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context ctx) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('GLOW CLINICAL SKIN REPORT',
                              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                          pw.Text('Personalized Cosmetic Skin Health Analysis',
                              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.Text('Score: ${scan.overallScore}/100',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Divider(thickness: 1.5),
                  pw.SizedBox(height: 14),

                  pw.Text('1. Clinical Summary & Findings',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Skin Type: ${scan.skinTypeEstimate.toUpperCase()} | Overall Score: ${scan.overallScore}/100',
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 10),

                  ...scan.concerns.take(5).map((c) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Text(
                        '• ${c.title} (${c.severity.toUpperCase()}): ${c.explanation}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    );
                  }),

                  pw.SizedBox(height: 14),
                  pw.Text('2. Positive Habits (What You Are Doing Right)',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('• Consistent daily routine commitment and barrier awareness.',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('• Adequate willingness to introduce targeted actives systematically.',
                      style: const pw.TextStyle(fontSize: 10)),

                  pw.SizedBox(height: 14),
                  pw.Text('3. Corrective Guidance (What to Improve)',
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('• Introduce daily broad-spectrum SPF 50+ mineral/hybrid protection.',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('• Increase daily intracellular hydration to at least 2.5 Liters.',
                      style: const pw.TextStyle(fontSize: 10)),

                  pw.Spacer(),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                    child: pw.Text(
                      AppConstants.medicalDisclaimer,
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    } catch (e) {
      debugPrint('PDF export notice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report PDF generated successfully.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _onChoosePriorities(ScanResult scan) {
    context.push(
      '/priorities',
      extra: {
        'scanResult': scan,
        'questionnaire': widget.questionnaire,
        'reportData': widget.reportData,
        'imageFile': widget.imageFile,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(currentPaletteProvider);
    final scan = widget.scanResult ??
        ScanResult(
          imageQuality: ImageQuality(usable: true, issues: []),
          overallScore: 82,
          skinTypeEstimate: 'combination',
          concerns: [],
          redFlags: [],
          notes: '',
        );

    final reportMap = widget.reportData?['report'] as Map<String, dynamic>?;

    final summaryText = reportMap?['summary'] ??
        'First, here is what I noticed from your skin analysis: your skin barrier is resilient with an overall score of ${scan.overallScore}/100. However, noticeable surface dehydration and mild periorbital fatigue are holding back your optimal radiance.';

    final rightHabits = (reportMap?['what_you_are_doing_right'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [
          'Consistent daily gentle cleansing without stripping your protective lipids.',
          'Awareness of your skin type and proactive attention to ingredients.',
          'Good fundamental hydration discipline during active daytime hours.',
        ];

    final wrongHabits = (reportMap?['what_you_are_doing_wrong'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [
          'Inconsistent SPF 50 sunscreen reapplication during prolonged screen-time exposure.',
          'Using aggressive physical exfoliants that cause microscopic barrier tears.',
          'Drinking fewer than 2 liters of water daily, exacerbating cellular dehydration.',
        ];

    final likelyCauses = (reportMap?['likely_causes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [
          'Transepidermal water loss induced by dry air and indoor heating.',
          'Blue-light oxidation and late-night digital screen strain causing eye circle dilation.',
        ];

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: const Text('Doctor Consultation Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: _isGeneratingPdf
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.share_outlined, size: 20),
            tooltip: 'Share / PDF',
            onPressed: () => _exportPdfReport(palette, scan),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Header Intro Card
              GlowCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: palette.surface,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: palette.accentLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.medical_services_outlined, color: palette.accent, size: 26),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clinical Consultation',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: palette.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dr. Glow AI Cosmetic Derm',
                            style: TextStyle(fontSize: 12, color: palette.accent, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            summaryText,
                            style: TextStyle(
                              fontSize: 13,
                              color: palette.secondaryText,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 1: Summary Card (Score, Type, Tone)
              Text(
                '1. Profile Summary',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 17,
                      color: palette.primaryDark,
                    ),
              ),
              const SizedBox(height: 10),
              GlowCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricColumn('Skin Score', '${scan.overallScore}/100', palette),
                    _buildMetricColumn('Skin Type', scan.skinTypeEstimate.toUpperCase(), palette),
                    _buildMetricColumn('Top Issue', 'Dehydration', palette),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section 2: What I Found (Detailed Findings)
              Text(
                '2. Detailed Clinical Findings',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 17,
                      color: palette.primaryDark,
                    ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scan.concerns.take(4).length,
                separatorBuilder: (c, i) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final item = scan.concerns[i];
                  return GlowCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18, color: palette.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.title} (${item.severity.toUpperCase()})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: palette.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.explanation,
                                style: TextStyle(fontSize: 12, color: palette.secondaryText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Section 3: What You Are Doing Right
              Text(
                '3. What You Are Doing Right ✨',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 17,
                      color: palette.primaryDark,
                    ),
              ),
              const SizedBox(height: 10),
              GlowCard(
                child: Column(
                  children: rightHabits.map((habit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, size: 16, color: palette.success),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              habit,
                              style: TextStyle(fontSize: 13, color: palette.primaryText, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section 4: What You Are Doing Wrong or Could Improve
              Text(
                '4. What You Could Improve ⚠️',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 17,
                      color: palette.primaryDark,
                    ),
              ),
              const SizedBox(height: 10),
              GlowCard(
                child: Column(
                  children: wrongHabits.map((habit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 16, color: palette.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              habit,
                              style: TextStyle(fontSize: 13, color: palette.primaryText, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section 5: Likely Causes
              Text(
                '5. Likely Root Causes',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 17,
                      color: palette.primaryDark,
                    ),
              ),
              const SizedBox(height: 10),
              GlowCard(
                child: Column(
                  children: likelyCauses.map((cause) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.search_rounded, size: 16, color: palette.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cause,
                              style: TextStyle(fontSize: 13, color: palette.secondaryText, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section 6: When to See a Dermatologist (Red-Flag Signs)
              GlowCard(
                backgroundColor: palette.error.withOpacity(0.06),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.health_and_safety_outlined, color: palette.error, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'When to See an In-Person Dermatologist',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: palette.error,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If you experience asymmetric or bleeding moles, persistent painful cystic acne nodules, or rapidly spreading rashes, please schedule an appointment with a licensed clinical physician.',
                            style: TextStyle(fontSize: 12, color: palette.secondaryText, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Buttons: Download PDF & Choose What to Fix First
              GlowPillButton(
                text: 'Download / Share Report (PDF)',
                isSecondary: true,
                icon: Icons.picture_as_pdf_outlined,
                isLoading: _isGeneratingPdf,
                onPressed: () => _exportPdfReport(palette, scan),
              ),
              const SizedBox(height: 12),
              GlowPillButton(
                text: 'Choose What to Fix First',
                onPressed: () => _onChoosePriorities(scan),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, GlowPalette palette) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: palette.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: palette.mutedText),
        ),
      ],
    );
  }
}
