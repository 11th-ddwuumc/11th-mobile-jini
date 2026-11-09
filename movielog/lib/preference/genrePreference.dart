import 'package:shared_preferences/shared_preferences.dart';

class GenrePreference {
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _selectedGenreKey = 'selected_genre';

  final SharedPreferencesAsync _preferences;

  Future<void> saveGenre(String genre) async {
    await _preferences.setString(_selectedGenreKey, genre);
  }

  Future<String?> loadGenre() async {
    return await _preferences.getString(_selectedGenreKey);
  }
}
