import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

class AuthController {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to handle user login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Sign in user with Firebase Auth
      final auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        return {'success': false, 'message': 'Login failed. Please try again.'};
      }

      // Get the user's data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return {'success': false, 'message': 'User profile not found.'};
      }

      // Create CustomUser object
      final customUser = User.fromFirestore(userDoc);

      return {'success': true, 'user': customUser};
    } on auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message =
              'No account found with this email. Please check your email address or sign up for a new account.';
          break;
        case 'wrong-password':
          message =
              'Incorrect password. Please try again or use "Forgot Password" to reset it.';
          break;
        case 'invalid-email':
          message =
              'The email address is not valid. Please enter a valid email.';
          break;
        case 'user-disabled':
          message =
              'This account has been disabled. Please contact support for assistance.';
          break;
        case 'too-many-requests':
          message =
              'Too many failed login attempts. Please wait a few minutes before trying again.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection and try again.';
          break;
        case 'invalid-credential':
          message =
              'The supplied auth credential is incorrect, malformed or has expired.';
          break;
        default:
          message =
              'Login failed due to an unexpected error. Please try again later.\nErrors: $e';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Function to sign out user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Function to check if user is currently logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Function to get current user data
  Future<User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) return null;

    return User.fromFirestore(userDoc);
  }

  // Function to handle user signup
  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Create user with Firebase Auth
      final auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        return {
          'success': false,
          'message': 'Signup failed. Please try again.',
        };
      }

      // Create user document in Firestore
      final user = User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: 'Customer',
        provider: 'Email/Password',
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(user.toFirestore());

      return {'success': true, 'user': user};
    } on auth.FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message =
              'An account with this email already exists. Please sign in instead.';
          break;
        case 'invalid-email':
          message = 'Invalid email format.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Please choose a stronger password.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }
}
