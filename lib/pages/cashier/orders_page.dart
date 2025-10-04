//orders_page.dart
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/orders_tab_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/preparing_tab_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/serving_tab_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/new_order_page.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';

class OrdersPage extends StatefulWidget {
  final Function(bool)? onFabVisibilityChanged;

  const OrdersPage({super.key, this.onFabVisibilityChanged});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;
  late ValueNotifier<bool> _showFabNotifier;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _showFabNotifier = ValueNotifier<bool>(true);
    _tabs = [
      OrdersTabPage(
        onFabVisibilityChanged: (visible) {
          _showFabNotifier.value = visible;
        },
      ),
      const PreparingTabPage(),
      const ServingTabPage(),
    ];
  }

  Future<void> _completeAllServing() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete All Serving Orders'),
        content: const Text(
          'Are you sure you want to set all serving orders to completed?',
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.orangeAccent),
              foregroundColor: Colors.orangeAccent,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          GradientButton(
            colors: GradientColorSets.set1,
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _loading = true;
              });
              try {
                final controller = OrderController();
                final stream = controller.getOrdersByStatus('serving');
                final snapshot = await stream.first;
                final futures = snapshot.map((order) async {
                  await controller.updateOrderStatus(order.id!, 'completed');
                });
                await Future.wait(futures);
                Toast.show('All serving orders completed');
              } catch (e) {
                Toast.show('Error: $e');
              } finally {
                setState(() {
                  _loading = false;
                });
              }
            },
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: GradientCircularProgressIndicator())
          : _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Reset FAB visibility when switching back to Orders tab
          if (index == 0) {
            _showFabNotifier.value = true;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Preparing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.room_service),
            label: 'Serving',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButton: _currentIndex == 0
          ? ValueListenableBuilder<bool>(
              valueListenable: _showFabNotifier,
              builder: (context, value, child) {
                return AnimatedOpacity(
                  opacity: value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !value, // Disable touch events when hidden
                    child: FloatingActionButton(
                      backgroundColor: Colors.redAccent[100],
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      tooltip: 'Add New Order',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewOrderPage(),
                          ),
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                );
              },
            )
          : _currentIndex == 2
          ? FloatingActionButton(
              backgroundColor: Colors.redAccent[100],
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              tooltip: 'Complete All',
              onPressed: _completeAllServing,
              child: const Icon(Icons.checklist),
            )
          : null,
    );
  }
}
