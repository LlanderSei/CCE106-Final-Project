//models/category.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String? id;
  final String name;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Category({this.id, required this.name, this.createdAt, this.updatedAt});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }
}
