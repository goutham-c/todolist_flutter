import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/notes/models/note_model.dart';
import '../../features/tasks_deadlines/models/task_model.dart';
import '../../features/habits_everyday/models/habit_model.dart';
import '../../features/flashcards/models/flashcard_model.dart';
import '../../features/focus_timer/models/timer_model.dart';
import '../utils/formatters.dart';

class StorageService {
  static const String _notesKey = 'omni_notes_data';
  static const String _tasksKey = 'omni_tasks_data';
  static const String _deadlinesKey = 'omni_deadlines_data';
  static const String _habitsKey = 'omni_habits_data';
  static const String _decksKey = 'omni_decks_data';
  static const String _vaultPinKey = 'omni_vault_pin';
  static const String _isDarkModeKey = 'omni_is_dark_mode';
  static const String _timerSettingsKey = 'omni_timer_settings';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Theme & PIN ---
  bool get isDarkMode => _prefs.getBool(_isDarkModeKey) ?? false;
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_isDarkModeKey, value);
  }

  String get vaultPin => _prefs.getString(_vaultPinKey) ?? '1234';
  Future<void> setVaultPin(String pin) async {
    await _prefs.setString(_vaultPinKey, pin);
  }

  // --- Notes ---
  List<NoteModel> getNotes() {
    final raw = _prefs.getString(_notesKey);
    if (raw == null || raw.isEmpty) {
      final initial = _getInitialNotes();
      saveNotes(initial);
      return initial;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => NoteModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialNotes();
    }
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    final raw = jsonEncode(notes.map((n) => n.toJson()).toList());
    await _prefs.setString(_notesKey, raw);
  }

  // --- Tasks ---
  List<TaskModel> getTasks() {
    final raw = _prefs.getString(_tasksKey);
    if (raw == null || raw.isEmpty) {
      final initial = _getInitialTasks();
      saveTasks(initial);
      return initial;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialTasks();
    }
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_tasksKey, raw);
  }

  // --- Deadlines ---
  List<DeadlineModel> getDeadlines() {
    final raw = _prefs.getString(_deadlinesKey);
    if (raw == null || raw.isEmpty) {
      final initial = _getInitialDeadlines();
      saveDeadlines(initial);
      return initial;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => DeadlineModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialDeadlines();
    }
  }

  Future<void> saveDeadlines(List<DeadlineModel> deadlines) async {
    final raw = jsonEncode(deadlines.map((d) => d.toJson()).toList());
    await _prefs.setString(_deadlinesKey, raw);
  }

  // --- Habits ---
  List<HabitModel> getHabits() {
    final raw = _prefs.getString(_habitsKey);
    if (raw == null || raw.isEmpty) {
      final initial = _getInitialHabits();
      saveHabits(initial);
      return initial;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => HabitModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialHabits();
    }
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    final raw = jsonEncode(habits.map((h) => h.toJson()).toList());
    await _prefs.setString(_habitsKey, raw);
  }

  // --- Flashcard Decks ---
  List<DeckModel> getDecks() {
    final raw = _prefs.getString(_decksKey);
    if (raw == null || raw.isEmpty) {
      final initial = _getInitialDecks();
      saveDecks(initial);
      return initial;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => DeckModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getInitialDecks();
    }
  }

  Future<void> saveDecks(List<DeckModel> decks) async {
    final raw = jsonEncode(decks.map((d) => d.toJson()).toList());
    await _prefs.setString(_decksKey, raw);
  }

  // --- Timer Settings ---
  TimerSettings getTimerSettings() {
    final raw = _prefs.getString(_timerSettingsKey);
    if (raw == null || raw.isEmpty) {
      return TimerSettings();
    }
    try {
      return TimerSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return TimerSettings();
    }
  }

  Future<void> saveTimerSettings(TimerSettings settings) async {
    final raw = jsonEncode(settings.toJson());
    await _prefs.setString(_timerSettingsKey, raw);
  }

  // ================= DEMO SEED DATA =================
  List<NoteModel> _getInitialNotes() {
    final now = DateTime.now();
    return [
      NoteModel(
        id: 'note_1',
        title: 'Project Architecture & Goals 🚀',
        content: '# All-in-One Productivity & Study Suite\n\n'
            'Unified ecosystem combining:\n'
            '- **Deer**: Minimalist Todo & task planning\n'
            '- **DeadlinesApp**: Urgency-driven countdowns\n'
            '- **Everyday Tasks**: Habit & routine tracking\n'
            '- **Flutter-Pomodoro & Break.Down.Timer**: Smart intervals\n'
            '- **FlipCard**: Spaced repetition memorization\n'
            '- **Jiyi & kardi notes**: Encrypted voice memos & secure vault\n\n'
            '### Next Steps\n'
            '- [x] Model design\n'
            '- [x] Local storage integration\n'
            '- [ ] Polished animations\n',
        tags: ['Architecture', 'Flutter', 'Milestones'],
        colorValue: 0xFFE0E7FF, // Soft Indigo
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now,
        isPinned: true,
      ),
      NoteModel(
        id: 'note_2',
        title: 'Brainstorm: Voice Memo 🎙️ (Jiyi style)',
        content: 'Recorded audio memo regarding app launch strategy and UI feedback.\n'
            'Tap play below to preview simulated encrypted voice recording.',
        tags: ['Audio', 'Encrypted', 'Ideas'],
        colorValue: 0xFFFEF3C7, // Soft Amber
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        isPinned: false,
        hasVoiceMemo: true,
        voiceDurationSeconds: 42,
        voiceWaveform: [0.3, 0.6, 0.9, 0.4, 0.8, 1.0, 0.5, 0.7, 0.9, 0.3, 0.6, 0.8, 0.4, 0.9, 0.6, 0.4, 0.7, 0.3],
      ),
      NoteModel(
        id: 'note_3',
        title: 'Confidential: Vault Passwords & Keys 🔒',
        content: 'API Access Token: sk_live_892348923402934\nMaster Passphrase: correct horse battery staple',
        tags: ['Security', 'Vault'],
        colorValue: 0xFFFCE7F3, // Soft Pink
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now,
        isPinned: true,
        isLocked: true,
      ),
    ];
  }

  List<TaskModel> _getInitialTasks() {
    final now = DateTime.now();
    return [
      TaskModel(
        id: 'task_1',
        title: 'Finalize Flutter Mobile UI Architecture',
        description: 'Complete MVVM implementation with smooth animations and responsive widgets.',
        priority: TaskPriority.urgent,
        category: 'Development',
        dueDate: now.add(const Duration(days: 1)),
        subtasks: [
          SubTask(id: 'st_1', title: 'Setup theme switcher & responsive layout', isDone: true),
          SubTask(id: 'st_2', title: 'Implement local persistence via shared_preferences', isDone: true),
          SubTask(id: 'st_3', title: 'Add 3D FlipCard interactive study mode', isDone: false),
        ],
        createdAt: now,
      ),
      TaskModel(
        id: 'task_2',
        title: 'Review Machine Learning & Algorithms deck',
        description: 'Go through 15 flashcards in the FlipCard module.',
        priority: TaskPriority.high,
        category: 'Study',
        dueDate: now.add(const Duration(days: 2)),
        subtasks: [
          SubTask(id: 'st_4', title: 'Review 10 flashcards', isDone: false),
          SubTask(id: 'st_5', title: 'Score at least 80% mastery', isDone: false),
        ],
        createdAt: now,
      ),
      TaskModel(
        id: 'task_3',
        title: 'Weekly grocery & meal prep',
        description: 'Organic vegetables, almond milk, and protein oats.',
        priority: TaskPriority.low,
        category: 'Personal',
        dueDate: now.add(const Duration(days: 4)),
        subtasks: [],
        createdAt: now,
      ),
    ];
  }

  List<DeadlineModel> _getInitialDeadlines() {
    final now = DateTime.now();
    return [
      DeadlineModel(
        id: 'dl_1',
        title: 'Final Project Submission & Demo',
        courseOrProject: 'Mobile App Engineering',
        targetDate: now.add(const Duration(days: 2, hours: 14)),
        note: 'Submit APK, GitHub repository link, and video walkthrough.',
        priority: TaskPriority.urgent,
      ),
      DeadlineModel(
        id: 'dl_2',
        title: 'Productivity Suite Beta Release',
        courseOrProject: 'Open Source Launch',
        targetDate: now.add(const Duration(days: 6, hours: 8)),
        note: 'Tag v1.0.0 on GitHub, attach release notes.',
        priority: TaskPriority.high,
      ),
      DeadlineModel(
        id: 'dl_3',
        title: 'Research Paper Proposal Review',
        courseOrProject: 'Academic Track',
        targetDate: now.add(const Duration(days: 14)),
        note: 'Review peer feedback and submit revised proposal.',
        priority: TaskPriority.medium,
      ),
    ];
  }

  List<HabitModel> _getInitialHabits() {
    final now = DateTime.now();
    final todayKey = Formatters.formatDateKey(now);
    final yesterdayKey = Formatters.formatDateKey(now.subtract(const Duration(days: 1)));
    final twoDaysAgoKey = Formatters.formatDateKey(now.subtract(const Duration(days: 2)));

    return [
      HabitModel(
        id: 'habit_1',
        title: 'Morning Workout & Stretch',
        category: 'Health',
        colorValue: 0xFF10B981,
        iconCode: 'fitness_center',
        completedDates: [twoDaysAgoKey, yesterdayKey, todayKey],
        streak: 3,
        bestStreak: 14,
        targetDaysPerWeek: 7,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      HabitModel(
        id: 'habit_2',
        title: 'Read 25 Pages of a Book',
        category: 'Personal Growth',
        colorValue: 0xFF6366F1,
        iconCode: 'menu_book',
        completedDates: [yesterdayKey],
        streak: 1,
        bestStreak: 21,
        targetDaysPerWeek: 6,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
      HabitModel(
        id: 'habit_3',
        title: 'Deep Work Focus Session (Pomodoro)',
        category: 'Productivity',
        colorValue: 0xFFF59E0B,
        iconCode: 'timer',
        completedDates: [twoDaysAgoKey, yesterdayKey, todayKey],
        streak: 3,
        bestStreak: 12,
        targetDaysPerWeek: 5,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      HabitModel(
        id: 'habit_4',
        title: 'Drink 2.5 Liters of Water',
        category: 'Health',
        colorValue: 0xFF06B6D4,
        iconCode: 'water_drop',
        completedDates: [twoDaysAgoKey, yesterdayKey],
        streak: 2,
        bestStreak: 30,
        targetDaysPerWeek: 7,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  List<DeckModel> _getInitialDecks() {
    final now = DateTime.now();
    return [
      DeckModel(
        id: 'deck_1',
        title: 'Flutter & Dart Mastery 💙',
        description: 'Key Flutter architecture, state management, and Dart patterns.',
        category: 'Computer Science',
        colorValue: 0xFF0284C7,
        createdAt: now,
        cards: [
          Flashcard(
            id: 'c_1',
            front: 'What is the purpose of BuildContext in Flutter?',
            back: 'A handle to the location of a widget in the widget tree, used to locate ancestors, theme, and media queries.',
            mastery: CardMastery.good,
            reviewCount: 3,
          ),
          Flashcard(
            id: 'c_2',
            front: 'What is the difference between hot reload and hot restart?',
            back: 'Hot reload injects updated source code files into the running Dart VM preserving state. Hot restart destroys state and re-runs main().',
            mastery: CardMastery.easy,
            reviewCount: 4,
          ),
          Flashcard(
            id: 'c_3',
            front: 'What is the BLoC pattern?',
            back: 'Business Logic Component pattern separates presentation from business logic using reactive Streams or ChangeNotifiers.',
            mastery: CardMastery.good,
            reviewCount: 2,
          ),
          Flashcard(
            id: 'c_4',
            front: 'What is the role of Keys in Flutter?',
            back: 'Keys preserve state when widgets move around in the widget tree, crucial when modifying collections of stateful widgets.',
            mastery: CardMastery.hard,
            reviewCount: 1,
          ),
        ],
      ),
      DeckModel(
        id: 'deck_2',
        title: 'Data Structures & Algorithms ⚡',
        description: 'Time complexities, trees, graphs, and dynamic programming fundamentals.',
        category: 'Interviews',
        colorValue: 0xFF8B5CF6,
        createdAt: now,
        cards: [
          Flashcard(
            id: 'd_1',
            front: 'What is the average and worst-case time complexity of QuickSort?',
            back: 'Average: O(n log n). Worst-case: O(n²) when the pivot selection is unbalanced.',
            mastery: CardMastery.good,
            reviewCount: 5,
          ),
          Flashcard(
            id: 'd_2',
            front: 'Explain the difference between BFS and DFS traversal.',
            back: 'BFS explores level-by-level using a Queue (FIFO). DFS explores branch-by-branch deeply using a Stack (LIFO) or recursion.',
            mastery: CardMastery.easy,
            reviewCount: 4,
          ),
          Flashcard(
            id: 'd_3',
            front: 'What is a Trie and what are its common use cases?',
            back: 'A tree-like data structure used to store strings efficiently, commonly used for autocomplete, spell check, and IP routing.',
            mastery: CardMastery.learning,
            reviewCount: 2,
          ),
        ],
      ),
    ];
  }
}
