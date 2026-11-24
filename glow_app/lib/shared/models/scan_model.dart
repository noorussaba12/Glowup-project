class ImageQuality {
  final bool usable;
  final List<String> issues;

  ImageQuality({required this.usable, required this.issues});

  factory ImageQuality.fromJson(Map<String, dynamic> json) {
    return ImageQuality(
      usable: json['usable'] ?? true,
      issues: (json['issues'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'usable': usable,
    'issues': issues,
  };
}

class SkinConcern {
  final String id;
  final String title;
  final String severity; // 'none' | 'mild' | 'moderate' | 'severe'
  final int score;       // 0 - 100
  final List<String> zones; // ['forehead','left_cheek','right_cheek','nose','chin','under_eyes']
  final double confidence; // 0.0 - 1.0
  final String explanation;

  SkinConcern({
    required this.id,
    required this.title,
    required this.severity,
    required this.score,
    required this.zones,
    required this.confidence,
    required this.explanation,
  });

  static String getTitleForId(String id) {
    switch (id) {
      case 'dehydration': return 'Dehydration / Dryness';
      case 'oiliness': return 'Excess Oil / Shine';
      case 'dark_circles': return 'Dark Circles';
      case 'puffy_eyes': return 'Puffy Eyes';
      case 'blackheads': return 'Blackheads';
      case 'whiteheads': return 'Whiteheads';
      case 'acne': return 'Acne / Breakouts';
      case 'pigmentation': return 'Pigmentation / Dark Spots';
      case 'tanning': return 'Tanning / Uneven Tone';
      case 'redness': return 'Redness / Sensitivity';
      case 'pores': return 'Enlarged Pores';
      case 'fine_lines': return 'Fine Lines / Aging';
      case 'texture': return 'Uneven Texture / Roughness';
      default: return id.replaceAll('_', ' ').toUpperCase();
    }
  }

  factory SkinConcern.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? 'texture';
    return SkinConcern(
      id: id,
      title: json['title'] ?? getTitleForId(id),
      severity: json['severity'] ?? 'mild',
      score: (json['score'] as num?)?.toInt() ?? 50,
      zones: (json['zones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['cheeks'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'severity': severity,
    'score': score,
    'zones': zones,
    'confidence': confidence,
    'explanation': explanation,
  };
}

class ScanResult {
  final ImageQuality imageQuality;
  final int overallScore; // 0 - 100
  final String skinTypeEstimate; // oily | dry | combination | normal | unsure
  final List<SkinConcern> concerns;
  final List<String> redFlags;
  final String notes;

  ScanResult({
    required this.imageQuality,
    required this.overallScore,
    required this.skinTypeEstimate,
    required this.concerns,
    required this.redFlags,
    required this.notes,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      imageQuality: ImageQuality.fromJson(json['image_quality'] ?? {}),
      overallScore: (json['overall_score'] as num?)?.toInt() ?? 75,
      skinTypeEstimate: json['skin_type_estimate'] ?? 'combination',
      concerns: (json['concerns'] as List<dynamic>?)
              ?.map((e) => SkinConcern.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      redFlags: (json['red_flags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'image_quality': imageQuality.toJson(),
    'overall_score': overallScore,
    'skin_type_estimate': skinTypeEstimate,
    'concerns': concerns.map((c) => c.toJson()).toList(),
    'red_flags': redFlags,
    'notes': notes,
  };
}

class ScanRecord {
  final String id;
  final String? localImagePath;
  final String? storageImageUrl;
  final DateTime createdAt;
  final ScanResult scanResult;
  final Map<String, dynamic>? questionnaireAnswers;
  final Map<String, dynamic>? doctorReport;
  final List<String>? selectedPriorities;
  final Map<String, dynamic>? planData;

  ScanRecord({
    required this.id,
    this.localImagePath,
    this.storageImageUrl,
    required this.createdAt,
    required this.scanResult,
    this.questionnaireAnswers,
    this.doctorReport,
    this.selectedPriorities,
    this.planData,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'localImagePath': localImagePath,
    'storageImageUrl': storageImageUrl,
    'createdAt': createdAt.toIso8601String(),
    'scanResult': scanResult.toJson(),
    'questionnaireAnswers': questionnaireAnswers,
    'doctorReport': doctorReport,
    'selectedPriorities': selectedPriorities,
    'planData': planData,
  };

  factory ScanRecord.fromMap(Map<String, dynamic> map, String id) {
    return ScanRecord(
      id: id,
      localImagePath: map['localImagePath'],
      storageImageUrl: map['storageImageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      scanResult: ScanResult.fromJson(map['scanResult'] ?? {}),
      questionnaireAnswers: map['questionnaireAnswers'],
      doctorReport: map['doctorReport'],
      selectedPriorities: (map['selectedPriorities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      planData: map['planData'],
    );
  }
}
