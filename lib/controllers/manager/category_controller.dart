//controllers/manager/category_controller.dart
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbqlagao_and_beefpares/models/category.dart';

class CategoryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  Stream<List<Category>> get getCategories => _firestore
      .collection(_collection)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList(),
      );

  Future<void> addCategory(Category category) async {
    await _firestore.collection(_collection).add({
      ...category.toFirestore(),
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    Toast.show('Category added successfully');
  }

  Future<void> updateCategory(String id, Category category) async {
    await _firestore.collection(_collection).doc(id).update({
      ...category.toFirestore(),
      'updatedAt': Timestamp.now(),
    });
    Toast.show('Category updated successfully');
  }

  Future<void> deleteCategory(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
    Toast.show('Category deleted successfully');
  }
}
