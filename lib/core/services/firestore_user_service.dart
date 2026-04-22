import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet/core/services/offline_sync_queue.dart';
import 'package:projet/core/services/user_prefs_service.dart';

/// Handles syncing user-specific data (bookmark, downloads, reciter pref) to Firestore.
class FirestoreUserService {
  static const _bookmarkBaseKey = 'mushaf_bookmark_page';
  static const _reciterBaseKey = 'last_reciter_id';

  String get _bookmarkKey => UserPrefsService.instance.keyFor(_bookmarkBaseKey);
  String get _reciterKey => UserPrefsService.instance.keyFor(_reciterBaseKey);

  // ── Mushaf Bookmark ──────────────────────────────────────────────────

  /// Save bookmark locally AND to Firestore.
  Future<void> saveBookmark(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bookmarkKey, page);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'prefs': {'mushafBookmark': page, 'bookmarkUpdatedAt': FieldValue.serverTimestamp()}
      }, SetOptions(merge: true));
      debugPrint('[FirestoreUserService] Bookmark $page saved to Firestore');
    } catch (e) {
      debugPrint('[FirestoreUserService] Bookmark offline, queued: $e');
      await OfflineSyncQueue().enqueue({'type': 'sync_bookmark', 'page': page});
    }
  }

  /// Load bookmark: Firestore first (wins on new device), then local.
  Future<int?> loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getInt(_bookmarkKey);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return local;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final remote = (doc.data()?['prefs']?['mushafBookmark'] as num?)?.toInt();
      if (remote != null) {
        await prefs.setInt(_bookmarkKey, remote); // keep local in sync
        debugPrint('[FirestoreUserService] Bookmark loaded from Firestore: $remote');
        return remote;
      }
    } catch (e) {
      debugPrint('[FirestoreUserService] Bookmark load error: $e');
    }
    return local;
  }

  // ── Download Metadata ────────────────────────────────────────────────

  /// Save download metadata to Firestore after a successful download.
  Future<void> saveDownloadMeta({
    required String url,
    required String title,
    required String reciterName,
    required int surahNumber,
    required int fileSize,
    required DateTime downloadedAt,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = _urlToDocId(url);
    final data = {
      'url': url,
      'title': title,
      'reciterName': reciterName,
      'surahNumber': surahNumber,
      'fileSize': fileSize,
      'downloadedAt': Timestamp.fromDate(downloadedAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users').doc(user.uid).collection('downloads').doc(docId)
          .set(data);
      debugPrint('[FirestoreUserService] Download meta saved: $title');
    } catch (e) {
      debugPrint('[FirestoreUserService] Download meta offline, queued: $e');
      await OfflineSyncQueue().enqueue({
        'type': 'sync_download_meta',
        'docId': docId,
        'url': url,
        'title': title,
        'reciterName': reciterName,
        'surahNumber': surahNumber,
        'fileSize': fileSize,
        'downloadedAt': downloadedAt.toIso8601String(),
      });
    }
  }

  /// Remove download metadata from Firestore.
  Future<void> deleteDownloadMeta(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = _urlToDocId(url);
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(user.uid).collection('downloads').doc(docId)
          .delete();
      debugPrint('[FirestoreUserService] Download meta deleted: $docId');
    } catch (e) {
      debugPrint('[FirestoreUserService] Delete meta offline, queued: $e');
      await OfflineSyncQueue().enqueue({'type': 'delete_download_meta', 'docId': docId});
    }
  }

  /// Fetch all remote download entries from Firestore.
  Future<List<Map<String, dynamic>>> fetchRemoteDownloads() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).collection('downloads').get();
      return snap.docs.map((d) => <String, dynamic>{'id': d.id, ...d.data()}).toList();
    } catch (e) {
      debugPrint('[FirestoreUserService] fetchRemoteDownloads error: $e');
      return [];
    }
  }

  // ── Reciter Preference ───────────────────────────────────────────────

  Future<void> saveLastReciter(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reciterKey, reciterId);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'prefs': {'lastReciterId': reciterId}
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<String?> loadLastReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString(_reciterKey);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return local;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final remote = doc.data()?['prefs']?['lastReciterId'] as String?;
      if (remote != null) {
        await prefs.setString(_reciterKey, remote);
        return remote;
      }
    } catch (_) {}
    return local;
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Converts a URL to a safe Firestore document ID.
  String _urlToDocId(String url) {
    final safe = url.replaceAll(RegExp(r'[^\w]'), '_');
    return safe.length > 100 ? safe.substring(safe.length - 100) : safe;
  }
}
