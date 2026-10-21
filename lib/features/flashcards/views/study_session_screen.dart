import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../view_models/flashcards_view_model.dart';

class StudySessionScreen extends StatefulWidget {
  final DeckModel deck;
  final FlashcardsViewModel viewModel;

  const StudySessionScreen({
    super.key,
    required this.deck,
    required this.viewModel,
  });

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    widget.viewModel.startStudySession(widget.deck);
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleFlip() {
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    widget.viewModel.flipCard();
  }

  void _rateCard(CardMastery mastery) async {
    // If flipped, rotate back before or during transition
    if (_flipController.isCompleted) {
      _flipController.reverse();
    }
    await widget.viewModel.rateCurrentCard(mastery);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final isFinished = widget.viewModel.isSessionFinished;
        final currentCard = widget.viewModel.currentCard;
        final totalCards = widget.deck.cards.length;
        final currentIndex = widget.viewModel.currentCardIndex;

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.deck.title),
            actions: [
              if (!isFinished)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      '${currentIndex + 1} / $totalCards',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          body: isFinished
              ? _buildSessionSummary()
              : (currentCard == null
                  ? const Center(child: Text('No cards in this deck.'))
                  : _buildCardStudyView(currentCard, totalCards, currentIndex)),
        );
      },
    );
  }

  Widget _buildCardStudyView(Flashcard card, int totalCards, int currentIndex) {
    final progress = totalCards == 0 ? 0.0 : (currentIndex + 1) / totalCards;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withAlpha(40),
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),

          // 3D FlipCard Widget
          Expanded(
            child: GestureDetector(
              onTap: _handleFlip,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * math.pi;
                  final isBack = _flipAnimation.value >= 0.5;

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // 3D Perspective
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child: _buildCardFace(
                              title: 'ANSWER / EXPLANATION',
                              content: card.back,
                              isAnswer: true,
                              color: const Color(0xFF312E81),
                            ),
                          )
                        : _buildCardFace(
                            title: 'QUESTION / CONCEPT',
                            content: card.front,
                            isAnswer: false,
                            color: Colors.indigo,
                          ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            '💡 Tap card to flip and reveal answer',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Recall / Spaced Repetition Buttons
          Row(
            children: [
              _buildRatingButton('Again', CardMastery.again, Colors.red),
              const SizedBox(width: 8),
              _buildRatingButton('Hard', CardMastery.hard, Colors.orange),
              const SizedBox(width: 8),
              _buildRatingButton('Good', CardMastery.good, Colors.blue),
              const SizedBox(width: 8),
              _buildRatingButton('Easy', CardMastery.easy, Colors.green),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildCardFace({
    required String title,
    required String content,
    required bool isAnswer,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton(String label, CardMastery mastery, Color color) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _rateCard(mastery),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSessionSummary() {
    final counts = widget.viewModel.sessionMasteryCounts;
    final total = widget.viewModel.cardsReviewedInSession;
    final goodEasy = (counts[CardMastery.good] ?? 0) + (counts[CardMastery.easy] ?? 0);
    final masteryRate = total == 0 ? 0.0 : (goodEasy / total);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars_rounded, size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Study Session Completed! 🎉',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Mastery Rate: ${(masteryRate * 100).toInt()}%',
              style: const TextStyle(fontSize: 16, color: Colors.indigo, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Breakdown card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Easy 🟢', counts[CardMastery.easy] ?? 0),
                  const Divider(height: 16),
                  _buildSummaryRow('Good 🔵', counts[CardMastery.good] ?? 0),
                  const Divider(height: 16),
                  _buildSummaryRow('Hard 🟠', counts[CardMastery.hard] ?? 0),
                  const Divider(height: 16),
                  _buildSummaryRow('Again 🔴', counts[CardMastery.again] ?? 0),
                ],
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Decks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text('$count cards', style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
