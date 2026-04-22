import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:projet/core/services/user_prefs_service.dart';

class OfflineSyncQueue {
  static const _baseKey = 'offline_sync_queue_v1';

  String get _key => UserPrefsService.instance.keyFor(_baseKey);

  Future<void> enqueue(Map<String, dynamic> action) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = _decode(prefs.getString(_key));
    existing.add(action);
    await prefs.setString(_key, jsonEncode(existing));
  }

  Future<void> flush() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final queued = _decode(prefs.getString(_key));
    if (queued.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final action in queued) {
      try {
        await _apply(user.uid, action);
      } catch (_) {
        remaining.add(action);
      }
    }
    await prefs.setString(_key, jsonEncode(remaining));
  }

  List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  Future<void> _apply(String uid, Map<String, dynamic> action) async {
    final type = action['type'] as String? ?? '';
    if (type == 'add_favorite') {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('favorites').add({
        'title': action['title'],
        'audioUrl': action['audioUrl'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    if (type == 'remove_favorite') {
      final favoriteId = action['favoriteId'] as String?;
      if (favoriteId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorites')
            .doc(favoriteId)
            .delete();
      }
      return;
    }
    if (type == 'sync_stats') {
      final totalMinutes = (action['totalMinutes'] as num?)?.toInt() ?? 0;
      final monthlyMinutesByDay = (action['monthlyMinutesByDay'] as Map?)?.cast<String, dynamic>() ?? {};
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'stats': {
          'totalMinutes': totalMinutes,
          'monthlyMinutesByDay': monthlyMinutesByDay,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      return;
    }
    if (type == 'add_session') {
      final startedAt = DateTime.tryParse((action['startedAt'] ?? '').toString());
      final endedAt = DateTime.tryParse((action['endedAt'] ?? '').toString());
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('sessions').add({
        'trackTitle': action['trackTitle'],
        'startedAt': startedAt != null ? Timestamp.fromDate(startedAt) : FieldValue.serverTimestamp(),
        'endedAt': endedAt != null ? Timestamp.fromDate(endedAt) : FieldValue.serverTimestamp(),
        'durationSeconds': (action['durationSeconds'] as num?)?.toInt() ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    if (type == 'sync_bookmark') {
      final page = (action['page'] as num?)?.toInt() ?? 1;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'prefs': {'mushafBookmark': page, 'bookmarkUpdatedAt': FieldValue.serverTimestamp()}
      }, SetOptions(merge: true));
    }
    if (type == 'sync_download_meta') {
      final downloadedAt = DateTime.tryParse((action['downloadedAt'] ?? '').toString());
      await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('downloads')
          .doc(action['docId'] as String? ?? 'unknown')
          .set({
        'url': action['url'],
        'title': action['title'],
        'reciterName': action['reciterName'],
        'surahNumber': (action['surahNumber'] as num?)?.toInt() ?? 0,
        'fileSize': (action['fileSize'] as num?)?.toInt() ?? 0,
        'downloadedAt': downloadedAt != null ? Timestamp.fromDate(downloadedAt) : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    if (type == 'delete_download_meta') {
      final docId = action['docId'] as String? ?? '';
      if (docId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users').doc(uid).collection('downloads').doc(docId).delete();
      }
    }
  }
}

final offlineSyncQueueProvider = Provider<OfflineSyncQueue>((ref) => OfflineSyncQueue());
