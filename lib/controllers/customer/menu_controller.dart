import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/dish.dart';

class MenuController {
  // Singleton instance
  static final MenuController _instance = MenuController._internal();
  static MenuController get instance => _instance;
  MenuController._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menu';

  Stream<List<Dish>> getAllDishes() => _firestore
      .collection(_collection)
      .where('isVisible', isEqualTo: true)
      .where('isAvailable', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Dish.fromFirestore(doc)).toList(),
      );

  Stream<List<Dish>> getDishesByCategory(String category) {
    if (category == 'All') return getAllDishes();

    if (category == 'Misc.') {
      return getAllDishes().map(
        (dishes) => dishes.where((dish) => dish.categories.isEmpty).toList(),
      );
    }

    return getAllDishes().map(
      (dishes) => dishes
          .where(
            (dish) =>
                dish.categories.any((cat) => cat['categoryName'] == category),
          )
          .toList(),
    );
  }

  Stream<List<String>> getAllCategories() => _firestore
      .collection(_collection)
      .where('isVisible', isEqualTo: true)
      .where('isAvailable', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final Set<String> categories = {};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final dishCategories = List<Map<String, dynamic>>.from(
            data['categories'] ?? [],
          );
          for (final cat in dishCategories) {
            final name = cat['categoryName'];
            if (name is String && name.isNotEmpty) {
              categories.add(name);
            }
          }
        }
        return categories.toList()..sort();
      });
}
