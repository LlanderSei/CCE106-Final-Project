// lib/models/admin/dish.dart
class Dish {
  String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<IngredientRequirement> ingredients;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.ingredients,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] ?? '',
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      ingredients: (json['ingredients'] as List? ?? [])
          .map((i) => IngredientRequirement.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
    };
  }
}

class IngredientRequirement {
  final String ingredientId;
  final int quantity;

  IngredientRequirement({required this.ingredientId, required this.quantity});

  factory IngredientRequirement.fromJson(Map<String, dynamic> json) {
    return IngredientRequirement(
      ingredientId: json['ingredientId'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'ingredientId': ingredientId, 'quantity': quantity};
  }
}
