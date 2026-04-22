import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet/core/services/biometric_service.dart';
import 'package:local_auth/local_auth.dart';

/// A favorite track entry.
class FavoriteTrack {
  const FavoriteTrack({
    required this.surahNumber,
    required this.surahName,
    required this.reciterName,
    required this.audioUrl,
    this.addedAt,
  });

  final int surahNumber;
  final String surahName;
  final String reciterName;
  final String audioUrl;
  final DateTime? addedAt;

  Map<String, dynamic> toMap() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'reciterName': reciterName,
        'audioUrl': audioUrl,
        'addedAt': FieldValue.serverTimestamp(),
      };

  factory FavoriteTrack.fromMap(Map<String, dynamic> map) {
    return FavoriteTrack(
      surahNumber: (map['surahNumber'] as int?) ?? 0,
      surahName: (map['surahName'] ?? '').toString(),
      reciterName: (map['reciterName'] ?? '').toString(),
      audioUrl: (map['audioUrl'] ?? '').toString(),
      addedAt: (map['addedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Manages favorites with Firestore sync.
class FavoritesNotifier extends AsyncNotifier<List<FavoriteTrack>> {
  final _biometric = BiometricService(LocalAuthentication());

  CollectionReference<Map<String, dynamic>>? _favoritesCol() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites');
  }

  @override
  Future<List<FavoriteTrack>> build() async {
    final col = _favoritesCol();
    if (col == null) return [];
    try {
      final snap = await col.orderBy('addedAt', descending: true).get();
      return snap.docs
          .map((d) => FavoriteTrack.fromMap(d.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Check if a track is a favorite.
  bool isFavorite(int surahNumber) {
    return state.valueOrNull
            ?.any((f) => f.surahNumber == surahNumber) ??
        false;
  }

  /// Add a track to favorites.
  Future<void> addFavorite(FavoriteTrack track) async {
    final col = _favoritesCol();
    if (col == null) return;
    try {
      await col.doc('${track.surahNumber}').set(track.toMap());
      ref.invalidateSelf();
    } catch (_) {}
  }

  /// Remove a track from favorites (requires biometric auth).
  Future<bool> removeFavorite(int surahNumber) async {
    // Require biometric confirmation
    final result = await _biometric.authenticate();
    if (!result.ok) return false;

    final col = _favoritesCol();
    if (col == null) return false;
    try {
      await col.doc('$surahNumber').delete();
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Toggle favorite status.
  Future<void> toggleFavorite(FavoriteTrack track) async {
    if (isFavorite(track.surahNumber)) {
      await removeFavorite(track.surahNumber);
    } else {
      await addFavorite(track);
    }
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteTrack>>(
  FavoritesNotifier.new,
);
