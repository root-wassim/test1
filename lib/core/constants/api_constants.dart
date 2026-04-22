class ApiConstants {
  static const String baseUrl = 'https://quran.yousefheiba.com';

  // Quran text
  static const String surahs = '$baseUrl/api/surahs';
  static const String ayah = '$baseUrl/api/ayah';
  static const String quranPagesText = '$baseUrl/api/quranPagesText';
  static const String quranPagesImage = '$baseUrl/api/quranPagesImage';

  // Audio
  static const String reciters = '$baseUrl/api/reciters';
  static const String reciterAudio = '$baseUrl/api/reciterAudio';
  static const String surahAudio = '$baseUrl/api/surahAudio';
  static const String radio = '$baseUrl/api/radio';

  // Azkar / duas
  static const String azkar = '$baseUrl/api/azkar';
  static const String duas = '$baseUrl/api/duas';
  static const String laylatAlQadr = '$baseUrl/api/laylatAlQadr';

  // Practical services
  static const String prayerTimes = '$baseUrl/api/getPrayerTimes';
}
