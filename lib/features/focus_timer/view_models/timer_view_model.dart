import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/timer_model.dart';
import '../../../core/services/storage_service.dart';

class TimerViewModel extends ChangeNotifier {
  final StorageService storageService;

  late TimerSettings _settings;
  TimerMode _mode = TimerMode.pomodoro;
  bool _isRunning = false;
  int _remainingSeconds = 25 * 60;
  int _totalDurationSeconds = 25 * 60;
  int _completedPomodoroRounds = 0;
  Timer? _ticker;

  // Break.Down.Timer alert state
  BreakCheckpoint? _activeBreakNotification;

  TimerViewModel({required this.storageService}) {
    _settings = storageService.getTimerSettings();
    _resetToMode(_mode);
  }

  TimerSettings get settings => _settings;
  TimerMode get mode => _mode;
  bool get isRunning => _isRunning;
  int get remainingSeconds => _remainingSeconds;
  int get totalDurationSeconds => _totalDurationSeconds;
  int get completedPomodoroRounds => _completedPomodoroRounds;
  BreakCheckpoint? get activeBreakNotification => _activeBreakNotification;

  double get progress {
    if (_totalDurationSeconds == 0) return 0.0;
    return (_totalDurationSeconds - _remainingSeconds) / _totalDurationSeconds;
  }

  void setMode(TimerMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _resetToMode(mode);
    notifyListeners();
  }

  void _resetToMode(TimerMode mode) {
    _ticker?.cancel();
    _isRunning = false;
    _activeBreakNotification = null;

    switch (mode) {
      case TimerMode.pomodoro:
        _totalDurationSeconds = _settings.pomodoroMinutes * 60;
        break;
      case TimerMode.shortBreak:
        _totalDurationSeconds = _settings.shortBreakMinutes * 60;
        break;
      case TimerMode.longBreak:
        _totalDurationSeconds = _settings.longBreakMinutes * 60;
        break;
      case TimerMode.breakDownTimer:
        _totalDurationSeconds = _settings.breakDownTotalMinutes * 60;
        // reset triggered flags on checkpoints
        for (final cp in _settings.breakDownCheckpoints) {
          cp.hasTriggered = false;
        }
        break;
    }
    _remainingSeconds = _totalDurationSeconds;
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    notifyListeners();

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;

        // Check for intermediate break notifications in Break.Down.Timer mode
        if (_mode == TimerMode.breakDownTimer) {
          _checkBreakDownCheckpoints();
        }

        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
  }

  void pauseTimer() {
    _ticker?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _resetToMode(_mode);
    notifyListeners();
  }

  void dismissBreakAlert() {
    _activeBreakNotification = null;
    notifyListeners();
  }

  void _checkBreakDownCheckpoints() {
    for (final cp in _settings.breakDownCheckpoints) {
      if (!cp.hasTriggered && _remainingSeconds <= cp.triggerAtSecond) {
        cp.hasTriggered = true;
        _activeBreakNotification = cp;
        break;
      }
    }
  }

  void _onTimerComplete() {
    _ticker?.cancel();
    _isRunning = false;

    if (_mode == TimerMode.pomodoro) {
      _completedPomodoroRounds++;
      // Auto switch to short break or long break
      if (_completedPomodoroRounds % 4 == 0) {
        _mode = TimerMode.longBreak;
      } else {
        _mode = TimerMode.shortBreak;
      }
    } else {
      _mode = TimerMode.pomodoro;
    }

    _resetToMode(_mode);
    notifyListeners();
  }

  Future<void> updateSettings(TimerSettings newSettings) async {
    _settings = newSettings;
    await storageService.saveTimerSettings(_settings);
    _resetToMode(_mode);
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
