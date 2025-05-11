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

      await _firebaseService.addChapter(chapter);

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
}