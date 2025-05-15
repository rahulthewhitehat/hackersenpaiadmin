// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chapter_model.dart';
import '../models/student_model.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import 'auth_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Student Methods
  Future<void> addStudent(Student student, String password) async {
    try {
      // First create the user in Auth
      final userCredential = await _authService.registerStudent(
        student.email,
        password,
      );

      // Then add student data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(
        student.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Student>> getStudents() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Student.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _firestore.collection('users').doc(student.id).update(
        student.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      // Delete from Auth first
      await _authService.deleteStudent(studentId);

      // Then delete from Firestore
      await _firestore.collection('users').doc(studentId).delete();
    } catch (e) {
      // If we can't delete from Auth (which is likely in this demo),
      // at least delete from Firestore
      await _firestore.collection('users').doc(studentId).delete();
    }
  }

  // Chapter Methods
  Future<void> addChapter(Chapter chapter) async {
    try {
      // Get the count of existing chapters to determine the new order
      QuerySnapshot chaptersSnapshot = await _firestore
          .collection('courses')
          .doc(chapter.courseId)
          .collection('chapters')
          .get();

      // Create a map with the chapter data including the order
      final chapterData = chapter.toJson();

      // If order is not explicitly set, use the count of existing chapters
      if (chapterData['order'] == 0) {
        chapterData['order'] = chaptersSnapshot.docs.length;
      }

      await _firestore
          .collection('courses')
          .doc(chapter.courseId)
          .collection('chapters')
          .add(chapterData);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Chapter>> getChapters(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('chapters')
        .orderBy('order') // Order by the 'order' field
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['course_id'] = courseId;
        return Chapter.fromJson(data, doc.id);
      }).toList();
    });
  }

  Future<void> updateChapter(Chapter chapter) async {
    try {
      await _firestore
          .collection('courses')
          .doc(chapter.courseId)
          .collection('chapters')
          .doc(chapter.id)
          .update(chapter.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteChapter(Chapter chapter) async {
    try {
      // First delete all videos in the chapter
      final videosSnapshot = await _firestore
          .collection('courses')
          .doc(chapter.courseId)
          .collection('chapters')
          .doc(chapter.id)
          .collection('videos')
          .get();

      for (var doc in videosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the chapter
      await _firestore
          .collection('courses')
          .doc(chapter.courseId)
          .collection('chapters')
          .doc(chapter.id)
          .delete();

      // Update the order of remaining chapters
     // await _reorderChaptersAfterDelete(chapter);
    } catch (e) {
      rethrow;
    }
  }

  // Course Methods
  Future<void> addCourse(Course course) async {
    try {
      await _firestore
          .collection('courses')
          .doc(course.name) // Use course name as document ID
          .set(course.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Course>> getCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Course.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateCourse(Course course) async {
    try {
      await _firestore.collection('courses').doc(course.id).update(
        course.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      // First delete all videos in the course
      final videosSnapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('videos')
          .get();

      for (var doc in videosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Then delete the course
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addVideo(Video video) async {
    try {
      // Get the count of existing videos to determine the new order
      QuerySnapshot videosSnapshot = await _firestore
          .collection('courses')
          .doc(video.courseId)
          .collection('chapters')
          .doc(video.chapterId)
          .collection('videos')
          .get();

      // Create a map with the video data including the order
      final videoData = video.toJson();

      // If order is not explicitly set, use the count of existing videos
      if (videoData['order'] == 0) {
        videoData['order'] = videosSnapshot.docs.length;
      }

      await _firestore
          .collection('courses')
          .doc(video.courseId)
          .collection('chapters')
          .doc(video.chapterId)
          .collection('videos')
          .add(videoData);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Video>> getVideos(String courseId, String chapterId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('chapters')
        .doc(chapterId)
        .collection('videos')
        .orderBy('order') // Order by the 'order' field
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['course_id'] = courseId;
        data['chapter_id'] = chapterId;
        return Video.fromJson(data, doc.id);
      }).toList();
    });
  }

  Future<void> updateVideo(Video video) async {
    try {
      await _firestore
          .collection('courses')
          .doc(video.courseId)
          .collection('chapters')
          .doc(video.chapterId)
          .collection('videos')
          .doc(video.id)
          .update(video.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVideo(Video video) async {
    try {
      await _firestore
          .collection('courses')
          .doc(video.courseId)
          .collection('chapters')
          .doc(video.chapterId)
          .collection('videos')
          .doc(video.id)
          .delete();

      // Update the order of remaining videos
     // await _reorderVideosAfterDelete(video);
    } catch (e) {
      rethrow;
    }
  }

}
