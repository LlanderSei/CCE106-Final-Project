// controllers/order_controller.dart
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:bbqlagao_and_beefpares/models/order.dart';

class OrderController {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  final String _collection = 'orders';

  Stream<List<Order>> getOrdersByStatus(String status) => _firestore
      .collection(_collection)
      .where('status', isEqualTo: status)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList(),
      );

  Future<int> getNextOrderId() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('orderId', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return 1;
    return 1 + snapshot.docs.first.data()['orderId'] as int;
  }

  Future<void> addOrder(Order order) async {
    await _firestore.collection(_collection).add(order.toFirestore());
    await _deductIngredients(order);
    Toast.show('Order successfully created!');
  }

  Future<void> updateOrderStatus(
    String orderId,
    String status, {
    DateTime? timestamp,
  }) async {
    final data = {
      'status': status,
      'updatedAt': fs.Timestamp.fromDate(DateTime.now()),
    };
    if (timestamp != null) {
      if (status == 'preparing')
        data['preparedAt'] = fs.Timestamp.fromDate(timestamp);
      if (status == 'serving')
        data['servedAt'] = fs.Timestamp.fromDate(timestamp);
    }
    await _firestore.collection(_collection).doc(orderId).update(data);
  }

  Future<bool> canAffordQuantity(String dishId, int quantity) async {
    final dishSnapshot = await _firestore.collection('menu').doc(dishId).get();
    if (!dishSnapshot.exists) return false;
    final dishData = dishSnapshot.data()!;
    final ingredients = List<Map<String, dynamic>>.from(
      dishData['ingredients'] ?? [],
    );
    for (var ing in ingredients) {
      final itemId = ing['itemId'];
      final reqQty = (ing['quantity'] as int) * quantity;
      final itemSnapshot = await _firestore
          .collection('inventory')
          .doc(itemId)
          .get();
      if (!itemSnapshot.exists ||
          (itemSnapshot.data()?['quantity'] ?? 0) < reqQty) {
        return false;
      }
    }
    return true;
  }

  Future<void> _deductIngredients(Order order) async {
    for (var item in order.items) {
      final dishId = item['dishId'];
      final qty = item['quantity'] as int;
      final dishSnapshot = await _firestore
          .collection('menu')
          .doc(dishId)
          .get();
      final ingredients = List<Map<String, dynamic>>.from(
        dishSnapshot.data()?['ingredients'] ?? [],
      );
      for (var ing in ingredients) {
        final itemId = ing['itemId'];
        final deductQty = (ing['quantity'] as int) * qty;
        await _firestore.collection('inventory').doc(itemId).update({
          'quantity': fs.FieldValue.increment(-deductQty),
        });
      }
    }
  }
}
