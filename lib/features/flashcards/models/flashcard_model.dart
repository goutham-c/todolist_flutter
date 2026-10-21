enum CardMastery { again, learning, hard, good, easy }

class Flashcard {
  final String id;
  final String front;
  final String back;
  final CardMastery mastery;
  final int reviewCount;
  final DateTime? lastReviewed;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.mastery = CardMastery.again,
    this.reviewCount = 0,
    this.lastReviewed,
  });

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    CardMastery? mastery,
    int? reviewCount,
    DateTime? lastReviewed,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      mastery: mastery ?? this.mastery,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
        'mastery': mastery.index,
        'reviewCount': reviewCount,
        'lastReviewed': lastReviewed?.toIso8601String(),
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        front: json['front'] as String,
        back: json['back'] as String,
        mastery: CardMastery.values[json['mastery'] as int? ?? 0],
        reviewCount: json['reviewCount'] as int? ?? 0,
        lastReviewed: json['lastReviewed'] != null ? DateTime.tryParse(json['lastReviewed']) : null,
      );
}

class DeckModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int colorValue;
  final List<Flashcard> cards;
  final DateTime createdAt;

  DeckModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'Study',
    this.colorValue = 0xFF6366F1,
    this.cards = const [],
    required this.createdAt,
  });

  double get masteryPercentage {
    if (cards.isEmpty) return 0.0;
    final mastered = cards.where((c) => c.mastery == CardMastery.good || c.mastery == CardMastery.easy).length;
    return mastered / cards.length;
  }

  DeckModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? colorValue,
    List<Flashcard>? cards,
    DateTime? createdAt,
  }) {
    return DeckModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      cards: cards ?? this.cards,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'colorValue': colorValue,
        'cards': cards.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory DeckModel.fromJson(Map<String, dynamic> json) => DeckModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? 'Study',
        colorValue: json['colorValue'] as int? ?? 0xFF6366F1,
        cards: (json['cards'] as List<dynamic>?)
                ?.map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}
