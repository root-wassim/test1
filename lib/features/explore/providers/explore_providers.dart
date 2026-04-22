import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/services/quran_api_service.dart';
import 'package:projet/features/explore/models/azkar_model.dart';
import 'package:projet/features/explore/models/dua_model.dart';
import 'package:projet/features/explore/models/prayer_times_model.dart';
import 'package:projet/features/explore/models/surah_model.dart';

final _apiService = QuranApiService();

/// Fetches the list of 114 surahs.
final surahsProvider = FutureProvider<List<SurahModel>>((ref) async {
  final json = await _apiService.fetchSurahs();
  return json
      .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Fetches all ayahs for a specific surah number (1–114).
final ayahProvider = FutureProvider.family<List<dynamic>, int>((ref, surahNumber) async {
  return await _apiService.fetchAyah(surahNumber);
});

/// Fetches azkar organized by 12 categories.
final azkarProvider = FutureProvider<List<AzkarCategory>>((ref) async {
  final json = await _apiService.fetchAzkar();
  final map = json as Map<String, dynamic>;

  const categoryMeta = {
    'morning_azkar': ('أذكار الصباح', '🌅'),
    'evening_azkar': ('أذكار المساء', '🌙'),
    'prayer_azkar': ('أذكار الصلاة', '🕌'),
    'prayer_later_azkar': ('أذكار بعد الصلاة', '📿'),
    'sleep_azkar': ('أذكار النوم', '😴'),
    'wake_up_azkar': ('أذكار الاستيقاظ', '☀️'),
    'mosque_azkar': ('أذكار المسجد', '🏛️'),
    'wudu_azkar': ('أذكار الوضوء', '💧'),
    'food_azkar': ('أذكار الطعام', '🍽️'),
    'home_azkar': ('أذكار المنزل', '🏠'),
    'adhan_azkar': ('أذكار الأذان', '📢'),
    'khala_azkar': ('أذكار الخلاء', '🚿'),
    'miscellaneous_azkar': ('أذكار متنوعة', '✨'),
    'hajj_and_umrah_azkar': ('أذكار الحج والعمرة', '🕋'),
  };

  final categories = <AzkarCategory>[];
  for (final entry in map.entries) {
    final meta = categoryMeta[entry.key];
    if (meta == null) continue;
    final items = (entry.value as List<dynamic>)
        .map((e) => AzkarItem.fromJson(e as Map<String, dynamic>))
        .toList();
    if (items.isEmpty) continue;
    categories.add(AzkarCategory(
      key: entry.key,
      label: meta.$1,
      icon: meta.$2,
      items: items,
    ));
  }
  return categories;
});

/// Fetches duas organized by 4 categories.
final duasProvider = FutureProvider<List<DuaCategory>>((ref) async {
  final json = await _apiService.fetchDuas();
  final map = json as Map<String, dynamic>;

  const categoryMeta = {
    'prophetic_duas': ('أدعية نبوية', '🤲'),
    'quran_duas': ('أدعية قرآنية', '📖'),
    'prophets_duas': ('أدعية الأنبياء', '✨'),
    'quran_completion_duas': ('دعاء ختم القرآن', '🏆'),
  };

  final categories = <DuaCategory>[];
  for (final entry in map.entries) {
    final meta = categoryMeta[entry.key];
    if (meta == null) continue;
    final items = (entry.value as List<dynamic>)
        .map((e) => DuaItem.fromJson(e as Map<String, dynamic>))
        .toList();
    if (items.isEmpty) continue;
    categories.add(DuaCategory(
      key: entry.key,
      label: meta.$1,
      icon: meta.$2,
      items: items,
    ));
  }
  return categories;
});

/// Fetches prayer times based on user's IP location.
final prayerTimesProvider = FutureProvider<PrayerTimesModel>((ref) async {
  final json = await _apiService.fetchPrayerTimes();
  return PrayerTimesModel.fromJson(json as Map<String, dynamic>);
});

/// Fetches Laylat Al-Qadr information.
final laylatAlQadrProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final json = await _apiService.fetchLaylatAlQadr();
  return json as Map<String, dynamic>;
});

/// Fetches Quran page images list.
final quranPageImagesProvider = FutureProvider<List<String>>((ref) async {
  final json = await _apiService.fetchQuranPagesImage();
  if (json is Map) {
    final pages = json['pages'] ?? json['images'] ?? [];
    if (pages is List) {
      return pages.map((e) {
        if (e is Map) return (e['page_url'] ?? e['url'] ?? '').toString();
        return e.toString();
      }).where((url) => url.isNotEmpty).toList();
    }
  }
  if (json is List) {
    return json.map((e) {
      if (e is Map) return (e['page_url'] ?? e['url'] ?? '').toString();
      return e.toString();
    }).where((url) => url.isNotEmpty).toList();
  }
  return [];
});

/// Fetches radio stream URL.
final radioProvider = FutureProvider<String>((ref) async {
  final json = await _apiService.fetchRadio();
  if (json is Map) {
    return (json['url'] ?? json['radio_url'] ?? json['stream_url'] ?? '').toString();
  }
  return json.toString();
});
