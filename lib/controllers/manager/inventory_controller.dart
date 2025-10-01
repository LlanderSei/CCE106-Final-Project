// lib/controllers/inventory_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbqlagao_and_beefpares/models/item.dart';

class InventoryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'inventory';

  Stream<List<Item>> get getItems => _firestore
      .collection(_collection)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList(),
      );

  Future<void> addItem(Item item) async {
    await _firestore.collection(_collection).add(item.toFirestore());
  }

  Future<void> updateItem(String id, Item item) async {
    await _firestore.collection(_collection).doc(id).update(item.toFirestore());
  }

  Future<void> deleteItem(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
