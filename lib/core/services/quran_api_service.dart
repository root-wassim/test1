import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:projet/core/constants/api_constants.dart';
import 'package:projet/core/services/api_cache_service.dart';
import 'package:projet/features/player/models/reciter_model.dart';
import 'package:projet/features/player/models/track_model.dart';

/// Offline-first API service: tries network first, falls back to local cache.
class QuranApiService {
  final http.Client _client = http.Client();
  final ApiCacheService _cache = ApiCacheService();

  /// Core helper: fetch JSON from network, cache it; on failure, return cache.
  Future<dynamic> _getJsonCached(Uri uri, String cacheKey) async {
    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw HttpException(_httpMessage(response.statusCode));
      }
      // Cache the successful response
      await _cache.setCache(cacheKey, response.body);
      return jsonDecode(response.body);
    } on SocketException {
      // No internet — try cache
      return _fallbackToCache(cacheKey);
    } on HttpException catch (e) {
      // Server error — try cache
      final cached = await _cache.getCached(cacheKey);
      if (cached != null) return jsonDecode(cached);
      throw Exception(e.message);
    } on FormatException {
      final cached = await _cache.getCached(cacheKey);
      if (cached != null) return jsonDecode(cached);
      throw Exception('Invalid API response / Réponse API invalide');
    } on Exception {
      // Timeout or other error — try cache
      return _fallbackToCache(cacheKey);
    }
  }

  /// Try to return cached data, throw if not available.
  Future<dynamic> _fallbackToCache(String cacheKey) async {
    final cached = await _cache.getCached(cacheKey);
    if (cached != null) return jsonDecode(cached);
    throw Exception('Pas de connexion internet et aucune donnée en cache.');
  }

  Future<List<ReciterModel>> fetchReciters() async {
    final json = await _getJsonCached(Uri.parse(ApiConstants.reciters), 'reciters');
    final map = json as Map<String, dynamic>;
    final list = (map['reciters'] ?? []) as List<dynamic>;
    return list.map((e) => ReciterModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TrackModel>> fetchReciterTracks(int reciterId) async {
    final uri = Uri.parse('${ApiConstants.reciterAudio}?reciter_id=$reciterId');
    final json = await _getJsonCached(uri, 'reciter_tracks_$reciterId');
    final map = json as Map<String, dynamic>;
    final list = (map['audio_urls'] ?? map['audio_files'] ?? []) as List<dynamic>;
    return list.map((e) => TrackModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- Additional endpoints from the Quran APIs website ----
  Future<List<dynamic>> fetchSurahs() async {
    final json = await _getJsonCached(Uri.parse(ApiConstants.surahs), 'surahs');
    return (json as List<dynamic>);
  }

  Future<List<dynamic>> fetchAyah(int number) async {
    final json = await _getJsonCached(
      Uri.parse('${ApiConstants.ayah}?number=$number'),
      'ayah_$number',
    );
    return json as List<dynamic>;
  }

  Future<dynamic> fetchQuranPageText(int page) async {
    return _getJsonCached(
      Uri.parse('${ApiConstants.quranPagesText}?page=$page'),
      'quran_page_text_$page',
    );
  }

  Future<dynamic> fetchQuranPagesImage() async {
    return _getJsonCached(Uri.parse(ApiConstants.quranPagesImage), 'quran_pages_image');
  }

  Future<dynamic> fetchSurahAudio({
    required String reciterShortName,
    required int surahId,
  }) async {
    final uri = Uri.parse('${ApiConstants.surahAudio}?reciter=$reciterShortName&id=$surahId');
    return _getJsonCached(uri, 'surah_audio_${reciterShortName}_$surahId');
  }

  Future<dynamic> fetchRadio() async {
    return _getJsonCached(Uri.parse(ApiConstants.radio), 'radio');
  }

  Future<dynamic> fetchAzkar() async {
    return _getJsonCached(Uri.parse(ApiConstants.azkar), 'azkar');
  }

  Future<dynamic> fetchDuas() async {
    return _getJsonCached(Uri.parse(ApiConstants.duas), 'duas');
  }

  Future<dynamic> fetchLaylatAlQadr() async {
    return _getJsonCached(Uri.parse(ApiConstants.laylatAlQadr), 'laylat_al_qadr');
  }

  Future<dynamic> fetchPrayerTimes() async {
    return _getJsonCached(Uri.parse(ApiConstants.prayerTimes), 'prayer_times');
  }

  String _httpMessage(int code) {
    if (code == 400) return 'Bad request / Requête invalide (400)';
    if (code == 404) return 'Resource not found / Ressource introuvable (404)';
    if (code >= 500) return 'Server error / Erreur serveur ($code)';
    return 'Unexpected API error / Erreur API inattendue ($code)';
  }
}
