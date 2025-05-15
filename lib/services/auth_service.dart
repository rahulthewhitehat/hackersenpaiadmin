// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a student with email and password
  Future<UserCredential> registerStudent(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Delete a student from Authentication
  Future<void> deleteStudent(String uid) async {
    try {

      // This is a placeholder - in a real implementation, you'd use Firebase Admin SDK
      throw Exception("Deleting users requires Firebase Admin SDK or Cloud Functions");
    } catch (e) {
      rethrow;
    }
  }
}