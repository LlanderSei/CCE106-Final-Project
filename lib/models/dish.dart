import 'package:cloud_firestore/cloud_firestore.dart';

class Dish {
  final String? id;
  final String name;
  final String? description;
  final double price;
  final bool isVisible;
  final bool isAvailable;
  final List<Map<String, dynamic>> ingredients;
  final String? imageUrl;

  Dish({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.isVisible = true,
    this.isAvailable = true,
    required this.ingredients,
    this.imageUrl,
  });

  factory Dish.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Dish(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      price: (data['price'] ?? 0.0).toDouble(),
      isVisible: data['isVisible'] ?? true,
      isAvailable: data['isAvailable'] ?? true,
      ingredients: List<Map<String, dynamic>>.from(data['ingredients'] ?? []),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      'isVisible': isVisible,
      'isAvailable': isAvailable,
      'ingredients': ingredients,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
