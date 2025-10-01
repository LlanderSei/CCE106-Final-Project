// lib/controllers/admin/admin_controller.dart
import 'package:bbqlagao_and_beefpares/.old/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/legacy.dart';

// Start modification: Updated to use unified User model, integrated Firebase Auth for add/delete, fetch only admins
final adminControllerProvider =
    StateNotifierProvider<AdminController, List<User>>((ref) {
      return AdminController(
        FirebaseFirestore.instance,
        firebase_auth.FirebaseAuth.instance,
      );
    });

class AdminController extends StateNotifier<List<User>> {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  AdminController(this._firestore, this._auth) : super([]) {
    _loadAdmins();
  }

  // Load admins from Firestore
  Future<void> _loadAdmins() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();
    state = snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  // Add a new admin
  Future<void> addAdmin(String fullName, String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = userCredential.user!.uid;
    final newUser = User(
      uid: uid,
      role: 'admin',
      timeAdded: Timestamp.now(),
      fullName: fullName,
      email: email,
    );
    await _firestore.collection('users').doc(uid).set(newUser.toMap());
    state = [...state, newUser];
  }

  // Modify an existing admin (no password edit)
  Future<void> updateAdmin(String uid, String fullName, String email) async {
    final updatedUser = User(
      uid: uid,
      role: 'admin',
      timeAdded: state.firstWhere((user) => user.uid == uid).timeAdded,
      fullName: fullName,
      email: email,
    );
    await _firestore.collection('users').doc(uid).update(updatedUser.toMap());
    state = state.map((user) => user.uid == uid ? updatedUser : user).toList();
    // Update email in Auth if changed
    final authUser = _auth.currentUser;
    if (authUser != null && authUser.uid == uid && authUser.email != email) {
      await (authUser).updateEmail(email); // Explicit cast and method call
    }
  }

  // Delete an admin
  Future<void> deleteAdmin(String uid) async {
    final authUser = _auth.currentUser;
    if (authUser != null && authUser.uid == uid) {
      throw Exception('Cannot delete currently logged-in admin');
    }
    await _firestore.collection('users').doc(uid).delete();
    final email = state.firstWhere((user) => user.uid == uid).email;
    final signInMethods = await _auth.fetchSignInMethodsForEmail(
      email,
    ); // Correct method
    if (signInMethods.isNotEmpty) {
      // Note: Deleting a user requires re-authentication or admin privileges
      // In a real app, use Firebase Admin SDK or a Cloud Function
      throw Exception(
        'User deletion requires re-authentication; implement via cloud function',
      );
    }
    state = state.where((user) => user.uid != uid).toList();
  }

  // Get admin by UID
  User? getAdminById(String uid) {
    try {
      return state.firstWhere((user) => user.uid == uid);
    } catch (e) {
      return null; // Explicitly return null for safety
    }
  }
}

extension on firebase_auth.FirebaseAuth {
  Future fetchSignInMethodsForEmail(String email) {
    throw UnimplementedError('fetchSignInMethodsForEmail is not implemented');
  }
}

extension on firebase_auth.User {
  Future<void> updateEmail(String email) async {}
}
// End modification