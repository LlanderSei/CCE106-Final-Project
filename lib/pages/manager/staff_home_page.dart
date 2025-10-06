import 'package:bbqlagao_and_beefpares/models/user.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/inventory_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/menu_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/staff_list_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/modify_item_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/modify_dish_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/modify_user_page.dart';
import 'package:bbqlagao_and_beefpares/pages/manager/category_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/orders_page.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/order_history_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bbqlagao_and_beefpares/controllers/auth/auth_controller.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  String _currentPage = 'menu';
  String _appBarTitle = 'Staff Dashboard';
  String _tooltip = 'Add Menu';
  late ValueNotifier<bool> _showFabNotifier;
  bool _isManagementExpanded = true;
  bool _isUserManagementExpanded = false;
  bool _isAuditingExpanded = false;
  CategoryPage categoryPage = CategoryPage();

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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_appBarTitle != 'Staff Dashboard')
              Text(
                'Staff Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            Text(_appBarTitle, style: TextStyle(color: Colors.white)),
          ],
        ),

        flexibleSpace:
            [
              "dashboard",
              "inventory",
              "menu",
              "inventory",
              "category",
              "orders",
              "order_history",
              "staffs",
            ].contains(_currentPage)
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.redAccent, Colors.red, Colors.orangeAccent],
                  ),
                ),
              )
            : null,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            color: Colors.white,
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
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: _currentPage == 'dashboard'
                          ? Colors.white
                          : Colors.redAccent,
                    ),
                    title: Text(
                      'Dashboard',
                      style: TextStyle(
                        color: _currentPage == 'dashboard'
                            ? Colors.white
                            : Colors.redAccent,
                      ),
                    ),
                    selected: _currentPage == 'dashboard',
                    selectedTileColor: Colors.redAccent.withValues(alpha: 0.75),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentPage = 'dashboard';
                        _appBarTitle = 'Staff Dashboard';
                      });
                    },
                  ),
                  ExpansionTile(
                    initiallyExpanded: _isManagementExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isManagementExpanded = expanded;
                      });
                    },
                    title: const Text(
                      'Inventory Management',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    leading: const Icon(
                      Icons.business,
                      color: Colors.redAccent,
                    ),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.restaurant_menu,
                          color: _currentPage == 'menu'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Menu',
                          style: TextStyle(
                            color: _currentPage == 'menu'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'menu',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: 0.75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'menu';
                            _appBarTitle = 'Menu';
                            _tooltip = 'Add Menu';
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.inventory,
                          color: _currentPage == 'inventory'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Inventory',
                          style: TextStyle(
                            color: _currentPage == 'inventory'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'inventory',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: .75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'inventory';
                            _appBarTitle = 'Inventory';
                            _tooltip = 'Add Item';
                          });
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.category,
                          color: _currentPage == 'category'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Category',
                          style: TextStyle(
                            color: _currentPage == 'category'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'category',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: .75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'category';
                            _appBarTitle = 'Category';
                            _tooltip = 'Add Category';
                          });
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    initiallyExpanded: _isAuditingExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isAuditingExpanded = expanded;
                      });
                    },
                    title: const Text(
                      'Auditing',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    leading: Icon(
                      FontAwesomeIcons.fileLines,
                      color: Colors.redAccent,
                    ),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.list,
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
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: 0.75,
                        ),
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
                          color: _currentPage == 'order_history'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Order History',
                          style: TextStyle(
                            color: _currentPage == 'order_history'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'order_history',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: .75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'order_history';
                            _appBarTitle = 'Order History';
                          });
                        },
                      ),
                    ],
                  ),
                  ExpansionTile(
                    initiallyExpanded: _isUserManagementExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isUserManagementExpanded = expanded;
                      });
                    },
                    title: const Text(
                      'User Management',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    leading: const Icon(Icons.people, color: Colors.redAccent),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          FontAwesomeIcons.userGear,
                          color: _currentPage == 'staffs'
                              ? Colors.white
                              : Colors.redAccent,
                        ),
                        title: Text(
                          'Staffs',
                          style: TextStyle(
                            color: _currentPage == 'staffs'
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ),
                        selected: _currentPage == 'staffs',
                        selectedTileColor: Colors.redAccent.withValues(
                          alpha: .75,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 'staffs';
                            _appBarTitle = 'Staffs';
                            _tooltip = 'Add Staff';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: _logout,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.close, color: Colors.redAccent),
                      title: const Text(
                        'Close Menu',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton:
          ["inventory", "menu", "staffs"].contains(_currentPage)
          ? ValueListenableBuilder<bool>(
              valueListenable: _showFabNotifier,
              builder: (context, showFab, child) {
                if (!showFab) return const SizedBox.shrink();
                return FloatingActionButton(
                  backgroundColor: Colors.redAccent[100],
                  shape: const CircleBorder(),
                  foregroundColor: Colors.white,
                  onPressed: () {
                    switch (_currentPage) {
                      case 'inventory':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ModifyItemPage(),
                          ),
                        );
                        break;
                      case 'menu':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ModifyDishPage(),
                          ),
                        );
                        break;
                      case 'staffs':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ModifyUserPage(),
                          ),
                        );
                        break;
                      case 'category':
                        break;
                    }
                  },
                  tooltip: _tooltip,
                  child: const Icon(Icons.add),
                );
              },
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentPage) {
      case 'menu':
        return MenuPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'inventory':
        return InventoryPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'staffs':
        return StaffListPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'category':
        return CategoryPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'orders':
        return OrdersPage(onFabVisibilityChanged: _onFabVisibilityChanged);
      case 'order_history':
        return OrderHistoryPage();
      default:
        return const Center(child: Text('Page not implemented'));
    }
  }
}
