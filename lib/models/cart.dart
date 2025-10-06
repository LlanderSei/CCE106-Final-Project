import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // Create from Firestore document
  factory CartItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      quantity: data['quantity'] ?? 1,
    );
  }

  // Create a copy with modified fields
  CartItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}
