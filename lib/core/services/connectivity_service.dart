import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier that tracks device connectivity state in real-time.
class ConnectivityNotifier extends Notifier<bool> {
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  bool build() {
    _init();
    ref.onDispose(() => _sub?.cancel());
    return true; // assume online initially
  }

  Future<void> _init() async {
    // Check initial state
    final result = await Connectivity().checkConnectivity();
    state = _isConnected(result);

    // Listen for changes
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      state = _isConnected(result);
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }
}

/// Whether the device currently has internet connectivity.
final isOnlineProvider = NotifierProvider<ConnectivityNotifier, bool>(
  ConnectivityNotifier.new,
);
