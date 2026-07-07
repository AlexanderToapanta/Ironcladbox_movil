import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  SharedPreferences? _prefs;
  final Map<String, String> _memoryCache = {};

  factory CacheService() => _instance;
  CacheService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> save(String key, dynamic data) async {
    try {
      final json = jsonEncode(data);
      _memoryCache[key] = json;
      if (_prefs != null) {
        await _prefs!.setString('cache_$key', json);
        await _prefs!.setInt('cache_${key}_ts', DateTime.now().millisecondsSinceEpoch);
      }
    } catch (_) {}
  }

  dynamic get(String key) {
    try {
      final cached = _memoryCache[key];
      if (cached != null) return jsonDecode(cached);
      if (_prefs != null) {
        final stored = _prefs!.getString('cache_$key');
        if (stored != null) return jsonDecode(stored);
      }
    } catch (_) {}
    return null;
  }

  int getAgeMinutes(String key) {
    try {
      int? ts;
      if (_prefs != null) {
        ts = _prefs!.getInt('cache_${key}_ts');
      }
      if (ts == null) return 999999;
      final ageMs = DateTime.now().millisecondsSinceEpoch - ts;
      return (ageMs ~/ (1000 * 60));
    } catch (_) {
      return 999999;
    }
  }

  Future<void> clear() async {
    _memoryCache.clear();
    if (_prefs != null) {
      final keys = _prefs!.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _prefs!.remove(key);
        }
      }
    }
  }
}
