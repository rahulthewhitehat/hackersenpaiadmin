import 'package:flutter/foundation.dart';
import '../models/chapter_model.dart';
import '../services/firebase_service.dart';

class ChapterProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Chapter> _chapters = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCourseId;

  List<Chapter> get chapters => _chapters;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCourseId => _currentCourseId;

  void setCurrentCourse(String courseId) {
    _currentCourseId = courseId;
    fetchChapters(courseId);
  }

  void fetchChapters(String courseId) {
    _isLoading = true;
    _chapters = [];
    notifyListeners();

    _firebaseService.getChapters(courseId).listen(
          (chaptersList) {
        _chapters = chaptersList;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addChapter(Chapter chapter) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Determine the next order value
      int nextOrder = 0;
      if (_chapters.isNotEmpty) {
        nextOrder = _chapters.length;
      }

      // Create a new chapter with the determined order
      final newChapter = Chapter(
        id: chapter.id,
        name: chapter.name,
        description: chapter.description,
        courseId: chapter.courseId,
        order: nextOrder,
      );

      await _firebaseService.addChapter(newChapter);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateChapter(Chapter chapter) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.updateChapter(chapter);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteChapter(Chapter chapter) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.deleteChapter(chapter);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> reorderChapter(int oldIndex, int newIndex) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Adjust for removing the item
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Get the chapter that's being moved
      final Chapter movedChapter = _chapters[oldIndex];

      // Create a batch of updates for all affected chapters
      List<Chapter> updatedChapters = List.from(_chapters);
      updatedChapters.removeAt(oldIndex);
      updatedChapters.insert(newIndex, movedChapter);

      // Update the order of each chapter
      for (int i = 0; i < updatedChapters.length; i++) {
        Chapter chapter = updatedChapters[i];
        if (chapter.order != i) {
          // Create updated chapter with new order
          Chapter updatedChapter = Chapter(
            id: chapter.id,
            name: chapter.name,
            description: chapter.description,
            courseId: chapter.courseId,
            order: i,
          );

          await _firebaseService.updateChapter(updatedChapter);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}