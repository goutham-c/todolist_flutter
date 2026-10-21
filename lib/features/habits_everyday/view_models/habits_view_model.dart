import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/formatters.dart';

class HabitsViewModel extends ChangeNotifier {
  final StorageService storageService;

  List<HabitModel> _habits = [];

  HabitsViewModel({required this.storageService}) {
    loadHabits();
  }

  List<HabitModel> get habits => _habits;

  double get todayCompletionRate {
    if (_habits.isEmpty) return 0.0;
    final todayKey = Formatters.formatDateKey(DateTime.now());
    final completedCount = _habits.where((h) => h.isCompletedOn(todayKey)).length;
    return completedCount / _habits.length;
  }

  int get todayCompletedCount {
    final todayKey = Formatters.formatDateKey(DateTime.now());
    return _habits.where((h) => h.isCompletedOn(todayKey)).length;
  }

  void loadHabits() {
    _habits = storageService.getHabits();
    notifyListeners();
  }

  Future<void> toggleHabitToday(String habitId) async {
    final todayKey = Formatters.formatDateKey(DateTime.now());
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final dates = List<String>.from(habit.completedDates);
      int newStreak = habit.streak;
      int newBestStreak = habit.bestStreak;

      if (dates.contains(todayKey)) {
        dates.remove(todayKey);
        if (newStreak > 0) newStreak--;
      } else {
        dates.add(todayKey);
        newStreak++;
        if (newStreak > newBestStreak) {
          newBestStreak = newStreak;
        }
      }

      _habits[index] = habit.copyWith(
        completedDates: dates,
        streak: newStreak,
        bestStreak: newBestStreak,
      );

      await storageService.saveHabits(_habits);
      notifyListeners();
    }
  }

  Future<void> addHabit(HabitModel habit) async {
    _habits.add(habit);
    await storageService.saveHabits(_habits);
    notifyListeners();
  }

  Future<void> updateHabit(HabitModel habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      await storageService.saveHabits(_habits);
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await storageService.saveHabits(_habits);
    notifyListeners();
  }
}
