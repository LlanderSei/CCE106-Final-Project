// pages/cashier/orders_page.dart
import 'package:bbqlagao_and_beefpares/customtoast.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/order_tab_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/preparing_tab_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/serving_tab_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/new_order_page.dart';

class OrdersPage extends StatefulWidget {
  final Function(bool)? onFabVisibilityChanged;

  const OrdersPage({super.key, this.onFabVisibilityChanged});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _currentIndex = 0;
  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      OrderTabPage(onFabVisibilityChanged: widget.onFabVisibilityChanged),
      const PreparingTabPage(),
      const ServingTabPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
          ? FloatingActionButton(
              backgroundColor: Colors.redAccent[100],
              foregroundColor: Colors.white,
              shape: CircleBorder(),
              tooltip: 'Add New Order',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewOrderPage()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
