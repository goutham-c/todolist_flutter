import 'package:flutter/material.dart';
import '../../../core/app_scope.dart';
import '../../notes/views/notes_screen.dart';
import '../../tasks_deadlines/views/tasks_screen.dart';
import '../../habits_everyday/views/habits_screen.dart';
import '../../focus_timer/views/timer_screen.dart';
import '../../flashcards/views/flashcards_screen.dart';
import '../../../core/utils/formatters.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _showAppCreditsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.hub, color: Colors.indigo),
            SizedBox(width: 8),
            Text('OmniFocus Suite'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This All-In-One Flutter application unifies 11 notable open-source Flutter productivity apps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Break.Down.Timer - Interval break notifications in timer'),
              Text('• DeadlinesApp - Due date countdowns & urgency tags'),
              Text('• Deer - Minimalist BLoC-inspired Todo list'),
              Text('• Everyday Tasks - Habit tracking & streak logging'),
              Text('• FlipCard - 3D Flashcard spaced repetition'),
              Text('• flutter_notes_app - Color coded note taking'),
              Text('• Flutter-Pomodoro - Pomodoro focus cycles'),
              Text('• GitJournal - Markdown preview & checklists'),
              Text('• Glory Todo Desktop - Task priorities & subtasks'),
              Text('• Jiyi - Encrypted voice memo recording'),
              Text('• kardi notes - PIN-secured vault & tag organization'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(AppController controller) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Vault PIN'),
        content: TextField(
          controller: pinController,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter new 4-digit PIN',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                controller.storageService.setVaultPin(pin);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vault PIN updated!')),
                );
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final isDark = controller.isDarkMode;

    final screens = [
      _buildDashboardView(controller),
      NotesScreen(viewModel: controller.notesViewModel),
      TasksScreen(viewModel: controller.tasksViewModel),
      HabitsScreen(viewModel: controller.habitsViewModel),
      TimerScreen(viewModel: controller.timerViewModel),
      FlashcardsScreen(viewModel: controller.flashcardsViewModel),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.indigo, size: 24),
            SizedBox(width: 8),
            Text('OmniFocus', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'App Ecosystem & Credits',
            icon: const Icon(Icons.info_outline),
            onPressed: _showAppCreditsDialog,
          ),
          IconButton(
            tooltip: 'Change Vault PIN',
            icon: const Icon(Icons.security),
            onPressed: () => _showChangePinDialog(controller),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: controller.toggleDarkMode,
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.repeat_outlined),
            selectedIcon: Icon(Icons.repeat),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
            label: 'FlipCards',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(AppController controller) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.notesViewModel,
        controller.tasksViewModel,
        controller.habitsViewModel,
        controller.timerViewModel,
        controller.flashcardsViewModel,
      ]),
      builder: (context, _) {
        final notes = controller.notesViewModel.notes;
        final tasks = controller.tasksViewModel.tasks;
        final upcomingDeadlines = controller.tasksViewModel.deadlines.where((d) => !d.isCompleted).toList();
        final habitRate = controller.habitsViewModel.todayCompletionRate;
        final decks = controller.flashcardsViewModel.decks;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Hero Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ALL-IN-ONE PRODUCTIVITY',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.formatDate(DateTime.now()),
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome back!',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your unified workspace for notes, deadlines, everyday tasks, pomodoro focus, and flipcard memorization.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildQuickMetric(
                    title: 'Active Tasks',
                    count: '${tasks.where((t) => !t.isCompleted).length}',
                    icon: Icons.check_circle_outline,
                    color: Colors.indigo,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickMetric(
                    title: 'Deadlines',
                    count: '${upcomingDeadlines.length}',
                    icon: Icons.alarm,
                    color: Colors.orange,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickMetric(
                    title: 'Habit Routine',
                    count: '${(habitRate * 100).toInt()}% Done',
                    icon: Icons.repeat,
                    color: const Color(0xFF10B981),
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickMetric(
                    title: 'FlipCard Decks',
                    count: '${decks.length}',
                    icon: Icons.style,
                    color: Colors.purple,
                    onTap: () => setState(() => _currentIndex = 5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section 1: Imminent Deadlines (DeadlinesApp)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Urgent Deadlines ⏳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 2),
                  child: const Text('View All'),
                ),
              ],
            ),
            if (upcomingDeadlines.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No upcoming deadlines! You\'re fully on track.'),
                ),
              )
            else
              ...upcomingDeadlines.take(2).map((dl) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFEE2E2),
                      child: Icon(Icons.timer, color: Colors.red, size: 20),
                    ),
                    title: Text(dl.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(dl.courseOrProject),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        Formatters.formatCountdown(dl.targetDate),
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Section 2: Quick Launch Focus Timer (Flutter-Pomodoro & Break.Down.Timer)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFE0E7FF),
                      child: Icon(Icons.play_arrow, color: Colors.indigo, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ready for Deep Work?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 2),
                          Text('Start Pomodoro (25m) or Break.Down.Timer (50m)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                      onPressed: () => setState(() => _currentIndex = 4),
                      child: const Text('Start'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: Recent Notes & Vault (Jiyi & kardi notes)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Notes & Voice Vault 🎙️', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 1),
                  child: const Text('View All'),
                ),
              ],
            ),
            ...notes.take(2).map((n) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(n.colorValue),
                    child: Icon(n.hasVoiceMemo ? Icons.mic : (n.isLocked ? Icons.lock : Icons.note), size: 20, color: Colors.indigo),
                  ),
                  title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    n.isLocked ? 'Encrypted note' : n.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: n.isPinned ? const Icon(Icons.push_pin, size: 16, color: Colors.indigo) : null,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildQuickMetric({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
