// pages/cashier/new_order_page.dart
import 'package:flutter/material.dart' hide MenuController;
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/menu_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/models/dish.dart';
import 'package:bbqlagao_and_beefpares/customtoast.dart';
import 'payment_page.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final OrderController _orderController = OrderController();
  final MenuController _menuController = MenuController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _selectedDishes = [];
  bool _toPrepare = false;
  bool _isPaymentEnabled = true;
  double _totalAmount = 0.0;
  final String _cashierName = 'Temporary Cashier';

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  void _addDish() {
    showDialog(
      context: context,
      builder: (context) => _DishSelectionDialog(
        menuController: _menuController,
        selectedDishes: _selectedDishes,
        onSelected: (dishId, dishName, price) {
          setState(() {
            _selectedDishes.add({
              'dishId': dishId,
              'name': dishName,
              'price': price,
              'quantity': 1,
              'totalPrice': price,
              'warning': false,
            });
          });
          _checkAffordability();
          _calculateTotal();
        },
      ),
    );
  }

  void _updateQuantity(String dishId, int newQty) {
    final index = _selectedDishes.indexWhere((d) => d['dishId'] == dishId);
    if (index != -1 && newQty >= 1) {
      setState(() {
        _selectedDishes[index]['quantity'] = newQty;
        _selectedDishes[index]['totalPrice'] =
            _selectedDishes[index]['price'] * newQty;
      });
      _checkAffordabilityForDish(dishId);
      _calculateTotal();
    }
  }

  void _removeDish(String dishId) {
    setState(() {
      _selectedDishes.removeWhere((d) => d['dishId'] == dishId);
    });
    _checkAffordability();
    _calculateTotal();
  }

  Future<void> _checkAffordability() async {
    bool allAffordable = true;
    for (var dish in _selectedDishes) {
      final affordable = await _orderController.canAffordQuantity(
        dish['dishId'],
        dish['quantity'],
      );
      final index = _selectedDishes.indexWhere(
        (d) => d['dishId'] == dish['dishId'],
      );
      if (index != -1) {
        setState(() {
          _selectedDishes[index]['warning'] = !affordable;
        });
      }
      if (!affordable) allAffordable = false;
    }
    setState(() {
      _isPaymentEnabled = allAffordable && _selectedDishes.isNotEmpty;
    });
  }

  Future<void> _checkAffordabilityForDish(String dishId) async {
    final index = _selectedDishes.indexWhere((d) => d['dishId'] == dishId);
    if (index != -1) {
      final affordable = await _orderController.canAffordQuantity(
        dishId,
        _selectedDishes[index]['quantity'],
      );
      setState(() {
        _selectedDishes[index]['warning'] = !affordable;
      });
    }
    await _checkAffordability();
  }

  void _calculateTotal() {
    _totalAmount = _selectedDishes.fold(
      0.0,
      (sum, d) => sum + (d['totalPrice'] as double),
    );
    setState(() {});
  }

  Future<void> _proceedToPayment() async {
    if (!_isPaymentEnabled) {
      Toast.show(
        context,
        'Cannot proceed: Insufficient ingredients for some items.',
      );
      return;
    }
    final nextOrderId = await _orderController.getNextOrderId();
    final now = DateTime.now();
    final order = Order(
      orderId: nextOrderId,
      name: _cashierName,
      items: _selectedDishes
          .map((d) => {'dishId': d['dishId'], 'quantity': d['quantity']})
          .toList(),
      status: _toPrepare ? 'preparing' : 'reviewing',
      totalAmount: _totalAmount,
      createdAt: now,
      updatedAt: now,
      preparedAt: _toPrepare ? now : null,
    );
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaymentPage(order: order, totalAmount: _totalAmount),
      ),
    );
    if (result == true) {
      await _orderController.addOrder(order);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Order', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Initiated By',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '$_cashierName (Cashier)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addDish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Text(
                'Add Dish',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedDishes.length,
              itemBuilder: (context, index) {
                final dish = _selectedDishes[index];
                return Card(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.orange[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      title: Text(dish['name']),
                      subtitle: Text(
                        'Price: ₱${dish['price']} | ₱${dish['totalPrice']}',
                        style: TextStyle(
                          color: dish['warning'] ? Colors.red : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _updateQuantity(
                              dish['dishId'],
                              dish['quantity'] - 1,
                            ),
                          ),
                          Text('${dish['quantity']}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _updateQuantity(
                              dish['dishId'],
                              dish['quantity'] + 1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeDish(dish['dishId']),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 3, 15, 7),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.black26,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('To Prepare'),
                        Switch(
                          value: _toPrepare,
                          onChanged: (value) =>
                              setState(() => _toPrepare = value),
                        ),
                      ],
                    ),
                    Text('Total Amount: $_totalAmount'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _isPaymentEnabled ? _proceedToPayment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                      ),
                      child: const Text(
                        'To Payment',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DishSelectionDialog extends StatefulWidget {
  final MenuController menuController;
  final List<Map<String, dynamic>> selectedDishes;
  final Function(String, String, double) onSelected;

  const _DishSelectionDialog({
    required this.menuController,
    required this.selectedDishes,
    required this.onSelected,
  });

  @override
  State<_DishSelectionDialog> createState() => _DishSelectionDialogState();
}

class _DishSelectionDialogState extends State<_DishSelectionDialog> {
  final _searchController = TextEditingController();
  String _searchText = '';
  Dish? _selectedDish;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Dish'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Dishes',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Dish>>(
                stream: widget.menuController.getDishes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final dishes = snapshot.data!
                        .where(
                          (dish) =>
                              dish.isVisible &&
                              dish.isAvailable &&
                              dish.name.toLowerCase().contains(_searchText),
                        )
                        .toList();
                    return ListView.builder(
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        final alreadyAdded = widget.selectedDishes.any(
                          (d) => d['dishId'] == dish.id,
                        );
                        return ListTile(
                          title: Text(dish.name),
                          subtitle: Text('₱${dish.price}'),
                          enabled: !alreadyAdded,
                          onTap: alreadyAdded
                              ? null
                              : () => setState(() => _selectedDish = dish),
                          selected: _selectedDish?.id == dish.id,
                        );
                      },
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedDish == null
              ? null
              : () {
                  widget.onSelected(
                    _selectedDish!.id!,
                    _selectedDish!.name,
                    _selectedDish!.price,
                  );
                  Navigator.pop(context);
                },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
