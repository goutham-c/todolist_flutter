import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../../../core/services/storage_service.dart';

class NotesViewModel extends ChangeNotifier {
  final StorageService storageService;

  List<NoteModel> _notes = [];
  String _searchQuery = '';
  String? _selectedTag;
  bool _isVaultUnlocked = false;

  // Voice note simulation state
  bool _isRecordingVoice = false;
  int _recordingDuration = 0;
  List<double> _liveWaveform = [];
  Timer? _recordingTimer;

  NotesViewModel({required this.storageService}) {
    loadNotes();
  }

  List<NoteModel> get notes => _notes;
  String get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;
  bool get isVaultUnlocked => _isVaultUnlocked;
  bool get isRecordingVoice => _isRecordingVoice;
  int get recordingDuration => _recordingDuration;
  List<double> get liveWaveform => _liveWaveform;

  List<String> get allTags {
    final tags = <String>{};
    for (final note in _notes) {
      tags.addAll(note.tags);
    }
    return tags.toList();
  }

  List<NoteModel> get filteredNotes {
    return _notes.where((note) {
      if (!_isVaultUnlocked && note.isLocked) {
        // Still show locked placeholder cards in UI so user knows they exist
      }
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTag = _selectedTag == null || note.tags.contains(_selectedTag);
      return matchesSearch && matchesTag;
    }).toList()
      ..sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  void loadNotes() {
    _notes = storageService.getNotes();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  bool unlockVault(String enteredPin) {
    if (enteredPin == storageService.vaultPin) {
      _isVaultUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void lockVault() {
    _isVaultUnlocked = false;
    notifyListeners();
  }

  Future<void> addNote(NoteModel note) async {
    _notes.insert(0, note);
    await storageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> updateNote(NoteModel note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
      await storageService.saveNotes(_notes);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await storageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final note = _notes[index];
      _notes[index] = note.copyWith(isPinned: !note.isPinned);
      await storageService.saveNotes(_notes);
      notifyListeners();
    }
  }

  // Voice recording simulation (inspired by Jiyi encrypted voice notes)
  void startRecordingVoice() {
    _isRecordingVoice = true;
    _recordingDuration = 0;
    _liveWaveform = [];
    notifyListeners();

    _recordingTimer?.cancel();
    final random = Random();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _recordingDuration++;
      // Generate a realistic audio amplitude between 0.2 and 1.0
      final amplitude = 0.2 + random.nextDouble() * 0.8;
      _liveWaveform.add(amplitude);
      if (_liveWaveform.length > 24) {
        _liveWaveform.removeAt(0);
      }
      notifyListeners();
    });
  }

  Map<String, dynamic> stopRecordingVoice() {
    _recordingTimer?.cancel();
    _isRecordingVoice = false;
    final result = {
      'duration': _recordingDuration ~/ 2, // roughly seconds
      'waveform': List<double>.from(_liveWaveform),
    };
    notifyListeners();
    return result;
  }

  void cancelRecordingVoice() {
    _recordingTimer?.cancel();
    _isRecordingVoice = false;
    _liveWaveform = [];
    _recordingDuration = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }
}
