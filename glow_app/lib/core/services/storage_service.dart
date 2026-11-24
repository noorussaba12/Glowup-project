import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Onboarding
  static bool get hasOnboarded =>
      _prefs?.getBool(AppConstants.prefHasOnboarded) ?? false;

  static Future<void> setHasOnboarded(bool value) async {
    await _prefs?.setBool(AppConstants.prefHasOnboarded, value);
  }

  // Skip scan instructions
  static bool get skipScanInstructions =>
      _prefs?.getBool(AppConstants.prefSkipScanInstructions) ?? false;

  static Future<void> setSkipScanInstructions(bool value) async {
    await _prefs?.setBool(AppConstants.prefSkipScanInstructions, value);
  }

  // Gender & Theme
  static String get userGender =>
      _prefs?.getString(AppConstants.prefUserGender) ?? 'female';

  static Future<void> setUserGender(String gender) async {
    await _prefs?.setString(AppConstants.prefUserGender, gender);
  }

  // Cached scan record / history fallback
  static List<Map<String, dynamic>> getOfflineScans() {
    final raw = _prefs?.getString('glow_offline_scans');
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveOfflineScan(Map<String, dynamic> scanData) async {
    final scans = getOfflineScans();
    scans.insert(0, scanData);
    await _prefs?.setString('glow_offline_scans', jsonEncode(scans));
  }

  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}
