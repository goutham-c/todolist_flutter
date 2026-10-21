enum TaskPriority { urgent, high, medium, low }

class SubTask {
  final String id;
  final String title;
  final bool isDone;

  SubTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isDone: json['isDone'] as bool? ?? false,
      );
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final String category;
  final DateTime? dueDate;
  final bool isCompleted;
  final List<SubTask> subtasks;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.category = 'General',
    this.dueDate,
    this.isCompleted = false,
    this.subtasks = const [],
    required this.createdAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    List<SubTask>? subtasks,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.index,
        'category': category,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        priority: TaskPriority.values[json['priority'] as int? ?? 2],
        category: json['category'] as String? ?? 'General',
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
        isCompleted: json['isCompleted'] as bool? ?? false,
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class DeadlineModel {
  final String id;
  final String title;
  final String courseOrProject;
  final DateTime targetDate;
  final String note;
  final TaskPriority priority;
  final bool isCompleted;

  DeadlineModel({
    required this.id,
    required this.title,
    required this.courseOrProject,
    required this.targetDate,
    this.note = '',
    this.priority = TaskPriority.high,
    this.isCompleted = false,
  });

  DeadlineModel copyWith({
    String? id,
    String? title,
    String? courseOrProject,
    DateTime? targetDate,
    String? note,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return DeadlineModel(
      id: id ?? this.id,
      title: title ?? this.title,
      courseOrProject: courseOrProject ?? this.courseOrProject,
      targetDate: targetDate ?? this.targetDate,
      note: note ?? this.note,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseOrProject': courseOrProject,
        'targetDate': targetDate.toIso8601String(),
        'note': note,
        'priority': priority.index,
        'isCompleted': isCompleted,
      };

  factory DeadlineModel.fromJson(Map<String, dynamic> json) => DeadlineModel(
        id: json['id'] as String,
        title: json['title'] as String,
        courseOrProject: json['courseOrProject'] as String? ?? '',
        targetDate: DateTime.tryParse(json['targetDate'] as String? ?? '') ?? DateTime.now(),
        note: json['note'] as String? ?? '',
        priority: TaskPriority.values[json['priority'] as int? ?? 1],
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}
