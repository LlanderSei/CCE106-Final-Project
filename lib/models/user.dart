// lib/models/user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String role; // 'admin' or 'customer'
  final Timestamp timeAdded;
  final String? fullName;
  final String email;

  User({
    required this.uid,
    required this.role,
    required this.timeAdded,
    this.fullName,
    required this.email,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      role: map['role'],
      timeAdded: map['timeAdded'],
      fullName: map['fullName'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'timeAdded': timeAdded,
      'fullName': fullName,
      'email': email,
    };
  }
}