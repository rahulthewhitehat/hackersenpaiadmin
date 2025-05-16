
import 'package:flutter/foundation.dart';
import '../models/student_model.dart';
import '../services/firebase_service.dart';

class StudentProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StudentProvider() {
    loadStudents();
  }

  // Alias for fetchStudents to match both conventions
  void loadStudents() => fetchStudents();

  void fetchStudents() {
    _isLoading = true;
    notifyListeners();

    _firebaseService.getStudents().listen(
          (studentsList) {
        _students = studentsList;
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

  Future<void> addStudent(Student student, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.addStudent(student, password);
      fetchStudents(); // Refresh the list after adding

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.updateStudent(student);
      fetchStudents(); // Refresh the list after updating

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.deleteStudent(studentId);
      fetchStudents(); // Refresh the list after deleting

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> resetStudentUniqueId(String studentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.resetStudentUniqueId(studentId);
      // No need to refresh the list as this doesn't change any visible data

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}