import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resturent/models/user.dart' as app_models;

import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  app_models.User? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return app_models.User(
      id: user.uid,
      email: user.email!,
      name: user.displayName ?? 'User',
      photoUrl: user.photoURL,
    );
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw Exception('User document not found');
        }

        final data = userDoc.data() as Map<String, dynamic>? ?? {};
        return AppUser(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          isAdmin: data['isAdmin'] ?? false,
          name: data['name']?.toString(),
          photoUrl: data['photoUrl']?.toString(),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<app_models.User?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user == null) return null;

      // Update display name
      await user.updateDisplayName(name);

      // Create user document in Firestore
      final newUser = app_models.User(
        id: user.uid,
        email: user.email!,
        name: name,
      );

      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update user profile
  Future<app_models.User> updateUserProfile(app_models.User updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  // Stream of auth state changes
  Stream<app_models.User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final userData = await _firestore.collection('users').doc(user.uid).get();
      if (userData.exists) {
        return app_models.User.fromJson({
          ...userData.data()!,
          'id': user.uid,
          'email': user.email!,
        });
      }

      return app_models.User(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? 'User',
      );
    });
  }
}
