// pages/cashier/cashier_home_page.dart
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/orders_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/order_history_page.dart';

class CashierHomePage extends StatefulWidget {
  const CashierHomePage({super.key});

  @override
  State<CashierHomePage> createState() => _CashierHomePageState();
}

class _CashierHomePageState extends State<CashierHomePage> {
  String _currentPage = 'orders';
  String _appBarTitle = 'Cashier Dashboard';
  late ValueNotifier<bool> _showFabNotifier;

  void _onFabVisibilityChanged(bool visible) {
    _showFabNotifier.value = visible;
  }

  @override
  void initState() {
    super.initState();
    _showFabNotifier = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _showFabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle, style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.redAccent, Colors.red, Colors.orangeAccent],
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 75.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.redAccent, Colors.red, Colors.orangeAccent],
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'BBQ Lagao & Beef Pares',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Text(
                      'Staff Navigation',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.list_alt,
                      color: _currentPage == 'orders'
                          ? Colors.white
                          : Colors.redAccent,
                    ),
                    title: Text(
                      'Orders',
                      style: TextStyle(
                        color: _currentPage == 'orders'
                            ? Colors.white
                            : Colors.redAccent,
                      ),
                    ),
                    selected: _currentPage == 'orders',
                    selectedTileColor: Colors.redAccent.withValues(alpha: .75),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentPage = 'orders';
                        _appBarTitle = 'Orders';
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.history,
                      color: _currentPage == 'orderHistory'
                          ? Colors.white
                          : Colors.redAccent,
                    ),
                    title: Text(
                      'Order History',
                      style: TextStyle(
                        color: _currentPage == 'orderHistory'
                            ? Colors.white
                            : Colors.redAccent,
                      ),
                    ),
                    selected: _currentPage == 'orderHistory',
                    selectedTileColor: Colors.redAccent.withOpacity(0.75),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentPage = 'orderHistory';
                        _appBarTitle = 'Order History';
                      });
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close menu',
                ),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case 'orders':
        return OrdersPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'orderHistory':
        return const OrderHistoryPage();
      default:
        return const Center(child: Text('Page not implemented'));
    }
  }
}
