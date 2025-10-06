// pages\cashier\new_order_page.dart
import 'package:bbqlagao_and_beefpares/models/user.dart';
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_checkbox.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/menu_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/models/dish.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:provider/provider.dart';
import 'payment_page.dart';

class NewOrderPage extends StatefulWidget {
  const NewOrderPage({super.key});

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  final OrderController _orderController = OrderController();
  final MenuController _menuController = MenuController.instance;
  List<Map<String, dynamic>> _selectedDishes = [];
  bool _toPrepare = false;
  bool _isPaymentEnabled = false;
  bool _isLoading = false;
  double _totalAmount = 0.0;
  String _cashierName = 'Temporary Cashier';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      setState(() {
        _cashierName = user?.name ?? 'Temporary Cashier';
      });
    });
    _calculateTotal();
  }

  void _addDish() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _DishSelectionBottomSheet(
        menuController: _menuController,
        selectedDishIds: _selectedDishes
            .map((d) => d['dishId'] as String)
            .toSet(),
        onAdd: (newDishes) {
          setState(() {
            _selectedDishes.addAll(newDishes);
            _isPaymentEnabled = false;
            _isLoading = true;
          });
          _calculateTotal();
          _checkAffordability().then((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
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
        _isPaymentEnabled = false;
        _isLoading = true;
      });
      _calculateTotal();
      _checkAffordabilityForDish(dishId).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _removeDish(String dishId) {
    setState(() {
      _selectedDishes.removeWhere((d) => d['dishId'] == dishId);
      _isPaymentEnabled = false;
      _isLoading = true;
    });
    _calculateTotal();
    _checkAffordability().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _checkAffordability() async {
    if (_selectedDishes.isEmpty) {
      setState(() {
        _isPaymentEnabled = false;
      });
      return;
    }

    final dishIds = _selectedDishes.map((d) => d['dishId'] as String).toList();
    Map<String, bool> affordabilityMap = {};

    for (String dishId in dishIds) {
      try {
        final dish = _selectedDishes.firstWhere((d) => d['dishId'] == dishId);
        final affordable = await _orderController.canAffordQuantity(
          dishId,
          dish['quantity'],
        );
        affordabilityMap[dishId] = affordable;
      } catch (e) {
        print('Error: $e');
      }
    }

    setState(() {
      bool allAffordable = true;
      for (var dish in _selectedDishes) {
        final dishId = dish['dishId'] as String;
        dish['warning'] = !(affordabilityMap[dishId] ?? true);
        if (dish['warning']) allAffordable = false;
      }
      _isPaymentEnabled = allAffordable && _selectedDishes.isNotEmpty;
    });
  }

  Future<void> _checkAffordabilityForDish(String dishId) async {
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
    setState(() {
      _isLoading = true;
    });
    await _checkAffordability();
    setState(() {
      _isLoading = false;
    });
    if (!_isPaymentEnabled) {
      Toast.show('Cannot proceed: Insufficient ingredients for some items.');
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
      // Navigate back to cashier's homepage by popping until we reach it
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEnabled = _isPaymentEnabled && !_isLoading;
    final Color buttonColor = isEnabled ? Colors.redAccent : Colors.grey;
    final Widget buttonLabel;
    if (_isLoading) {
      buttonLabel = Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          GradientCircularProgressIndicator(),
          SizedBox(width: 8),
          Text('Checking...', style: TextStyle(color: Colors.white)),
        ],
      );
    } else if (_selectedDishes.isEmpty) {
      buttonLabel = const Text(
        'Add Dishes First',
        style: TextStyle(color: Colors.white),
      );
    } else if (!_isPaymentEnabled) {
      buttonLabel = const Text(
        'Max Quantity Reached',
        style: TextStyle(color: Colors.white),
      );
    } else {
      buttonLabel = Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.payment, color: Colors.white),
          SizedBox(width: 8),
          Text('To Payment', style: TextStyle(color: Colors.white)),
        ],
      );
    }

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
                Text('Order Initiated By', textScaler: TextScaler.linear(.75)),
                Text(
                  '$_cashierName (Cashier)',
                  textScaler: TextScaler.linear(1.25),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: GradientButton(
                onPressed: _addDish,
                child: Text(
                  'Add Dish',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _selectedDishes.length,
              itemBuilder: (context, index) {
                final dish = _selectedDishes[index];
                return Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.orange[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      title: Text(dish['name']),
                      subtitle: Text(
                        'Price: ₱${dish['price']}\nSubtotal: ₱${dish['totalPrice']}',
                        style: TextStyle(
                          color: dish['warning'] ? Colors.red : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              final newQty = (dish['quantity'] as int) - 1;
                              if (newQty >= 1) {
                                _updateQuantity(dish['dishId'], newQty);
                              } else {
                                _removeDish(dish['dishId']);
                              }
                            },
                          ),
                          Text('${dish['quantity']}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _updateQuantity(
                              dish['dishId'],
                              (dish['quantity'] as int) + 1,
                            ),
                          ),
                          IconButton(
                            icon: GradientIcon(
                              icon: Icons.delete,
                              gradient: LinearGradient(
                                colors: GradientColorSets.set2,
                              ),
                              offset: Offset.zero,
                            ),
                            onPressed: () => _removeDish(dish['dishId']),
                            onLongPress: () => Toast.show('Delete item'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 16),
              GradientCheckbox(
                value: _toPrepare,
                onChanged: (val) => setState(() => _toPrepare = val!),
              ),
              const Expanded(child: Text('Prepare Immediately?')),
              const SizedBox(width: 16),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: ₱$_totalAmount',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isEnabled ? _proceedToPayment : null,
        backgroundColor: buttonColor,
        label: buttonLabel,
      ),
    );
  }
}

class _DishSelectionBottomSheet extends StatefulWidget {
  final MenuController menuController;
  final Set<String> selectedDishIds;
  final Function(List<Map<String, dynamic>>) onAdd;

  const _DishSelectionBottomSheet({
    required this.menuController,
    required this.selectedDishIds,
    required this.onAdd,
  });

  @override
  State<_DishSelectionBottomSheet> createState() =>
      _DishSelectionBottomSheetState();
}

class _DishSelectionBottomSheetState extends State<_DishSelectionBottomSheet> {
  String _searchText = '';
  final List<Map<String, dynamic>> _selectedDishes = [];

  bool _isSelected(Dish dish) {
    return _selectedDishes.any((m) => m['id'] == dish.id);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) =>
                  setState(() => _searchText = val.toLowerCase()),
              decoration: const InputDecoration(
                labelText: 'Search Dishes',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Dish>>(
              stream: widget.menuController.getAllDishesForStaff(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: GradientCircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No dishes available.'));
                }
                final availableDishes = snapshot.data!
                    .where(
                      (dish) =>
                          dish.isVisible &&
                          dish.isAvailable &&
                          !widget.selectedDishIds.contains(dish.id) &&
                          dish.name.toLowerCase().contains(_searchText),
                    )
                    .toList();
                return ListView.builder(
                  controller: scrollController,
                  itemCount: availableDishes.length,
                  itemBuilder: (context, index) {
                    final dish = availableDishes[index];
                    final isSelected = _isSelected(dish);
                    return ListTile(
                      leading: GradientCheckbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val!) {
                              _selectedDishes.add({
                                'id': dish.id,
                                'name': dish.name,
                                'price': dish.price,
                              });
                            } else {
                              _selectedDishes.removeWhere(
                                (m) => m['id'] == dish.id,
                              );
                            }
                          });
                        },
                      ),
                      title: Text(dish.name),
                      subtitle: Text('₱${dish.price}'),
                      trailing: dish.imageUrl != null
                          ? Image.network(
                              dish.imageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.image_not_supported),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  onPressed: () {
                    final newDishes = _selectedDishes
                        .map(
                          (m) => {
                            'dishId': m['id'],
                            'name': m['name'],
                            'price': m['price'],
                            'quantity': 1,
                            'totalPrice': m['price'],
                            'warning': false,
                          },
                        )
                        .toList();
                    widget.onAdd(newDishes);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add Dish',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
