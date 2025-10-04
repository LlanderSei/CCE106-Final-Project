import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbqlagao_and_beefpares/models/dish.dart';

class MenuController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menu';

  Stream<List<Dish>> get getDishes => _firestore
      .collection(_collection)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Dish.fromFirestore(doc)).toList(),
      );

  Future<void> addDish(Dish dish) async {
    await _firestore.collection(_collection).add(dish.toFirestore());
    Toast.show('Menu added successfully');
  }

  Future<void> updateDish(String id, Dish dish) async {
    await _firestore.collection(_collection).doc(id).update(dish.toFirestore());
    Toast.show('Menu updated successfully');
  }

  Future<void> deleteDish(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
    Toast.show('Menu added successfully');
  }
}
