// lib/models/admin/ingredient.dart
class Ingredient {
  String id;
  final String name;
  int stockQuantity;

  Ingredient({
    required this.id,
    required this.name,
    required this.stockQuantity,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      name: json['name'],
      stockQuantity: json['stockQuantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'stockQuantity': stockQuantity};
  }
}
