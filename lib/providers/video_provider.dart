import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../services/firebase_service.dart';

class VideoProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Video> _videos = [];
  bool _isLoading = false;
  String? _error;
  String? _currentCourseId;
  String? _currentChapterId;

  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentCourseId => _currentCourseId;
  String? get currentChapterId => _currentChapterId;

  void setCurrentCourse(String courseId) {
    _currentCourseId = courseId;
    // Clear videos when course changes
    _videos = [];
    _currentChapterId = null;
    notifyListeners();
  }

  void setCurrentChapter(String chapterId) {
    _currentChapterId = chapterId;
    if (_currentCourseId != null) {
      fetchVideos(_currentCourseId!, chapterId);
    }
  }

  void fetchVideos(String courseId, String chapterId) {
    _isLoading = true;
    _videos = [];
    notifyListeners();

    _firebaseService.getVideos(courseId, chapterId).listen(
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

      // Determine the next order value
      int nextOrder = 0;
      if (_videos.isNotEmpty) {
        nextOrder = _videos.length;
      }


      // Create a new video with the determined order
      final newVideo = Video(
        id: video.id,
        name: video.name,
        description: video.description,
        link: video.link,
        courseId: video.courseId,
        chapterId: video.chapterId,
        order: nextOrder,
      );

      await _firebaseService.addVideo(newVideo);

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

  // Optional: Method to reorder videos (if you want to implement drag and drop)
  Future<void> reorderVideo(int oldIndex, int newIndex) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Adjust for removing the item
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Get the video that's being moved
      final Video movedVideo = _videos[oldIndex];

      // Create a batch of updates for all affected videos
      List<Video> updatedVideos = List.from(_videos);
      updatedVideos.removeAt(oldIndex);
      updatedVideos.insert(newIndex, movedVideo);

      // Update the order of each video
      for (int i = 0; i < updatedVideos.length; i++) {
        Video video = updatedVideos[i];
        if (video.order != i) {
          // Create updated video with new order
          Video updatedVideo = Video(
            id: video.id,
            name: video.name,
            description: video.description,
            link: video.link,
            courseId: video.courseId,
            chapterId: video.chapterId,
            order: i,
          );

          await _firebaseService.updateVideo(updatedVideo);
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