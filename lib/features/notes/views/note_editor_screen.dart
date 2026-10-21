import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../view_models/notes_view_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? note;
  final NotesViewModel viewModel;

  const NoteEditorScreen({
    super.key,
    this.note,
    required this.viewModel,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  late List<String> _tags;
  late int _selectedColor;
  late bool _isPinned;
  late bool _isLocked;
  bool _isPreviewMode = false;

  // Voice memo state
  bool _hasVoiceMemo = false;
  int _voiceDuration = 0;
  List<double> _voiceWaveform = [];

  final List<int> _colorPalette = [
    0xFFFFFFFF, // Default White
    0xFFE0E7FF, // Soft Indigo
    0xFFFEF3C7, // Soft Amber
    0xFFDCFCE7, // Soft Emerald
    0xFFFCE7F3, // Soft Pink
    0xFFE0F2FE, // Soft Sky
    0xFFF3E8FF, // Soft Purple
  ];

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _titleController = TextEditingController(text: n?.title ?? '');
    _contentController = TextEditingController(text: n?.content ?? '');
    _tagInputController = TextEditingController();
    _tags = List<String>.from(n?.tags ?? []);
    _selectedColor = n?.colorValue ?? _colorPalette[0];
    _isPinned = n?.isPinned ?? false;
    _isLocked = n?.isLocked ?? false;
    _hasVoiceMemo = n?.hasVoiceMemo ?? false;
    _voiceDuration = n?.voiceDurationSeconds ?? 0;
    _voiceWaveform = List<double>.from(n?.voiceWaveform ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && !_hasVoiceMemo) {
      Navigator.pop(context);
      return;
    }

    final effectiveTitle = title.isEmpty ? 'Untitled Note' : title;
    final now = DateTime.now();

    if (widget.note != null) {
      widget.viewModel.updateNote(
        widget.note!.copyWith(
          title: effectiveTitle,
          content: content,
          tags: _tags,
          colorValue: _selectedColor,
          isPinned: _isPinned,
          isLocked: _isLocked,
          hasVoiceMemo: _hasVoiceMemo,
          voiceDurationSeconds: _voiceDuration,
          voiceWaveform: _voiceWaveform,
        ),
      );
    } else {
      widget.viewModel.addNote(
        NoteModel(
          id: 'note_${now.millisecondsSinceEpoch}',
          title: effectiveTitle,
          content: content,
          tags: _tags,
          colorValue: _selectedColor,
          createdAt: now,
          updatedAt: now,
          isPinned: _isPinned,
          isLocked: _isLocked,
          hasVoiceMemo: _hasVoiceMemo,
          voiceDurationSeconds: _voiceDuration,
          voiceWaveform: _voiceWaveform,
        ),
      );
    }

    Navigator.pop(context);
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: _tagInputController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Work, Ideas, Flutter',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            final tag = value.trim();
            if (tag.isNotEmpty && !_tags.contains(tag)) {
              setState(() => _tags.add(tag));
              _tagInputController.clear();
            }
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = _tagInputController.text.trim();
              if (tag.isNotEmpty && !_tags.contains(tag)) {
                setState(() => _tags.add(tag));
                _tagInputController.clear();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Color(_selectedColor);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            tooltip: _isPreviewMode ? 'Edit Mode' : 'Markdown Preview (GitJournal style)',
            icon: Icon(_isPreviewMode ? Icons.edit_note : Icons.visibility_outlined),
            onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
          ),
          IconButton(
            tooltip: _isPinned ? 'Unpin' : 'Pin to Top (kardi notes style)',
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          IconButton(
            tooltip: _isLocked ? 'Unlocked Vault' : 'Lock Note in Vault (Jiyi style)',
            icon: Icon(_isLocked ? Icons.lock : Icons.lock_open_outlined),
            onPressed: () => setState(() => _isLocked = !_isLocked),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Column(
        children: [
          // Color & Tag bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Color choices
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colorPalette.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.indigo : Colors.grey.shade400,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.indigo) : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Add Tag',
                  icon: const Icon(Icons.label_outline, size: 20),
                  onPressed: _showAddTagDialog,
                ),
              ],
            ),
          ),

          // Tag chips
          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tags.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (ctx, i) {
                    final tag = _tags[i];
                    return Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _tags.removeAt(i)),
                    );
                  },
                ),
              ),
            ),

          // Voice note banner (Jiyi encrypted voice note feature)
          if (_hasVoiceMemo)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    'Voice Memo (${_voiceDuration}s)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const Spacer(),
                  // Simulated mini waveform preview
                  Row(
                    children: _voiceWaveform.take(12).map((amp) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 3,
                        height: 24 * amp,
                        decoration: BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _hasVoiceMemo = false;
                        _voiceDuration = 0;
                        _voiceWaveform = [];
                      });
                    },
                  ),
                ],
              ),
            ),

          // Main note fields
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isPreviewMode
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 24),
                          _buildMarkdownPreview(_contentController.text),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: 'Note Title...',
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              hintText: 'Start writing or recording...\nMarkdown supported (# Header, - [ ] Task, - Item)',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Bottom toolbar: Audio Voice Recording simulation (Jiyi style)
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              if (widget.viewModel.isRecordingVoice) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: Colors.red.withAlpha(30),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Recording audio: ${widget.viewModel.recordingDuration ~/ 2}s',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: widget.viewModel.liveWaveform.map((amp) {
                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                height: 32 * amp,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                        onPressed: () {
                          final res = widget.viewModel.stopRecordingVoice();
                          setState(() {
                            _hasVoiceMemo = true;
                            _voiceDuration = res['duration'] as int;
                            _voiceWaveform = res['waveform'] as List<double>;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.grey, size: 28),
                        onPressed: () {
                          widget.viewModel.cancelRecordingVoice();
                        },
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.withAlpha(50))),
                ),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.mic, size: 18),
                      label: const Text('Record Voice Memo'),
                      onPressed: () {
                        widget.viewModel.startRecordingVoice();
                      },
                    ),
                    const Spacer(),
                    if (_isLocked)
                      const Chip(
                        avatar: Icon(Icons.lock, size: 16, color: Colors.amber),
                        label: Text('Vault Encrypted', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownPreview(String raw) {
    if (raw.isEmpty) {
      return const Text('No content to preview.', style: TextStyle(fontStyle: FontStyle.italic));
    }

    final lines = raw.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(line.substring(2), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          );
        } else if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(line.substring(3), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          );
        } else if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(line.substring(4), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          );
        } else if (line.startsWith('- [x] ') || line.startsWith('- [X] ')) {
          return Row(
            children: [
              const Icon(Icons.check_box, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line.substring(6),
                  style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey),
                ),
              ),
            ],
          );
        } else if (line.startsWith('- [ ] ')) {
          return Row(
            children: [
              const Icon(Icons.check_box_outline_blank, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(line.substring(6))),
            ],
          );
        } else if (line.startsWith('- ') || line.startsWith('* ')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Expanded(child: Text(line.substring(2))),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(line),
        );
      }).toList(),
    );
  }
}
