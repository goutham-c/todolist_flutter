# OmniFocus: All-In-One Flutter Productivity & Study Suite 🚀

An all-in-one Flutter application integrating the best features from 11 open-source Flutter productivity, timer, and note-taking applications into a unified, responsive, Material 3 application.

---

## 📱 Features Mapped to Open-Source Inspirations

| Project | Original Repo | Feature Integrated |
| :--- | :--- | :--- |
| **Break.Down.Timer** | [jenspfahl/bdt](https://github.com/jenspfahl/bdt) | **Interval Break Notifications**: Define scheduled break notifications (e.g. hydrate, stretch) while a focus session is running. |
| **DeadlinesApp** | [emmanuelmess/deadlinesapp](https://github.com/emmanuelmess/deadlinesapp) | **Deadlines Countdown Tracker**: Dedicated countdown cards showing remaining days/hours, urgency color flags (Overdue, Due Soon, Upcoming), and course/project grouping. |
| **Deer** | [aleksanderwozniak/deer](https://github.com/aleksanderwozniak/deer) | **Minimalist Todos**: Fast task management, category chips, check-off animations, and search filtering. |
| **Everyday Tasks** | [jenspfahl/everydaytasks](https://github.com/jenspfahl/everydaytasks) | **Habit & Routine Tracker**: Daily check-in logging, current & best streak tracking, and 7-day completion matrices. |
| **FlipCard** | [fiqryx/flipcard](https://github.com/fiqryx/flipcard) | **3D FlipCard Memorization**: Interactive flashcards with realistic 3D perspective flip animations and spaced repetition rating (Again, Hard, Good, Easy). |
| **flutter_notes_app** | [31Carlton7/flutter_notes_app](https://github.com/31Carlton7/flutter_notes_app) | **Color-Coded Notes**: Note creation with vibrant pastel palettes, tag filtering, and real-time search. |
| **Flutter-Pomodoro** | [wilsonowilson/Flutter-Pomodoro](https://github.com/wilsonowilson/Flutter-Pomodoro) | **Pomodoro Timer**: 25m Focus, 5m Short Break, 15m Long Break cycles, round counters, and circular animated progress. |
| **GitJournal** | [gitjournal/gitjournal](https://github.com/gitjournal/gitjournal) | **Markdown Support**: Rich markdown parsing & live preview toggle (`# Headers`, `- [ ] Checklists`, bullet points). |
| **Glory Todo Desktop** | [yessglory17/glory_todo_desktop](https://github.com/yessglory17/glory_todo_desktop) | **Task Priorities & Subtasks**: Urgent/High/Medium/Low priority flags and nested subtask checklists inside tasks. |
| **Jiyi** | [xiaoshihou514/jiyi](https://github.com/xiaoshihou514/jiyi) | **Encrypted Voice Notes**: Live voice recording simulation with pulsing waveform animations and playback durations. |
| **kardi notes** | [rikodot/kardi_notes_app](https://github.com/rikodot/kardi_notes_app) | **PIN-Protected Vault & Pinning**: Pin sensitive notes into a secure vault unlocked by a 4-digit PIN, with top-pinning support. |

---

## 🏗️ Architecture (Separation of Concerns)

The application follows the layered architecture recommended by the official Flutter guidelines:

```text
lib/
├── main.dart                                    # App entrypoint, AppScope DI, Material 3 themes
├── core/
│   ├── app_scope.dart                           # Top-level state and dependency injection
│   ├── theme/
│   │   └── app_theme.dart                       # Material 3 light & dark theme palettes
│   ├── utils/
│   │   └── formatters.dart                      # Date, countdown, timer, and key formatters
│   └── services/
│       └── storage_service.dart                 # Local persistence using shared_preferences
└── features/
    ├── home/
    │   └── views/
    │       └── main_navigation_screen.dart      # Unified dashboard & responsive navigation
    ├── notes/
    │   ├── models/note_model.dart               # Notes, voice memos, tags, markdown, and vault
    │   ├── view_models/notes_view_model.dart    # Search, pin, vault security, audio recording
    │   └── views/
    │       ├── notes_screen.dart                # Filterable notes grid & vault unlock
    │       └── note_editor_screen.dart          # Markdown preview & voice recorder
    ├── tasks_deadlines/
    │   ├── models/task_model.dart               # Tasks, subtasks, priorities, and deadlines
    │   ├── view_models/tasks_view_model.dart    # Filtering, completion, and urgency calculation
    │   └── views/tasks_screen.dart              # Tabs for Deer Todos & DeadlinesApp Countdowns
    ├── habits_everyday/
    │   ├── models/habit_model.dart              # Routines, streak metrics, 7-day logs
    │   ├── view_models/habits_view_model.dart   # Daily check-in & completion rate
    │   └── views/habits_screen.dart             # Daily progress ring & streak cards
    ├── focus_timer/
    │   ├── models/timer_model.dart              # Pomodoro cycles & Break.Down checkpoints
    │   ├── view_models/timer_view_model.dart    # Countdown ticker & break notifications
    │   └── views/timer_screen.dart              # Circular timer & Break.Down.Timer alert banner
    └── flashcards/
        ├── models/flashcard_model.dart          # Decks, cards, and spaced repetition mastery
        ├── view_models/flashcards_view_model.dart # Session management & rating calculation
        └── views/
            ├── flashcards_screen.dart           # Deck list & card creation
            └── study_session_screen.dart        # 3D card flip animation & mastery evaluation
```

---

## 🧪 Testing & Code Quality

- **Static Analysis**: Verified with `flutter analyze` (**0 issues found**).
- **Unit & Widget Tests**: Located in `test/widget_test.dart` and `test/view_models_test.dart` (**All tests passing**).

### Running Tests
```bash
flutter test
```

### Running the App
```bash
# Run on Windows Desktop
flutter run -d windows

# Run on Chrome
flutter run -d chrome
```
