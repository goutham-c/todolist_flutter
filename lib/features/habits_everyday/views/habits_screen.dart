import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../view_models/habits_view_model.dart';
import '../../../core/utils/formatters.dart';

class HabitsScreen extends StatefulWidget {
  final HabitsViewModel viewModel;

  const HabitsScreen({super.key, required this.viewModel});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    final categoryController = TextEditingController(text: 'Routine');
    int targetDays = 7;
    int selectedColor = 0xFF10B981; // Green

    final colors = [
      0xFF10B981, // Emerald
      0xFF6366F1, // Indigo
      0xFFF59E0B, // Amber
      0xFFEC4899, // Pink
      0xFF06B6D4, // Cyan
      0xFF8B5CF6, // Purple
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Everyday Habit / Routine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Habit Name * (e.g. Read 20 pages)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category (e.g. Health, Study)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Theme Color', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: colors.map((c) {
                  final isSel = selectedColor == c;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: isSel ? Border.all(color: Colors.white, width: 3) : null,
                        boxShadow: isSel ? [const BoxShadow(color: Colors.black26, blurRadius: 4)] : null,
                      ),
                      child: isSel ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(selectedColor),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    widget.viewModel.addHabit(
                      HabitModel(
                        id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        category: categoryController.text.trim().isEmpty ? 'Routine' : categoryController.text.trim(),
                        colorValue: selectedColor,
                        targetDaysPerWeek: targetDays,
                        createdAt: DateTime.now(),
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Add Everyday Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final habits = widget.viewModel.habits;
        final completionRate = widget.viewModel.todayCompletionRate;
        final todayDone = widget.viewModel.todayCompletedCount;
        final todayKey = Formatters.formatDateKey(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            title: const Text('Everyday Tasks & Habits 🔄'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            children: [
              // Daily Progress Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withAlpha(60),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Routine',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$todayDone of ${habits.length} Completed',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            completionRate >= 1.0 ? '🎉 All tasks done for today!' : 'Keep building your daily momentum!',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: completionRate,
                            strokeWidth: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          Center(
                            child: Text(
                              '${(completionRate * 100).toInt()}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Habits List
              if (habits.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No everyday tasks set up yet.'),
                  ),
                )
              else
                ...habits.map((h) => _buildHabitCard(h, todayKey)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'habits_fab',
            onPressed: _showAddHabitDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Routine'),
          ),
        );
      },
    );
  }

  Widget _buildHabitCard(HabitModel habit, String todayKey) {
    final isDoneToday = habit.isCompletedOn(todayKey);
    final habitColor = Color(habit.colorValue);

    // Build last 7 days keys
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return {
        'date': d,
        'key': Formatters.formatDateKey(d),
        'label': ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d.weekday - 1],
      };
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category, Title, Check-in Button
            Row(
              children: [
                Container(
                  width: 10,
                  height: 36,
                  decoration: BoxDecoration(
                    color: habitColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.category.toUpperCase(),
                        style: TextStyle(color: habitColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        habit.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () => widget.viewModel.deleteHabit(habit.id),
                ),
                const SizedBox(width: 4),
                // Today's toggle button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDoneToday ? habitColor : Colors.grey.withAlpha(40),
                    foregroundColor: isDoneToday ? Colors.white : Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: () => widget.viewModel.toggleHabitToday(habit.id),
                  icon: Icon(isDoneToday ? Icons.check_circle : Icons.radio_button_unchecked, size: 16),
                  label: Text(isDoneToday ? 'Done' : 'Check In', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Streak Badges & Last 7 Days dots
            Row(
              children: [
                // Streak indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak} day streak',
                        style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Best: ${habit.bestStreak}d',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const Spacer(),
                // 7-day indicator dots
                Row(
                  children: last7Days.map((item) {
                    final key = item['key'] as String;
                    final label = item['label'] as String;
                    final isCompleted = habit.isCompletedOn(key);
                    final isCurrentDay = key == todayKey;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                              color: isCurrentDay ? habitColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted ? habitColor : Colors.grey.withAlpha(50),
                              border: isCurrentDay ? Border.all(color: habitColor, width: 1.5) : null,
                            ),
                            child: isCompleted
                                ? const Icon(Icons.check, size: 10, color: Colors.white)
                                : null,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
