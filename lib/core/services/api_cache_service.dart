import 'package:shared_preferences/shared_preferences.dart';

/// Local JSON cache for API responses, enabling offline-first data access.
class ApiCacheService {
  static const _prefix = 'api_cache_';
  static const _tsPrefix = 'api_cache_ts_';

  /// Retrieve cached JSON string for [key], or null if not cached.
  Future<String?> getCached(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }

  /// Store a JSON string in cache for [key] and record the timestamp.
  Future<void> setCache(String key, String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonData);
    await prefs.setInt('$_tsPrefix$key', DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns true if the cache for [key] exists and is younger than [ttl].
  Future<bool> isFresh(String key, {Duration ttl = const Duration(hours: 24)}) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt('$_tsPrefix$key');
    if (ts == null) return false;
    final cached = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(cached) < ttl;
  }

  /// Remove a specific cache entry.
  Future<void> invalidate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
    await prefs.remove('$_tsPrefix$key');
  }

  /// Clear all cached API data.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix) || k.startsWith(_tsPrefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
