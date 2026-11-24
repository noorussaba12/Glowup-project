class AppConstants {
  static const String appName = 'Glow';
  static const String appTagline = 'AI Skin Health & Personalized Plan';

  // Backend endpoint configuration (points to local express backend or cloud function)
  static const String defaultBackendBaseUrl = 'http://10.0.2.2:5000'; // Android emulator localhost
  static const String physicalDeviceBackendUrl = 'http://localhost:5000';

  // Medical Disclaimer required by Prompt section 6
  static const String medicalDisclaimer =
      'Glow provides cosmetic skincare and nutrition guidance based on your photo and questionnaire. '
      'It is not a medical diagnosis, clinical treatment, or replacement for a licensed dermatologist. '
      'If you notice bleeding, irregular changing moles, painful cystic nodes, or severe rashes, please consult a medical physician immediately.';

  // Preference Keys
  static const String prefHasOnboarded = 'glow_has_onboarded';
  static const String prefSkipScanInstructions = 'glow_skip_scan_instructions';
  static const String prefUserGender = 'glow_user_gender';
  static const String prefUserTheme = 'glow_user_theme';

  // Face scanning constraints
  static const double minFaceRatio = 0.35;
  static const double maxFaceRatio = 0.85;
  static const double maxHeadEulerAngle = 14.0; // degrees
}
