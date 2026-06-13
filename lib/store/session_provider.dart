import 'package:flutter/material.dart';
import '../storage/session_storage.dart';

class SessionProvider extends ChangeNotifier {
  final SessionStorage _storage = SessionStorage();

  String _network = 'instagram';
  DateTime? _startedAt;
  int _postsViewed = 0;
  int _activeLimit = 20;
  bool _extended = false;
  bool _isCaughtUp = false;

  // List of history records loaded from disk
  List<SessionRecord> _history = [];
  bool _historyLoaded = false;

  // Getters
  String get network => _network;
  DateTime? get startedAt => _startedAt;
  int get postsViewed => _postsViewed;
  int get activeLimit => _activeLimit;
  bool get extended => _extended;
  bool get isCaughtUp => _isCaughtUp;
  List<SessionRecord> get history => _history;
  bool get historyLoaded => _historyLoaded;

  SessionProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _history = await _storage.loadRecords();
    _historyLoaded = true;
    notifyListeners();
  }

  void startSession(String network, int initialLimit) {
    if (_startedAt != null) return;

    _network = network;
    _startedAt = DateTime.now();
    _postsViewed = 0;
    _activeLimit = initialLimit;
    _extended = false;
    _isCaughtUp = false;
    notifyListeners();
  }

  void updatePostCount(int count) {
    if (_startedAt == null) return;
    if (count < _postsViewed) return;

    _postsViewed = count;

    // Trigger caught up overlay if we hit or exceed active limit
    if (_postsViewed >= _activeLimit && !_isCaughtUp) {
      _isCaughtUp = true;
    }
    notifyListeners();
  }

  void extendSession(int count) {
    _activeLimit += count;
    _extended = true;
    _isCaughtUp = false;
    notifyListeners();
  }

  Future<void> endSession() async {
    if (_startedAt == null) return;

    final record = SessionRecord(
      network: _network,
      startedAt: _startedAt!,
      endedAt: DateTime.now(),
      postsViewed: _postsViewed,
      limit: _activeLimit,
      extended: _extended,
    );

    // Save on-device
    await _storage.appendRecord(record);

    // Clear active session variables
    _startedAt = null;
    _postsViewed = 0;
    _extended = false;
    _isCaughtUp = false;

    // Reload history to refresh Insights screen
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _storage.clearAll();
    _history = [];
    notifyListeners();
  }
}
