import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<void> setFavoriteStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFavorite', status);
  }

  static Future<bool> getFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFavorite') ?? false;
  }
}
