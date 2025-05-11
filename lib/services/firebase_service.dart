// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
      throw e;
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
      throw e;
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

  // Course Methods
  Future<void> addCourse(Course course) async {
    try {
      await _firestore.collection('courses').add(course.toJson());
    } catch (e) {
      throw e;
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
      throw e;
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
      throw e;
    }
  }

  // Video Methods
  Future<void> addVideo(Video video) async {
    try {
      await _firestore
          .collection('courses')
          .doc(video.courseId)
          .collection('videos')
          .add(video.toJson());
    } catch (e) {
      throw e;
    }
  }

  Stream<List<Video>> getVideos(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('videos')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['course_id'] = courseId;
        return Video.fromJson(data, doc.id);
      }).toList();
    });
  }

  Future<void> updateVideo(Video video) async {
    try {
      await _firestore
          .collection('courses')
          .doc(video.courseId)
          .collection('videos')
          .doc(video.id)
          .update(video.toJson());
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteVideo(Video video) async {
    try {
      await _firestore
          .collection('courses')
          .doc(video.courseId)
          .collection('videos')
          .doc(video.id)
          .delete();
    } catch (e) {
      throw e;
    }
  }
}
