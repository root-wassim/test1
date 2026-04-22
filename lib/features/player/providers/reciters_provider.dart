import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/services/quran_api_service.dart';
import 'package:projet/features/player/models/reciter_model.dart';
import 'package:projet/features/player/models/track_model.dart';

final quranApiServiceProvider = Provider<QuranApiService>((ref) => QuranApiService());

final recitersProvider = FutureProvider<List<ReciterModel>>((ref) async {
  return ref.read(quranApiServiceProvider).fetchReciters();
});

final tracksByReciterProvider = FutureProvider.family<List<TrackModel>, int>((ref, reciterId) async {
  return ref.read(quranApiServiceProvider).fetchReciterTracks(reciterId);
});
