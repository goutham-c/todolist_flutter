import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../../../core/services/storage_service.dart';

class TasksViewModel extends ChangeNotifier {
  final StorageService storageService;

  List<TaskModel> _tasks = [];
  List<DeadlineModel> _deadlines = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  TasksViewModel({required this.storageService}) {
    loadData();
  }

  List<TaskModel> get tasks => _tasks;
  List<DeadlineModel> get deadlines => _deadlines;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<String> get categories {
    final set = {'All'};
    for (final t in _tasks) {
      set.add(t.category);
    }
    return set.toList();
  }

  List<TaskModel> get filteredTasks {
    return _tasks.where((t) {
      final matchesCat = _selectedCategory == 'All' || t.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList()
      ..sort((a, b) {
        // Pending first, then by priority, then by creation
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.priority.index.compareTo(b.priority.index);
      });
  }

  List<DeadlineModel> get sortedDeadlines {
    return List<DeadlineModel>.from(_deadlines)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.targetDate.compareTo(b.targetDate);
      });
  }

  int get upcomingDeadlinesCount {
    final now = DateTime.now();
    return _deadlines.where((d) => !d.isCompleted && d.targetDate.isAfter(now)).length;
  }

  int get overdueDeadlinesCount {
    final now = DateTime.now();
    return _deadlines.where((d) => !d.isCompleted && d.targetDate.isBefore(now)).length;
  }

  void loadData() {
    _tasks = storageService.getTasks();
    _deadlines = storageService.getDeadlines();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    _tasks.insert(0, task);
    await storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await storageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newStatus = !task.isCompleted;
      // Also update subtasks if completing the main task
      final updatedSubtasks = task.subtasks.map((st) => st.copyWith(isDone: newStatus)).toList();
      _tasks[index] = task.copyWith(
        isCompleted: newStatus,
        subtasks: updatedSubtasks,
      );
      await storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedSubtasks = task.subtasks.map((st) {
        if (st.id == subTaskId) {
          return st.copyWith(isDone: !st.isDone);
        }
        return st;
      }).toList();

      final allDone = updatedSubtasks.isNotEmpty && updatedSubtasks.every((st) => st.isDone);
      _tasks[index] = task.copyWith(
        subtasks: updatedSubtasks,
        isCompleted: allDone,
      );
      await storageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  // --- Deadlines methods ---
  Future<void> addDeadline(DeadlineModel deadline) async {
    _deadlines.add(deadline);
    await storageService.saveDeadlines(_deadlines);
    notifyListeners();
  }

  Future<void> updateDeadline(DeadlineModel deadline) async {
    final index = _deadlines.indexWhere((d) => d.id == deadline.id);
    if (index != -1) {
      _deadlines[index] = deadline;
      await storageService.saveDeadlines(_deadlines);
      notifyListeners();
    }
  }

  Future<void> deleteDeadline(String id) async {
    _deadlines.removeWhere((d) => d.id == id);
    await storageService.saveDeadlines(_deadlines);
    notifyListeners();
  }

  Future<void> toggleDeadlineCompletion(String id) async {
    final index = _deadlines.indexWhere((d) => d.id == id);
    if (index != -1) {
      final deadline = _deadlines[index];
      _deadlines[index] = deadline.copyWith(isCompleted: !deadline.isCompleted);
      await storageService.saveDeadlines(_deadlines);
      notifyListeners();
    }
  }
}
