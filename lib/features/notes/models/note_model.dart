class NoteModel {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isLocked;
  final bool hasVoiceMemo;
  final int voiceDurationSeconds;
  final List<double> voiceWaveform;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isLocked = false,
    this.hasVoiceMemo = false,
    this.voiceDurationSeconds = 0,
    this.voiceWaveform = const [],
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? tags,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isLocked,
    bool? hasVoiceMemo,
    int? voiceDurationSeconds,
    List<double>? voiceWaveform,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      hasVoiceMemo: hasVoiceMemo ?? this.hasVoiceMemo,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
      voiceWaveform: voiceWaveform ?? this.voiceWaveform,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'isLocked': isLocked,
      'hasVoiceMemo': hasVoiceMemo,
      'voiceDurationSeconds': voiceDurationSeconds,
      'voiceWaveform': voiceWaveform,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      colorValue: json['colorValue'] as int? ?? 0xFFFFFFFF,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      hasVoiceMemo: json['hasVoiceMemo'] as bool? ?? false,
      voiceDurationSeconds: json['voiceDurationSeconds'] as int? ?? 0,
      voiceWaveform: (json['voiceWaveform'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
    );
  }
}
