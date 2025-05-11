
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../services/firebase_service.dart';

class VideoProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Video> _videos = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCourseId;

  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCourseId => _currentCourseId;

  void setCurrentCourse(String courseId) {
    _currentCourseId = courseId;
    fetchVideos(courseId);
  }

  void fetchVideos(String courseId) {
    _isLoading = true;
    _videos = [];
    notifyListeners();

    _firebaseService.getVideos(courseId).listen(
          (videosList) {
        _videos = videosList;
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

  Future<void> addVideo(Video video) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.addVideo(video);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateVideo(Video video) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.updateVideo(video);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteVideo(Video video) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firebaseService.deleteVideo(video);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}