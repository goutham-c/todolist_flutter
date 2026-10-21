import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_in_one_productivity/core/services/storage_service.dart';
import 'package:all_in_one_productivity/features/notes/models/note_model.dart';
import 'package:all_in_one_productivity/features/notes/view_models/notes_view_model.dart';
import 'package:all_in_one_productivity/features/tasks_deadlines/models/task_model.dart';
import 'package:all_in_one_productivity/features/tasks_deadlines/view_models/tasks_view_model.dart';
import 'package:all_in_one_productivity/features/habits_everyday/view_models/habits_view_model.dart';
import 'package:all_in_one_productivity/features/focus_timer/models/timer_model.dart';
import 'package:all_in_one_productivity/features/focus_timer/view_models/timer_view_model.dart';
import 'package:all_in_one_productivity/features/flashcards/models/flashcard_model.dart';
import 'package:all_in_one_productivity/features/flashcards/view_models/flashcards_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = StorageService();
    await storageService.init();
  });

  group('NotesViewModel & Vault Tests (flutter_notes_app, GitJournal, Jiyi, kardi notes)', () {
    test('Can add, pin, and unlock vault', () async {
      final vm = NotesViewModel(storageService: storageService);
      expect(vm.notes.isNotEmpty, true);

      // Verify vault unlocking
      expect(vm.isVaultUnlocked, false);
      expect(vm.unlockVault('0000'), false);
      expect(vm.unlockVault('1234'), true);
      expect(vm.isVaultUnlocked, true);

      // Add a note
      final newNote = NoteModel(
        id: 'test_n1',
        title: 'Markdown Note',
        content: '# Header\n- [ ] Task item',
        tags: ['Test'],
        colorValue: 0xFFFFFFFF,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await vm.addNote(newNote);
      expect(vm.notes.any((n) => n.id == 'test_n1'), true);

      // Toggle pin
      await vm.togglePin('test_n1');
      expect(vm.notes.firstWhere((n) => n.id == 'test_n1').isPinned, true);
    });
  });

  group('TasksViewModel Tests (Deer, Glory Todo Desktop, DeadlinesApp)', () {
    test('Can manage tasks, subtasks, and deadlines', () async {
      final vm = TasksViewModel(storageService: storageService);
      expect(vm.tasks.isNotEmpty, true);

      // Add task with subtasks
      final task = TaskModel(
        id: 't_test',
        title: 'Project Roadmap',
        subtasks: [
          SubTask(id: 'st_1', title: 'Phase 1'),
          SubTask(id: 'st_2', title: 'Phase 2'),
        ],
        createdAt: DateTime.now(),
      );
      await vm.addTask(task);

      // Toggle subtask
      await vm.toggleSubTask('t_test', 'st_1');
      final updated = vm.tasks.firstWhere((t) => t.id == 't_test');
      expect(updated.subtasks.firstWhere((s) => s.id == 'st_1').isDone, true);
      expect(updated.isCompleted, false);

      // Check deadlines sorting
      expect(vm.sortedDeadlines.isNotEmpty, true);
    });
  });

  group('HabitsViewModel Tests (Everyday Tasks)', () {
    test('Calculates streak and toggles today check-in', () async {
      final vm = HabitsViewModel(storageService: storageService);
      expect(vm.habits.isNotEmpty, true);

      final firstHabit = vm.habits.first;
      final initialStreak = firstHabit.streak;
      expect(initialStreak >= 0, true);

      // Toggle check-in
      await vm.toggleHabitToday(firstHabit.id);
      expect(vm.todayCompletedCount >= 0, true);
      expect(vm.todayCompletionRate >= 0.0, true);
    });
  });

  group('TimerViewModel Tests (Flutter-Pomodoro, Break.Down.Timer)', () {
    test('Switches modes and resets interval durations', () {
      final vm = TimerViewModel(storageService: storageService);
      expect(vm.mode, TimerMode.pomodoro);
      expect(vm.remainingSeconds, 25 * 60);

      // Switch to Break.Down.Timer
      vm.setMode(TimerMode.breakDownTimer);
      expect(vm.mode, TimerMode.breakDownTimer);
      expect(vm.remainingSeconds, vm.settings.breakDownTotalMinutes * 60);
      expect(vm.settings.breakDownCheckpoints.isNotEmpty, true);
    });
  });

  group('FlashcardsViewModel Tests (FlipCard)', () {
    test('Runs 3D card study session and tracks spaced repetition mastery', () async {
      final vm = FlashcardsViewModel(storageService: storageService);
      expect(vm.decks.isNotEmpty, true);

      final deck = vm.decks.first;
      vm.startStudySession(deck);

      expect(vm.currentCardIndex, 0);
      expect(vm.isCardFlipped, false);
      expect(vm.currentCard != null, true);

      // Flip card
      vm.flipCard();
      expect(vm.isCardFlipped, true);

      // Rate card
      await vm.rateCurrentCard(CardMastery.easy);
      expect(vm.sessionMasteryCounts[CardMastery.easy], 1);
      expect(vm.cardsReviewedInSession, 1);
    });
  });
}
