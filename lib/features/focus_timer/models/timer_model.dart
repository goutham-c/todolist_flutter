enum TimerMode {
  pomodoro,
  shortBreak,
  longBreak,
  breakDownTimer, // Inspired by Break.Down.Timer where user defines multiple breaks inside a long timer
}

class BreakCheckpoint {
  final String label;
  final int triggerAtSecond; // e.g., at 1200 seconds remaining
  final int durationSeconds; // break length e.g. 120s (2m)
  bool hasTriggered;

  BreakCheckpoint({
    required this.label,
    required this.triggerAtSecond,
    this.durationSeconds = 120,
    this.hasTriggered = false,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'triggerAtSecond': triggerAtSecond,
        'durationSeconds': durationSeconds,
        'hasTriggered': hasTriggered,
      };

  factory BreakCheckpoint.fromJson(Map<String, dynamic> json) => BreakCheckpoint(
        label: json['label'] as String,
        triggerAtSecond: json['triggerAtSecond'] as int,
        durationSeconds: json['durationSeconds'] as int? ?? 120,
        hasTriggered: json['hasTriggered'] as bool? ?? false,
      );
}

class TimerSettings {
  final int pomodoroMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int breakDownTotalMinutes;
  final List<BreakCheckpoint> breakDownCheckpoints;

  TimerSettings({
    this.pomodoroMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.breakDownTotalMinutes = 50,
    List<BreakCheckpoint>? breakDownCheckpoints,
  }) : breakDownCheckpoints = breakDownCheckpoints ??
            [
              BreakCheckpoint(label: 'Hydrate & Stretch (2m)', triggerAtSecond: 30 * 60, durationSeconds: 120),
              BreakCheckpoint(label: 'Eye Rest & Deep Breath (2m)', triggerAtSecond: 15 * 60, durationSeconds: 120),
            ];

  Map<String, dynamic> toJson() => {
        'pomodoroMinutes': pomodoroMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
        'breakDownTotalMinutes': breakDownTotalMinutes,
        'breakDownCheckpoints': breakDownCheckpoints.map((c) => c.toJson()).toList(),
      };

  factory TimerSettings.fromJson(Map<String, dynamic> json) => TimerSettings(
        pomodoroMinutes: json['pomodoroMinutes'] as int? ?? 25,
        shortBreakMinutes: json['shortBreakMinutes'] as int? ?? 5,
        longBreakMinutes: json['longBreakMinutes'] as int? ?? 15,
        breakDownTotalMinutes: json['breakDownTotalMinutes'] as int? ?? 50,
        breakDownCheckpoints: (json['breakDownCheckpoints'] as List<dynamic>?)
            ?.map((e) => BreakCheckpoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
