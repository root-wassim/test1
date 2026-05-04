import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/track.dart';

/// Firestore-backed favorites service.
///
/// Data layout:
///   users/{uid}/favorites/{trackId}  →  track map + addedAt timestamp
class FavoritesService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _col() =>
      _db.collection('users').doc(_uid).collection('favorites');

  // ── Streams ───────────────────────────────────────────────────────────────

  /// Emits the full list of favorite tracks whenever it changes in Firestore.
  static Stream<List<Track>> favoritesStream() {
    if (_uid == null) return Stream.value([]);
    return _col().snapshots().map((snap) =>
        snap.docs.map((d) => Track.fromMap(d.data())).toList());
  }

  /// Emits a Set of favorite track IDs — cheap to check membership.
  static Stream<Set<String>> favoriteIdsStream() {
    if (_uid == null) return Stream.value({});
    return _col().snapshots().map((snap) =>
        snap.docs.map((d) => d.id).toSet());
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Toggles the favorite state of [track].
  /// Returns `true` if the track was **added**, `false` if removed.
  static Future<bool> toggleFavorite(Track track) async {
    if (_uid == null) return false;
    final ref = _col().doc(track.id);
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
      return false;
    } else {
      await ref.set({
        ...track.toMap(),
        'addedAt': FieldValue.serverTimestamp(),
      });
      return true;
    }
  }

  static Future<void> addFavorite(Track track) async {
    if (_uid == null) return;
    await _col().doc(track.id).set({
      ...track.toMap(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeFavorite(String trackId) async {
    if (_uid == null) return;
    await _col().doc(trackId).delete();
  }

  static Future<bool> isFavorite(String trackId) async {
    if (_uid == null) return false;
    final snap = await _col().doc(trackId).get();
    return snap.exists;
  }
}
