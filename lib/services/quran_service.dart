import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';

class QuranApiService {
  static const String _base = 'https://api.alquran.cloud/v1';
  static const String _reciter = 'Mishary Rashid Alafasy';

  static Future<List<Category>> fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('$_base/surah'));
      if (res.statusCode != 200) return _fallback();

      final data = jsonDecode(res.body);
      final List surahs = data['data'];

      return surahs.map<Category>((s) {
        final number = s['number'] as int;
        final id = number.toString();
        final englishName = s['englishName'] as String;
        final arabicName = s['name'] as String;           // e.g. الفاتحة
        final versesCount = s['numberOfAyahs'] as int;

        return Category(
          id: id,
          name: englishName,
          tracks: [
            Track(
              id: id,
              title: englishName,
              arabicTitle: arabicName,
              category: 'Quran',
              reciter: _reciter,
              audioUrl: _audioUrl(id),
              surahNumber: number,
              duration: versesCount,
            )
          ],
        );
      }).toList();
    } catch (e) {
      return _fallback();
    }
  }

  static String _audioUrl(String surahId) =>
      'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahId.mp3';

  static List<Category> _fallback() => [
    const Category(
      id: '1',
      name: 'Al-Fatiha',
      tracks: [
        Track(
          id: '1',
          title: 'Al-Fatiha',
          arabicTitle: 'الفاتحة',
          category: 'Quran',
          reciter: 'Mishary Rashid Alafasy',
          audioUrl:
          'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/1.mp3',
          surahNumber: 1,
        )
      ],
    ),
  ];
}