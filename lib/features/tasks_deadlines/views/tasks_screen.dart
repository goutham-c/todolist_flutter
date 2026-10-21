import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../view_models/tasks_view_model.dart';
import '../../../core/utils/formatters.dart';

class TasksScreen extends StatefulWidget {
  final TasksViewModel viewModel;

  const TasksScreen({super.key, required this.viewModel});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final categoryController = TextEditingController(text: 'General');
    TaskPriority priority = TaskPriority.medium;
    DateTime? dueDate = DateTime.now().add(const Duration(days: 1));
    final List<String> subtaskTitles = [];
    final subtaskInputController = TextEditingController();

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
                    const Text('New Task (Deer & Glory Todo)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                        items: TaskPriority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => priority = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Subtasks section
                const Text('Subtasks Checklist (Glory Todo style):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: subtaskInputController,
                        decoration: const InputDecoration(
                          hintText: 'Add subtask item...',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final text = subtaskInputController.text.trim();
                        if (text.isNotEmpty) {
                          setModalState(() {
                            subtaskTitles.add(text);
                            subtaskInputController.clear();
                          });
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
                if (subtaskTitles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: subtaskTitles.map((st) {
                      return Chip(
                        label: Text(st),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setModalState(() => subtaskTitles.remove(st)),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;
                      final now = DateTime.now();
                      final subtasks = subtaskTitles.asMap().entries.map((e) {
                        return SubTask(id: 'st_${now.millisecondsSinceEpoch}_${e.key}', title: e.value);
                      }).toList();

                      widget.viewModel.addTask(
                        TaskModel(
                          id: 'task_${now.millisecondsSinceEpoch}',
                          title: title,
                          description: descController.text.trim(),
                          priority: priority,
                          category: categoryController.text.trim().isEmpty ? 'General' : categoryController.text.trim(),
                          dueDate: dueDate,
                          subtasks: subtasks,
                          createdAt: now,
                        ),
                      );
                      Navigator.pop(ctx);
                    },
                    child: const Text('Create Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddDeadlineDialog() {
    final titleController = TextEditingController();
    final projectController = TextEditingController();
    final noteController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 3, hours: 12));
    TaskPriority priority = TaskPriority.high;

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
                  const Text('New Deadline (DeadlinesApp style)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Deadline Title *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: projectController,
                decoration: const InputDecoration(labelText: 'Course / Project Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Notes / Requirements', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: Colors.indigo),
                title: Text('Target: ${Formatters.formatDateTime(targetDate)}'),
                trailing: TextButton(
                  child: const Text('Pick Date'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setModalState(() {
                        targetDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          targetDate.hour,
                          targetDate.minute,
                        );
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    widget.viewModel.addDeadline(
                      DeadlineModel(
                        id: 'dl_${DateTime.now().millisecondsSinceEpoch}',
                        title: title,
                        courseOrProject: projectController.text.trim().isEmpty ? 'Project' : projectController.text.trim(),
                        targetDate: targetDate,
                        note: noteController.text.trim(),
                        priority: priority,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Set Deadline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks & Deadlines ⏳'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.check_circle_outline), text: 'Todos (Deer)'),
                Tab(icon: Icon(Icons.timer_outlined), text: 'Deadlines (DeadlinesApp)'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTasksTab(isDark),
              _buildDeadlinesTab(isDark),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'tasks_fab',
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddTaskDialog();
              } else {
                _showAddDeadlineDialog();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(_tabController.index == 0 ? 'Add Task' : 'Add Deadline'),
          ),
        );
      },
    );
  }

  Widget _buildTasksTab(bool isDark) {
    final tasks = widget.viewModel.filteredTasks;
    final categories = widget.viewModel.categories;

    return Column(
      children: [
        // Category chips
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final cat = categories[i];
              final isSelected = widget.viewModel.selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => widget.viewModel.setSelectedCategory(cat),
              );
            },
          ),
        ),

        // Tasks list
        Expanded(
          child: tasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No tasks in this category', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: tasks.length,
                  itemBuilder: (ctx, i) {
                    final task = tasks[i];
                    return _buildTaskCard(task, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, bool isDark) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.urgent:
        priorityColor = Colors.red;
        break;
      case TaskPriority.high:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.blue;
        break;
      case TaskPriority.low:
        priorityColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: Colors.green,
          onChanged: (_) => widget.viewModel.toggleTaskCompletion(task.id),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withAlpha(30),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.priority.name.toUpperCase(),
                style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              task.category,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (task.dueDate != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.event, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                Formatters.formatDate(task.dueDate!),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
          onPressed: () => widget.viewModel.deleteTask(task.id),
        ),
        children: [
          if (task.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  task.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            ),
          // Subtasks (Glory Todo Desktop style)
          if (task.subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text('Subtasks Checklist:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ...task.subtasks.map((st) {
                    return Row(
                      children: [
                        Checkbox(
                          value: st.isDone,
                          visualDensity: VisualDensity.compact,
                          onChanged: (_) => widget.viewModel.toggleSubTask(task.id, st.id),
                        ),
                        Expanded(
                          child: Text(
                            st.title,
                            style: TextStyle(
                              fontSize: 13,
                              decoration: st.isDone ? TextDecoration.lineThrough : null,
                              color: st.isDone ? Colors.grey : null,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeadlinesTab(bool isDark) {
    final deadlines = widget.viewModel.sortedDeadlines;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // DeadlinesApp Summary Banner
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.viewModel.upcomingDeadlinesCount}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 2),
                    const Text('Upcoming', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.viewModel.overdueDeadlinesCount}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 2),
                    const Text('Overdue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (deadlines.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('No active deadlines recorded.'),
            ),
          )
        else
          ...deadlines.map((dl) => _buildDeadlineCard(dl, isDark)),
      ],
    );
  }

  Widget _buildDeadlineCard(DeadlineModel dl, bool isDark) {
    final now = DateTime.now();
    final isOverdue = dl.targetDate.isBefore(now);
    final hoursLeft = dl.targetDate.difference(now).inHours;
    final isUrgent = hoursLeft < 48 && !isOverdue;

    Color badgeColor;
    if (dl.isCompleted) {
      badgeColor = Colors.green;
    } else if (isOverdue) {
      badgeColor = Colors.red;
    } else if (isUrgent) {
      badgeColor = Colors.orange;
    } else {
      badgeColor = Colors.indigo;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dl.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: dl.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () => widget.viewModel.deleteDeadline(dl.id),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dl.courseOrProject,
              style: TextStyle(fontSize: 13, color: Colors.indigo.shade400, fontWeight: FontWeight.w600),
            ),
            if (dl.note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(dl.note, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    dl.isCompleted ? Icons.check_circle : Icons.alarm,
                    size: 18,
                    color: badgeColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dl.isCompleted ? 'Completed' : Formatters.formatCountdown(dl.targetDate),
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    Formatters.formatDateTime(dl.targetDate),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(dl.isCompleted ? Icons.undo : Icons.check, size: 16),
                  label: Text(dl.isCompleted ? 'Mark Pending' : 'Mark Completed'),
                  onPressed: () => widget.viewModel.toggleDeadlineCompletion(dl.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
