import 'package:flutter/foundation.dart';
import '../models/dish.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {};
  final Map<String, Dish> _dishes = {};

  Map<String, int> get items => _items;
  Map<String, Dish> get dishes => _dishes;

  int get itemCount => _items.values.fold(0, (sum, count) => sum + count);

  void addToCart(Dish dish) {
    final id = dish.id ?? dish.name; // Use name as fallback ID if needed
    if (_items.containsKey(id)) {
      _items[id] = _items[id]! + 1;
    } else {
      _items[id] = 1;
      _dishes[id] = dish;
    }
    notifyListeners();
  }

  void removeFromCart(String dishId) {
    if (_items.containsKey(dishId)) {
      if (_items[dishId]! > 1) {
        _items[dishId] = _items[dishId]! - 1;
      } else {
        _items.remove(dishId);
        _dishes.remove(dishId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _dishes.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((dishId, quantity) {
      total += _dishes[dishId]!.price * quantity;
    });
    return total;
  }
}
