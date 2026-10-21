import 'package:flutter/material.dart';
import '../models/timer_model.dart';
import '../view_models/timer_view_model.dart';
import '../../../core/utils/formatters.dart';

class TimerScreen extends StatefulWidget {
  final TimerViewModel viewModel;

  const TimerScreen({super.key, required this.viewModel});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  void _showBreakDownConfigDialog() {
    final settings = widget.viewModel.settings;
    final totalMinutesController = TextEditingController(text: settings.breakDownTotalMinutes.toString());
    final labelController = TextEditingController();
    final atMinutesController = TextEditingController();

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Break.Down.Timer Setup ⏱️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Define custom intermediate breaks while the long timer runs (Break.Down.Timer pattern).',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: totalMinutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Session Duration (Minutes)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Scheduled Intermediate Breaks:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...settings.breakDownCheckpoints.map((cp) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.notifications_active, color: Colors.amber, size: 20),
                      title: Text(cp.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('At ${cp.triggerAtSecond ~/ 60}m remaining (${cp.durationSeconds ~/ 60}m break)'),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Text('Add New Break Notification:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: labelController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Eye rest & water',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: atMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'At min',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final label = labelController.text.trim();
                        final min = int.tryParse(atMinutesController.text.trim());
                        if (label.isNotEmpty && min != null) {
                          setModalState(() {
                            settings.breakDownCheckpoints.add(
                              BreakCheckpoint(
                                label: label,
                                triggerAtSecond: min * 60,
                                durationSeconds: 120,
                              ),
                            );
                            labelController.clear();
                            atMinutesController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () {
                      final totalMin = int.tryParse(totalMinutesController.text.trim()) ?? 50;
                      widget.viewModel.updateSettings(
                        TimerSettings(
                          pomodoroMinutes: settings.pomodoroMinutes,
                          shortBreakMinutes: settings.shortBreakMinutes,
                          longBreakMinutes: settings.longBreakMinutes,
                          breakDownTotalMinutes: totalMin,
                          breakDownCheckpoints: settings.breakDownCheckpoints,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save Timer Configuration', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
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
        final mode = widget.viewModel.mode;
        final isRunning = widget.viewModel.isRunning;
        final progress = widget.viewModel.progress;
        final remainingSeconds = widget.viewModel.remainingSeconds;
        final alert = widget.viewModel.activeBreakNotification;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Focus & Break Timer ⏱️'),
            actions: [
              IconButton(
                tooltip: 'Configure Break.Down.Timer',
                icon: const Icon(Icons.tune),
                onPressed: _showBreakDownConfigDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Mode Selection Segmented Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModeChip(TimerMode.pomodoro, 'Pomodoro (25m)', Icons.psychology),
                        const SizedBox(width: 8),
                        _buildModeChip(TimerMode.shortBreak, 'Short Break (5m)', Icons.coffee),
                        const SizedBox(width: 8),
                        _buildModeChip(TimerMode.longBreak, 'Long Break (15m)', Icons.nature_people),
                        const SizedBox(width: 8),
                        _buildModeChip(TimerMode.breakDownTimer, 'Break.Down (50m)', Icons.splitscreen),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Break Alert Banner (Break.Down.Timer feature)
                  if (alert != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        border: Border.all(color: Colors.amber.shade700, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.amber, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BREAK NOTIFICATION! 🔔',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  alert.label,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () {
                              widget.viewModel.dismissBreakAlert();
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),

                  // Circular Countdown Indicator
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.indigo.withAlpha(30),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            mode == TimerMode.pomodoro
                                ? Colors.indigo
                                : mode == TimerMode.breakDownTimer
                                    ? Colors.cyan
                                    : Colors.teal,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Formatters.formatTimerSeconds(remainingSeconds),
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                mode == TimerMode.pomodoro
                                    ? 'FOCUS SESSION'
                                    : mode == TimerMode.breakDownTimer
                                        ? 'BREAK.DOWN RUNNING'
                                        : 'RECHARGE TIME',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              if (mode == TimerMode.pomodoro) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Round #${widget.viewModel.completedPomodoroRounds + 1}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Control Buttons: Start, Pause, Reset
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset button
                      IconButton.filledTonal(
                        iconSize: 28,
                        icon: const Icon(Icons.refresh),
                        onPressed: widget.viewModel.resetTimer,
                      ),
                      const SizedBox(width: 24),
                      // Play/Pause button
                      IconButton.filled(
                        iconSize: 42,
                        style: IconButton.styleFrom(
                          backgroundColor: isRunning ? Colors.orange : Colors.indigo,
                          padding: const EdgeInsets.all(18),
                        ),
                        icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                        onPressed: () {
                          if (isRunning) {
                            widget.viewModel.pauseTimer();
                          } else {
                            widget.viewModel.startTimer();
                          }
                        },
                      ),
                      const SizedBox(width: 24),
                      // Skip / Settings button
                      IconButton.filledTonal(
                        iconSize: 28,
                        icon: const Icon(Icons.skip_next),
                        onPressed: () {
                          widget.viewModel.setMode(
                            mode == TimerMode.pomodoro ? TimerMode.shortBreak : TimerMode.pomodoro,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Break.Down.Timer feature card explanation
                  if (mode == TimerMode.breakDownTimer) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.cyan, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Break.Down.Timer Feature',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'In Break.Down.Timer, the app runs continuous work sessions while providing automated breaks/checkpoints at intervals you define. When an interval hits, an audio visual alert rings so you can pause, rest, and resume without losing task flow.',
                              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: widget.viewModel.settings.breakDownCheckpoints.map((cp) {
                                return Chip(
                                  avatar: Icon(
                                    cp.hasTriggered ? Icons.check_circle : Icons.schedule,
                                    size: 14,
                                    color: cp.hasTriggered ? Colors.green : Colors.cyan,
                                  ),
                                  label: Text('${cp.label} (@${cp.triggerAtSecond ~/ 60}m)'),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeChip(TimerMode targetMode, String label, IconData icon) {
    final isSelected = widget.viewModel.mode == targetMode;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.indigo),
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.indigo,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600),
      onSelected: (_) => widget.viewModel.setMode(targetMode),
    );
  }
}
