class HabitModel {
  final String id;
  final String title;
  final String category;
  final int colorValue;
  final String iconCode;
  final List<String> completedDates; // List of 'YYYY-MM-DD' strings
  final int streak;
  final int bestStreak;
  final int targetDaysPerWeek;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.title,
    this.category = 'Daily Routine',
    this.colorValue = 0xFF10B981,
    this.iconCode = 'fitness_center',
    this.completedDates = const [],
    this.streak = 0,
    this.bestStreak = 0,
    this.targetDaysPerWeek = 7,
    required this.createdAt,
  });

  bool isCompletedOn(String dateKey) {
    return completedDates.contains(dateKey);
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? category,
    int? colorValue,
    String? iconCode,
    List<String>? completedDates,
    int? streak,
    int? bestStreak,
    int? targetDaysPerWeek,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      completedDates: completedDates ?? this.completedDates,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'colorValue': colorValue,
        'iconCode': iconCode,
        'completedDates': completedDates,
        'streak': streak,
        'bestStreak': bestStreak,
        'targetDaysPerWeek': targetDaysPerWeek,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String? ?? 'Daily Routine',
        colorValue: json['colorValue'] as int? ?? 0xFF10B981,
        iconCode: json['iconCode'] as String? ?? 'fitness_center',
        completedDates: (json['completedDates'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        streak: json['streak'] as int? ?? 0,
        bestStreak: json['bestStreak'] as int? ?? 0,
        targetDaysPerWeek: json['targetDaysPerWeek'] as int? ?? 7,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
