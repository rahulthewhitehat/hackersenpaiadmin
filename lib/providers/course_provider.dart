import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../services/firebase_service.dart';

class CourseProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;

  bool get isLoading => _isLoading;

  String? get error => _error;

  CourseProvider() {
    fetchCourses();
  }

  void fetchCourses() {
    _isLoading = true;
    notifyListeners();

    _firebaseService.getCourses().listen(
          (coursesList) {
        _courses = coursesList;
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

  Future<void> addCourse(Course course) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.addCourse(course);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.updateCourse(course);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.deleteCourse(courseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}