import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/cart.dart';
import '../../models/user.dart';

class CartController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<CartItem> _items = [];
  final String userId;

  CartController(this.userId);

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  // Stream of cart items from Firestore
  Stream<List<CartItem>> get cartStream {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CartItem.fromDocument(doc))
              .toList();
        });
  }

  // Add item to cart
  Future<void> addItem(
    String id,
    String name,
    String? description,
    double price,
    String? imageUrl,
  ) async {
    try {
      final existingIndex = _items.indexWhere((item) => item.id == id);

      if (existingIndex >= 0) {
        // Item exists, increase quantity
        await increaseQuantity(id);
      } else {
        // Add new item
        final cartItem = CartItem(
          id: id,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(id)
            .set(cartItem.toMap());

        _items.add(cartItem);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Remove item from cart
  Future<void> removeItem(String id) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(id)
          .delete();

      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      // Handle case where document might not exist
      if (e is FirebaseException && e.code == 'not-found') {
        // Document already deleted, just remove from local list
        _items.removeWhere((item) => item.id == id);
        notifyListeners();
      } else {
        rethrow;
      }
    }
  }

  // Increase item quantity
  Future<void> increaseQuantity(String id) async {
    try {
      final item = _items.firstWhere((item) => item.id == id);
      item.quantity++;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(id)
          .update({'quantity': item.quantity});

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Decrease item quantity
  Future<void> decreaseQuantity(String id) async {
    try {
      final item = _items.firstWhere((item) => item.id == id);
      if (item.quantity > 1) {
        item.quantity--;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(id)
            .update({'quantity': item.quantity});
      } else {
        await removeItem(id);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Clear cart
  Future<void> clear() async {
    try {
      final batch = _firestore.batch();
      final cartDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      for (var doc in cartDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _items.clear();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Initialize cart from Firestore
  Future<void> loadCart() async {
    try {
      final cartDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      _items.clear();
      _items.addAll(cartDocs.docs.map((doc) => CartItem.fromDocument(doc)));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Update cart item
  Future<void> updateItem(CartItem item) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(item.id)
          .update(item.toMap());

      final index = _items.indexWhere((existing) => existing.id == item.id);
      if (index >= 0) {
        _items[index] = item;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
