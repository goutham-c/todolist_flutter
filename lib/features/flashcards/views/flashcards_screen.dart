import 'package:flutter/material.dart';
import '../models/flashcard_model.dart';
import '../view_models/flashcards_view_model.dart';
import 'study_session_screen.dart';

class FlashcardsScreen extends StatefulWidget {
  final FlashcardsViewModel viewModel;

  const FlashcardsScreen({super.key, required this.viewModel});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  void _showCreateDeckDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final categoryController = TextEditingController(text: 'Study');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
                const Text('New Flashcard Deck 🃏', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Deck Title *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  widget.viewModel.addDeck(
                    DeckModel(
                      id: 'deck_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      description: descController.text.trim(),
                      category: categoryController.text.trim().isEmpty ? 'Study' : categoryController.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Create Deck', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog(DeckModel deck) {
    final frontController = TextEditingController();
    final backController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
                Text('Add Card to ${deck.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: frontController,
              maxLines: 2,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Front (Question / Prompt) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: backController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Back (Answer / Explanation) *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () {
                  final front = frontController.text.trim();
                  final back = backController.text.trim();
                  if (front.isEmpty || back.isEmpty) return;

                  widget.viewModel.addCardToDeck(
                    deck.id,
                    Flashcard(
                      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
                      front: front,
                      back: back,
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Add Flashcard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final decks = widget.viewModel.decks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('FlipCard Flashcards 🃏'),
          ),
          body: decks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.style_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No flashcard decks yet', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: decks.length,
                  itemBuilder: (ctx, i) {
                    final deck = decks[i];
                    return _buildDeckCard(deck);
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'flashcards_fab',
            onPressed: _showCreateDeckDialog,
            icon: const Icon(Icons.add),
            label: const Text('New Deck'),
          ),
        );
      },
    );
  }

  Widget _buildDeckCard(DeckModel deck) {
    final mastery = deck.masteryPercentage;
    final deckColor = Color(deck.colorValue);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: deckColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    deck.category.toUpperCase(),
                    style: TextStyle(color: deckColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () => widget.viewModel.deleteDeck(deck.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              deck.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (deck.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                deck.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 16),
            // Progress & Stats
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.style, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            '${deck.cards.length} Cards',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.military_tech, size: 16, color: Colors.amber.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${(mastery * 100).toInt()}% Mastered',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: mastery,
                        backgroundColor: Colors.grey.withAlpha(30),
                        color: deckColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Card'),
                  onPressed: () => _showAddCardDialog(deck),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deckColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Study Deck'),
                    onPressed: deck.cards.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudySessionScreen(
                                  deck: deck,
                                  viewModel: widget.viewModel,
                                ),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
