// pages/cashier/cashier_home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/orders_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/order_history_page.dart';
import 'package:bbqlagao_and_beefpares/models/user.dart';
import 'package:bbqlagao_and_beefpares/controllers/auth/auth_controller.dart';

class CashierHomePage extends StatefulWidget {
  const CashierHomePage({super.key});

  @override
  State<CashierHomePage> createState() => _CashierHomePageState();
}

class _CashierHomePageState extends State<CashierHomePage> {
  String _currentPage = 'orders';
  String _appBarTitle = 'Cashier Dashboard';
  late ValueNotifier<bool> _showFabNotifier;
  final AuthController _authController = AuthController();

  void _onFabVisibilityChanged(bool visible) {
    _showFabNotifier.value = visible;
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authController.signOut();
              if (mounted) {
                Provider.of<UserProvider>(context, listen: false).clearUser();
                Navigator.pushReplacementNamed(context, '/hello');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
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
    final user = Provider.of<UserProvider>(context).user;
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
            if (user != null)
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logged in as:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    Text(user.name, style: TextStyle(fontSize: 16)),
                    Text(user.email, style: TextStyle(color: Colors.grey[600])),
                  ],
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
                        _showFabNotifier.value = true;
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
                    selectedTileColor: Colors.redAccent.withValues(alpha: .75),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentPage = 'orderHistory';
                        _appBarTitle = 'Order History';
                        _showFabNotifier.value = false;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: _logout,
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
