import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento de preferencias no sensibles (tema, onboarding, etc.).
/// NUNCA guardar JWT aquí; usar SecureStorage.
class PreferencesStorage {
  static const _onboardingKey = 'onboarding_done';

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}
