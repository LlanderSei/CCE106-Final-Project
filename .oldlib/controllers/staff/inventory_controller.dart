// lib/controllers/admin/inventory_controller.dart
// Start modification: Added CRUD methods for ingredients
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/.old/models/admin/ingredient.dart'; // Adjust import based on project name

final inventoryProvider = StreamProvider<List<Ingredient>>((ref) {
  return FirebaseFirestore.instance.collection('ingredients').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs
        .map((doc) => Ingredient.fromJson(doc.data())..id = doc.id)
        .toList();
  });
});

class InventoryController {
  Future<void> addIngredient(Ingredient ingredient) async {
    await FirebaseFirestore.instance
        .collection('ingredients')
        .add(ingredient.toJson());
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    await FirebaseFirestore.instance
        .collection('ingredients')
        .doc(ingredient.id)
        .update(ingredient.toJson());
  }

  Future<void> deleteIngredient(String id) async {
    await FirebaseFirestore.instance.collection('ingredients').doc(id).delete();
  }

  Future<void> updateStock(String id, int newQuantity) async {
    await FirebaseFirestore.instance.collection('ingredients').doc(id).update({
      'stockQuantity': newQuantity,
    });
  }
}

final inventoryControllerProvider = Provider<InventoryController>(
  (ref) => InventoryController(),
);
// End modification
