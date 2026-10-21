import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import '../features/notes/view_models/notes_view_model.dart';
import '../features/tasks_deadlines/view_models/tasks_view_model.dart';
import '../features/habits_everyday/view_models/habits_view_model.dart';
import '../features/focus_timer/view_models/timer_view_model.dart';
import '../features/flashcards/view_models/flashcards_view_model.dart';

class AppController extends ChangeNotifier {
  final StorageService storageService;
  late final NotesViewModel notesViewModel;
  late final TasksViewModel tasksViewModel;
  late final HabitsViewModel habitsViewModel;
  late final TimerViewModel timerViewModel;
  late final FlashcardsViewModel flashcardsViewModel;

  bool _isDarkMode = false;

  AppController({required this.storageService}) {
    _isDarkMode = storageService.isDarkMode;
    notesViewModel = NotesViewModel(storageService: storageService);
    tasksViewModel = TasksViewModel(storageService: storageService);
    habitsViewModel = HabitsViewModel(storageService: storageService);
    timerViewModel = TimerViewModel(storageService: storageService);
    flashcardsViewModel = FlashcardsViewModel(storageService: storageService);
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await storageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}

class AppScope extends InheritedWidget {
  final AppController controller;

  const AppScope({
    super.key,
    required this.controller,
    required super.child,
  });

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => controller != oldWidget.controller;
}
