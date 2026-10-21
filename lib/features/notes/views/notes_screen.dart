import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../view_models/notes_view_model.dart';
import 'note_editor_screen.dart';
import '../../../core/utils/formatters.dart';

class NotesScreen extends StatefulWidget {
  final NotesViewModel viewModel;

  const NotesScreen({super.key, required this.viewModel});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _promptUnlockVault() {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Unlock Secure Vault'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your 4-digit PIN (Default: 1234) to view encrypted notes:'),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              autofocus: true,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'PIN',
                prefixIcon: Icon(Icons.password),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final ok = widget.viewModel.unlockVault(pinController.text.trim());
              Navigator.pop(ctx);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN. Try 1234.')),
                );
              }
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final notes = widget.viewModel.filteredNotes;
        final tags = widget.viewModel.allTags;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Search & Vault App Bar
              SliverAppBar(
                floating: true,
                title: const Text('Notes & Vault 📝'),
                actions: [
                  IconButton(
                    tooltip: widget.viewModel.isVaultUnlocked ? 'Lock Vault' : 'Unlock Vault (kardi notes)',
                    icon: Icon(
                      widget.viewModel.isVaultUnlocked ? Icons.lock_open : Icons.lock_outline,
                      color: widget.viewModel.isVaultUnlocked ? Colors.green : Colors.amber,
                    ),
                    onPressed: () {
                      if (widget.viewModel.isVaultUnlocked) {
                        widget.viewModel.lockVault();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vault locked.')),
                        );
                      } else {
                        _promptUnlockVault();
                      }
                    },
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.viewModel.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search notes, markdown, voice memos...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.viewModel.setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Tags filter horizontal list
              if (tags.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: widget.viewModel.selectedTag == null,
                          onSelected: (_) => widget.viewModel.setSelectedTag(null),
                        ),
                        const SizedBox(width: 8),
                        ...tags.map((tag) {
                          final isSelected = widget.viewModel.selectedTag == tag;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('#$tag'),
                              selected: isSelected,
                              onSelected: (_) {
                                widget.viewModel.setSelectedTag(isSelected ? null : tag);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              // Notes count & Vault info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '${notes.length} ${notes.length == 1 ? 'Note' : 'Notes'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      if (!widget.viewModel.isVaultUnlocked)
                        GestureDetector(
                          onTap: _promptUnlockVault,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.lock, size: 12, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  'Vault Locked',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Notes list
              if (notes.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notes_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No notes found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = notes[index];
                        return _buildNoteCard(note, isDark);
                      },
                      childCount: notes.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'create_note_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteEditorScreen(
                    viewModel: widget.viewModel,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
        );
      },
    );
  }

  Widget _buildNoteCard(NoteModel note, bool isDark) {
    final isLockedHidden = note.isLocked && !widget.viewModel.isVaultUnlocked;
    final cardColor = isDark ? const Color(0xFF1E293B) : Color(note.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: note.isPinned ? Colors.indigo.shade400 : Colors.grey.withAlpha(40),
          width: note.isPinned ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isLockedHidden) {
            _promptUnlockVault();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditorScreen(
                  note: note,
                  viewModel: widget.viewModel,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Pin, Title, Lock, Actions
              Row(
                children: [
                  if (note.isPinned) ...[
                    const Icon(Icons.push_pin, size: 16, color: Colors.indigo),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      isLockedHidden ? 'Encrypted Note 🔒' : note.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isLocked) ...[
                    Icon(
                      widget.viewModel.isVaultUnlocked ? Icons.lock_open : Icons.lock,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                  ],
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (val) {
                      if (val == 'pin') {
                        widget.viewModel.togglePin(note.id);
                      } else if (val == 'delete') {
                        widget.viewModel.deleteNote(note.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'pin',
                        child: Text(note.isPinned ? 'Unpin note' : 'Pin note'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete note', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Content or encrypted teaser
              if (isLockedHidden)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: Colors.grey.shade500),
                      const SizedBox(width: 8),
                      Text(
                        'Content encrypted. Tap to enter PIN.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

              // Voice memo preview (Jiyi style)
              if (note.hasVoiceMemo && !isLockedHidden) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_fill, color: Colors.indigo, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Voice Memo (${note.voiceDurationSeconds}s)',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.indigo),
                      ),
                      const Spacer(),
                      Row(
                        children: note.voiceWaveform.take(14).map((amp) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            width: 2.5,
                            height: 18 * amp,
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Tags & Date
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: note.tags.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$t',
                            style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Text(
                    Formatters.formatDate(note.updatedAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
