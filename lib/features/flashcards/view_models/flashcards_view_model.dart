import 'package:flutter/foundation.dart';
import '../models/flashcard_model.dart';
import '../../../core/services/storage_service.dart';

class FlashcardsViewModel extends ChangeNotifier {
  final StorageService storageService;

  List<DeckModel> _decks = [];
  DeckModel? _currentDeck;
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;
  bool _isSessionFinished = false;

  // Study session stats
  int _cardsReviewedInSession = 0;
  final Map<CardMastery, int> _sessionMasteryCounts = {
    CardMastery.again: 0,
    CardMastery.learning: 0,
    CardMastery.hard: 0,
    CardMastery.good: 0,
    CardMastery.easy: 0,
  };

  FlashcardsViewModel({required this.storageService}) {
    loadDecks();
  }

  List<DeckModel> get decks => _decks;
  DeckModel? get currentDeck => _currentDeck;
  int get currentCardIndex => _currentCardIndex;
  bool get isCardFlipped => _isCardFlipped;
  bool get isSessionFinished => _isSessionFinished;
  int get cardsReviewedInSession => _cardsReviewedInSession;
  Map<CardMastery, int> get sessionMasteryCounts => _sessionMasteryCounts;

  Flashcard? get currentCard {
    if (_currentDeck == null || _currentDeck!.cards.isEmpty) return null;
    if (_currentCardIndex < _currentDeck!.cards.length) {
      return _currentDeck!.cards[_currentCardIndex];
    }
    return null;
  }

  void loadDecks() {
    _decks = storageService.getDecks();
    notifyListeners();
  }

  void startStudySession(DeckModel deck) {
    _currentDeck = deck;
    _currentCardIndex = 0;
    _isCardFlipped = false;
    _isSessionFinished = false;
    _cardsReviewedInSession = 0;
    for (final key in _sessionMasteryCounts.keys) {
      _sessionMasteryCounts[key] = 0;
    }
    notifyListeners();
  }

  void flipCard() {
    _isCardFlipped = !_isCardFlipped;
    notifyListeners();
  }

  Future<void> rateCurrentCard(CardMastery rating) async {
    if (_currentDeck == null || currentCard == null) return;

    final updatedCard = currentCard!.copyWith(
      mastery: rating,
      reviewCount: currentCard!.reviewCount + 1,
      lastReviewed: DateTime.now(),
    );

    final updatedCards = List<Flashcard>.from(_currentDeck!.cards);
    updatedCards[_currentCardIndex] = updatedCard;

    _currentDeck = _currentDeck!.copyWith(cards: updatedCards);

    // Update in full deck list & persist
    final deckIndex = _decks.indexWhere((d) => d.id == _currentDeck!.id);
    if (deckIndex != -1) {
      _decks[deckIndex] = _currentDeck!;
      await storageService.saveDecks(_decks);
    }

    _cardsReviewedInSession++;
    _sessionMasteryCounts[rating] = (_sessionMasteryCounts[rating] ?? 0) + 1;

    // Move to next card or complete session
    _isCardFlipped = false;
    if (_currentCardIndex + 1 < _currentDeck!.cards.length) {
      _currentCardIndex++;
    } else {
      _isSessionFinished = true;
    }
    notifyListeners();
  }

  Future<void> addDeck(DeckModel deck) async {
    _decks.add(deck);
    await storageService.saveDecks(_decks);
    notifyListeners();
  }

  Future<void> updateDeck(DeckModel deck) async {
    final index = _decks.indexWhere((d) => d.id == deck.id);
    if (index != -1) {
      _decks[index] = deck;
      if (_currentDeck?.id == deck.id) {
        _currentDeck = deck;
      }
      await storageService.saveDecks(_decks);
      notifyListeners();
    }
  }

  Future<void> deleteDeck(String id) async {
    _decks.removeWhere((d) => d.id == id);
    if (_currentDeck?.id == id) {
      _currentDeck = null;
    }
    await storageService.saveDecks(_decks);
    notifyListeners();
  }

  Future<void> addCardToDeck(String deckId, Flashcard card) async {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index != -1) {
      final deck = _decks[index];
      final updatedCards = List<Flashcard>.from(deck.cards)..add(card);
      final updatedDeck = deck.copyWith(cards: updatedCards);
      _decks[index] = updatedDeck;
      if (_currentDeck?.id == deckId) {
        _currentDeck = updatedDeck;
      }
      await storageService.saveDecks(_decks);
      notifyListeners();
    }
  }

  Future<void> deleteCardFromDeck(String deckId, String cardId) async {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index != -1) {
      final deck = _decks[index];
      final updatedCards = deck.cards.where((c) => c.id != cardId).toList();
      final updatedDeck = deck.copyWith(cards: updatedCards);
      _decks[index] = updatedDeck;
      if (_currentDeck?.id == deckId) {
        _currentDeck = updatedDeck;
      }
      await storageService.saveDecks(_decks);
      notifyListeners();
    }
  }
}
