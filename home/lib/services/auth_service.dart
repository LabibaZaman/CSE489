import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user
  Future<String?> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'createdAt': Timestamp.now(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Login user
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Get current user role
  Future<String> getCurrentUserRole() async {
    User? user = getCurrentUser();
    if (user == null) return 'none';

    Map<String, dynamic>? userData = await getUserData(user.uid);
    return userData?['role'] ?? 'patient';
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    String role = await getCurrentUserRole();
    return role == 'admin' || role == 'doctor' || role == 'receptionist';
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}