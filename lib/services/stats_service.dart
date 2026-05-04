import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data layout in Firestore:
///   users/{uid}/daily_stats/{YYYY-MM-DD}  → { totalSeconds: num, updatedAt: Timestamp }
///   users/{uid}/track_stats/{trackId}     → { title, totalSeconds: num, playCount: num, lastPlayedAt }
///
/// Monthly goal (hours) is saved locally via SharedPreferences (as required by spec).
class StatsService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static const String _keyGoalHours = 'monthly_goal_hours';
  static const int _defaultGoalHours = 20;

  static DocumentReference<Map<String, dynamic>> _userDoc() =>
      _db.collection('users').doc(_uid);

  static CollectionReference<Map<String, dynamic>> _dailyCol() =>
      _userDoc().collection('daily_stats');

  static CollectionReference<Map<String, dynamic>> _trackCol() =>
      _userDoc().collection('track_stats');

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<void> recordListening(
      String trackId, String trackTitle, int seconds) async {
    if (_uid == null || seconds <= 0) return;

    final today = _todayKey();
    final batch = _db.batch();

    batch.set(
      _dailyCol().doc(today),
      {
        'totalSeconds': FieldValue.increment(seconds),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      _trackCol().doc(trackId),
      {
        'title': trackTitle,
        'totalSeconds': FieldValue.increment(seconds),
        'playCount': FieldValue.increment(1),
        'lastPlayedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  // ── Monthly goal (hours) — stored locally ─────────────────────────────────

  static Future<int> getGoalHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyGoalHours) ?? _defaultGoalHours;
  }

  static Future<void> setGoalHours(int hours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGoalHours, hours);
  }

  // ── Today's minutes — Firestore stream ───────────────────────────────────

  static Stream<int> todayMinutesStream() {
    if (_uid == null) return Stream.value(0);
    return _dailyCol().doc(_todayKey()).snapshots().map((s) {
      // Firestore returns numeric fields as num, never as int directly.
      final raw = s.data()?['totalSeconds'];
      return ((raw as num?) ?? 0).toInt() ~/ 60;
    });
  }

  // ── Monthly minutes — Firestore stream ───────────────────────────────────

  static Stream<Map<String, int>> dailyMinutesThisMonthStream() {
    if (_uid == null) return Stream.value({});
    final prefix = _monthPrefix();
    return _dailyCol()
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix)
        .where(FieldPath.documentId, isLessThan: '${prefix.substring(0, 7)}-32')
        .snapshots()
        .map((snap) {
      final map = <String, int>{};
      for (final doc in snap.docs) {
        final raw = doc.data()['totalSeconds'];
        map[doc.id] = ((raw as num?) ?? 0).toInt() ~/ 60;
      }
      return map;
    });
  }

  static Future<int> getTotalSecondsThisMonth() async {
    if (_uid == null) return 0;
    final prefix = _monthPrefix();
    final snap = await _dailyCol()
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix)
        .where(FieldPath.documentId, isLessThan: '${prefix.substring(0, 7)}-32')
        .get();
    int total = 0;
    for (final doc in snap.docs) {
      final raw = doc.data()['totalSeconds'];
      total += ((raw as num?) ?? 0).toInt();
    }
    return total;
  }

  static Future<Map<String, int>> getDailyMinutesThisMonth() async {
    if (_uid == null) return {};
    final prefix = _monthPrefix();
    final snap = await _dailyCol()
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix)
        .where(FieldPath.documentId, isLessThan: '${prefix.substring(0, 7)}-32')
        .get();
    final map = <String, int>{};
    for (final doc in snap.docs) {
      final raw = doc.data()['totalSeconds'];
      map[doc.id] = ((raw as num?) ?? 0).toInt() ~/ 60;
    }
    return map;
  }

  // ── Most played ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMostPlayed({int limit = 5}) async {
    if (_uid == null) return [];
    final snap = await _trackCol()
        .orderBy('playCount', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return {
        'trackId': d.id,
        'title': data['title'] ?? '',
        'count': ((data['playCount'] as num?) ?? 0).toInt(),
        'seconds': ((data['totalSeconds'] as num?) ?? 0).toInt(),
      };
    }).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static int daysInCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 1)
        .difference(DateTime(now.year, now.month, 1))
        .inDays;
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static String _monthPrefix() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-';
  }
}