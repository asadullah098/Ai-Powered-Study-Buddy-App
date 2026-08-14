// lib/services/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Save todo items
  Future<void> saveTodoItems(List<Map<String, dynamic>> items) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('todos')
        .doc('items')
        .set({'items': items, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // Load todo items
  Future<List<Map<String, dynamic>>> loadTodoItems() async {
    if (currentUser == null) return [];

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('todos')
        .doc('items')
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['items'] ?? []);
    }

    return [];
  }

  // Save flashcards
  Future<void> saveFlashcards(List<Map<String, dynamic>> flashcards) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('flashcards')
        .doc('items')
        .set({'items': flashcards, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // Load flashcards
  Future<List<Map<String, dynamic>>> loadFlashcards() async {
    if (currentUser == null) return [];

    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('flashcards')
        .doc('items')
        .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['items'] ?? []);
    }

    return [];
  }

  // Handle authentication exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}