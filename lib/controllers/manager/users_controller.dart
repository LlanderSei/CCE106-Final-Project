import 'package:bbqlagao_and_beefpares/customtoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:bbqlagao_and_beefpares/models/user.dart';
import 'package:flutter/material.dart';

class UsersController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final String _collection = 'users';

  Stream<List<User>> get getUsers => _firestore
      .collection(_collection)
      .where('role', whereIn: ['Admin', 'Manager', 'Cashier'])
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => User.fromFirestore(doc)).toList(),
      );

  Future<void> addUser(dynamic context, User user, String password) async {
    try {
      auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: user.email,
            password: password,
          );
      String uid = userCredential.user!.uid;
      await _firestore.collection(_collection).doc(uid).set(user.toFirestore());
      await _firestore.collection(_collection).doc(uid).update({
        'provider': 'Email/Password',
      });
      if (context != null && (context as BuildContext).mounted) {
        Toast.show(context, 'User added successfully');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(dynamic context, id, User user) async {
    await _firestore.collection(_collection).doc(id).update(user.toFirestore());
    if (context != null && (context as BuildContext).mounted) {
      Toast.show(context, 'User updated successfully');
    }
  }
}
