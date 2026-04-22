import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralised helper that namespaces SharedPreferences keys by UID.
///
/// Every piece of user-specific local data MUST go through [keyFor] so that
/// switching accounts on the same device never leaks data across users.
class UserPrefsService {
  UserPrefsService._();
  static final instance = UserPrefsService._();

  // ── Public API ──────────────────────────────────────────────────────

  /// Returns the current Firebase UID, or `null` if no-one is signed in.
  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  /// Builds a per-user SharedPreferences key.
  ///
  /// Example: `keyFor('downloaded_tracks_map')` → `"abc123_downloaded_tracks_map"`.
  /// If no user is signed in, falls back to an `anon_` prefix so the app
  /// never crashes — but data saved under `anon_` is considered ephemeral.
  String keyFor(String baseKey) {
    final uid = currentUid ?? 'anon';
    return '${uid}_$baseKey';
  }

  /// Clears **all** SharedPreferences keys that belong to [uid].
  ///
  /// Call this on logout *before* the Firebase sign-out so [currentUid] is
  /// still available, or pass the UID explicitly.
  Future<void> clearUserData([String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null) return;

    final prefix = '${targetUid}_';
    final prefs = await SharedPreferences.getInstance();
    final userKeys = prefs.getKeys().where((k) => k.startsWith(prefix)).toList();

    debugPrint('[UserPrefsService] Clearing ${userKeys.length} keys for $targetUid');
    for (final key in userKeys) {
      await prefs.remove(key);
    }
  }
}
