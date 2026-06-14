import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _introSeenKey = 'intro_seen';

  static Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introSeenKey) ?? false;
  }

  static Future<void> markIntroAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, true);
  }
}
