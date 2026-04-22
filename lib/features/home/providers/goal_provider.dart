import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projet/core/services/user_prefs_service.dart';

class MonthlyGoalNotifier extends Notifier<int> {
  @override
  int build() => 20;

  void setGoal(int value) => state = value;
}

final monthlyGoalProvider = NotifierProvider<MonthlyGoalNotifier, int>(MonthlyGoalNotifier.new);

final monthlyGoalLoaderProvider = FutureProvider<void>((ref) async {
  final goalKey = UserPrefsService.instance.keyFor('monthly_goal_hours');
  final prefs = await SharedPreferences.getInstance();
  final localGoal = prefs.getInt(goalKey) ?? 20;
  ref.read(monthlyGoalProvider.notifier).setGoal(localGoal);

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  try {
    final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final remoteGoal = (snap.data()?['settings']?['monthlyGoalHours'] as num?)?.toInt();
    if (remoteGoal != null) {
      ref.read(monthlyGoalProvider.notifier).setGoal(remoteGoal);
      await prefs.setInt(goalKey, remoteGoal);
    }
  } catch (_) {
    // Keep local value if Firestore is unavailable.
  }
});

class GoalStorage {
  Future<void> setGoal(WidgetRef ref, int hours) async {
    ref.read(monthlyGoalProvider.notifier).setGoal(hours);
    final goalKey = UserPrefsService.instance.keyFor('monthly_goal_hours');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalKey, hours);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'settings': {
            'monthlyGoalHours': hours,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        }, SetOptions(merge: true));
      } catch (_) {
        // Local persistence already ensured.
      }
    }
  }
}

final goalStorageProvider = Provider<GoalStorage>((ref) => GoalStorage());
