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
      throw e;
    }
  }

  // Delete a student from Authentication
  Future<void> deleteStudent(String uid) async {
    try {
      // We need to sign in as the student to delete them - this requires admin privileges
      // In a real app, you should use Firebase Admin SDK or Cloud Functions
      // Here's a placeholder that would need to be implemented on the backend

      // For demo purposes assuming we have admin SDK:
      // await admin.auth().deleteUser(uid);

      // This is a placeholder - in a real implementation, you'd use Firebase Admin SDK
      throw Exception("Deleting users requires Firebase Admin SDK or Cloud Functions");
    } catch (e) {
      throw e;
    }
  }
}