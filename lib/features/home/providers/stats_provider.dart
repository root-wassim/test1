import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:projet/core/services/offline_sync_queue.dart';
import 'package:projet/core/services/user_prefs_service.dart';
import 'package:projet/features/favorites/providers/favorites_provider.dart';
import 'package:projet/features/home/models/listening_session.dart';
import 'package:projet/features/home/models/track_stats.dart';

class StatsState {
  const StatsState({
    required this.sessions,
    required this.totalMinutes,
    required this.monthlyMinutesByDay,
    required this.topTracks,
  });

  final List<ListeningSession> sessions;
  final int totalMinutes;
  final Map<int, int> monthlyMinutesByDay;
  final List<TrackStats> topTracks;

  factory StatsState.initial() => const StatsState(
        sessions: [],
        totalMinutes: 0,
        monthlyMinutesByDay: {},
        topTracks: [],
      );
}

class StatsNotifier extends AsyncNotifier<StatsState> {
  DateTime? _activeStart;
  String _activeTrack = '';

  @override
  Future<StatsState> build() async {
    final user = FirebaseAuth.instance.currentUser;
    final sessionsKey = UserPrefsService.instance.keyFor('listening_sessions');
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(sessionsKey) ?? '[]';
    final localList = (jsonDecode(raw) as List<dynamic>)
        .map((e) => ListeningSession.fromJson(e as Map<String, dynamic>))
        .toList();

    if (user == null) {
      return _compute(localList);
    }

    try {
      final sessionsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sessions')
          .orderBy('startedAt', descending: false)
          .get();

      final remoteList = sessionsSnap.docs
          .map(
            (doc) => ListeningSession(
              trackTitle: (doc.data()['trackTitle'] ?? '').toString(),
              startedAt: (doc.data()['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              endedAt: (doc.data()['endedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              durationSeconds: (doc.data()['durationSeconds'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();

      final merged = _mergeSessions(localList, remoteList);
      await prefs.setString(sessionsKey, jsonEncode(merged.map((e) => e.toJson()).toList()));
      return _compute(merged);
    } catch (_) {
      return _compute(localList);
    }
  }

  Future<void> startSession(String trackTitle) async {
    _activeTrack = trackTitle;
    _activeStart = DateTime.now();
  }

  Future<void> stopSession() async {
    if (_activeStart == null || _activeTrack.isEmpty) return;
    final end = DateTime.now();
    final seconds = end.difference(_activeStart!).inSeconds;
    if (seconds < 2) {
      _activeStart = null;
      _activeTrack = '';
      return;
    }

    final previous = state.value ?? StatsState.initial();
    final updatedSessions = [
      ...previous.sessions,
      ListeningSession(
        trackTitle: _activeTrack,
        startedAt: _activeStart!,
        endedAt: end,
        durationSeconds: seconds,
      ),
    ];

    final sessionsKey = UserPrefsService.instance.keyFor('listening_sessions');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      sessionsKey,
      jsonEncode(updatedSessions.map((e) => e.toJson()).toList()),
    );

    final computed = _compute(updatedSessions);
    state = AsyncData(computed);
    await _storeSessionInFirestore(updatedSessions.last, ref.read(offlineSyncQueueProvider));
    await _syncToFirestore(computed, ref.read(offlineSyncQueueProvider));

    _activeStart = null;
    _activeTrack = '';
  }

  StatsState _compute(List<ListeningSession> sessions) {
    final totalMinutes = sessions.fold<int>(0, (total, s) => total + (s.durationSeconds ~/ 60));
    final now = DateTime.now();
    final byDay = <int, int>{};
    final trackSeconds = <String, int>{};
    final trackPlays = <String, int>{};

    for (final session in sessions) {
      if (session.startedAt.year == now.year && session.startedAt.month == now.month) {
        byDay.update(
          session.startedAt.day,
          (value) => value + (session.durationSeconds ~/ 60),
          ifAbsent: () => session.durationSeconds ~/ 60,
        );
      }
      trackSeconds.update(session.trackTitle, (v) => v + session.durationSeconds, ifAbsent: () => session.durationSeconds);
      trackPlays.update(session.trackTitle, (v) => v + 1, ifAbsent: () => 1);
    }

    final topTracks = trackSeconds.entries
        .map((e) => TrackStats(
              trackTitle: e.key,
              playCount: trackPlays[e.key] ?? 0,
              totalSeconds: e.value,
            ))
        .toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));

    return StatsState(
      sessions: sessions,
      totalMinutes: totalMinutes,
      monthlyMinutesByDay: byDay,
      topTracks: topTracks.take(5).toList(),
    );
  }

  List<ListeningSession> _mergeSessions(List<ListeningSession> local, List<ListeningSession> remote) {
    final map = <String, ListeningSession>{};
    for (final s in [...local, ...remote]) {
      final key = '${s.trackTitle}|${s.startedAt.toIso8601String()}|${s.endedAt.toIso8601String()}';
      map[key] = s;
    }
    final merged = map.values.toList()
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return merged;
  }

  Future<void> _storeSessionInFirestore(ListeningSession session, OfflineSyncQueue queue) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('sessions').add({
        'trackTitle': session.trackTitle,
        'startedAt': Timestamp.fromDate(session.startedAt),
        'endedAt': Timestamp.fromDate(session.endedAt),
        'durationSeconds': session.durationSeconds,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await queue.enqueue({
        'type': 'add_session',
        'trackTitle': session.trackTitle,
        'startedAt': session.startedAt.toIso8601String(),
        'endedAt': session.endedAt.toIso8601String(),
        'durationSeconds': session.durationSeconds,
      });
    }
  }

  Future<void> _syncToFirestore(StatsState stateData, OfflineSyncQueue queue) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'stats': {
          'totalMinutes': stateData.totalMinutes,
          'monthlyMinutesByDay': stateData.monthlyMinutesByDay.map((k, v) => MapEntry('$k', v)),
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (_) {
      await queue.enqueue({
        'type': 'sync_stats',
        'totalMinutes': stateData.totalMinutes,
        'monthlyMinutesByDay': stateData.monthlyMinutesByDay.map((k, v) => MapEntry('$k', v)),
      });
    }
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, StatsState>(StatsNotifier.new);
