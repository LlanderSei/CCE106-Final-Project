// lib/controllers/admin/dish_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bbqlagao_and_beefpares/.old/models/admin/dish.dart';

final dishProvider = StreamProvider<List<Dish>>((ref) {
  return FirebaseFirestore.instance.collection('dishes').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Dish.fromJson(doc.data())..id = doc.id).toList();
  });
});

class DishController {
  Future<void> addDish(Dish dish) async {
    await FirebaseFirestore.instance.collection('dishes').add(dish.toJson());
  }

  Future<void> updateDish(Dish dish) async {
    await FirebaseFirestore.instance.collection('dishes').doc(dish.id).update(dish.toJson());
  }

  Future<void> deleteDish(String id) async {
    await FirebaseFirestore.instance.collection('dishes').doc(id).delete();
  }
}

final dishControllerProvider = Provider<DishController>((ref) => DishController());